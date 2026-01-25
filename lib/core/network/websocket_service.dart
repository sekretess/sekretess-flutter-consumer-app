import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import '../../data/models/message_dto.dart';
import '../../data/models/message_ack_dto.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/message_service.dart';
import '../enums/sekretess_event.dart';

abstract class IWebSocketService {
  Stream<SekretessEvent> get eventStream;
  Stream<MessageDto> get messageStream;
  Future<void> connect();
  void disconnect();
  bool ping();
  bool get isConnected;
}

@lazySingleton
class WebSocketService implements IWebSocketService {
  final AuthRepository _authRepository;
  final MessageService _messageService;
  final Logger _logger = Logger();
  
  WebSocketChannel? _channel;
  final _eventController = StreamController<SekretessEvent>.broadcast();
  final _messageController = StreamController<MessageDto>.broadcast();
  
  bool _isConnected = false;
  Timer? _pingTimer;
  DateTime? _tokenSentTime;
  bool _isAuthenticating = false;

  WebSocketService(this._authRepository, this._messageService);

  @override
  Stream<SekretessEvent> get eventStream => _eventController.stream;

  @override
  Stream<MessageDto> get messageStream => _messageController.stream;
  
  // Stream for simple string events (for Riverpod)
  Stream<String> get messageEventStream => _messageController.stream.map((_) => 'new-message');

  @override
  bool get isConnected => _isConnected;

  @override
  Future<void> connect() async {
    if (_isConnected) {
      _logger.i('WebSocket is already connected');
      return;
    }

    try {
      final token = await _authRepository.getAccessToken();
      if (token == null) {
        _logger.e('Cannot connect: No access token');
        _eventController.add(SekretessEvent.authFailed);
        _handleUnauthorized();
        return;
      }

      final uri = Uri.parse('${AppConstants.webSocketUrl}/ws');
      final webSocket = await WebSocket.connect(
        uri.toString(),
        headers: {
          'Origin': 'https://consumer.sekretess.io',
        },
      );
      _channel = IOWebSocketChannel(webSocket);

      _isAuthenticating = true;
      _tokenSentTime = DateTime.now();

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );

      // Send auth token
      _channel!.sink.add(token);
      
      // Wait a bit to see if connection closes immediately (indicates 403)
      // If connection is still open after a short delay, consider it authenticated
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if connection was closed during authentication (indicates 403)
      if (!_isAuthenticating) {
        // Connection was closed, _handleDone or _handleError already handled it
        return;
      }
      
      // Connection is still open, authentication successful
      _isConnected = true;
      _isAuthenticating = false;
      _eventController.add(SekretessEvent.websocketConnectionEstablished);
      _startPingTimer();
      _logger.i('WebSocket connected and authenticated');
    } catch (e) {
      _logger.e('WebSocket connection failed', error: e);
      _isConnected = false;
      _isAuthenticating = false;
      
      // Check if error indicates 403
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('403') || 
          errorString.contains('forbidden') ||
          errorString.contains('unauthorized')) {
        _logger.e('WebSocket connection forbidden (403)');
        _handleUnauthorized();
      } else {
        _eventController.add(SekretessEvent.websocketConnectionLost);
      }
    }
  }

  void _handleMessage(dynamic message) {
    try {
      String messageString;
      
      // Handle both String and List<int> (binary) messages
      if (message is String) {
        messageString = message;
      } else if (message is List<int>) {
        // Convert array of integers (bytes) to UTF-8 string
        messageString = utf8.decode(message);
        _logger.d('Received binary message, converted to string: $messageString');
      } else {
        _logger.w('Received message of unsupported type: ${message.runtimeType}');
        return;
      }
      
      final json = jsonDecode(messageString) as Map<String, dynamic>;
      final messageDto = MessageDto.fromJson(json);
      
      // Handle message through MessageService (which will decrypt it)
      _messageService.handleMessage(messageDto);
      
      // Send ACK
      sendAck(messageDto.messageId, 2); // MESSAGE_HANDLING_SUCCESS
      
      // Also emit to message stream for UI updates
      _messageController.add(messageDto);
    } catch (e) {
      _logger.e('Error handling WebSocket message', error: e);
      // Try to send failure ACK if we have message ID
      try {
        String messageString;
        if (message is String) {
          messageString = message;
        } else if (message is List<int>) {
          messageString = utf8.decode(message);
        } else {
          return;
        }
        
        final json = jsonDecode(messageString) as Map<String, dynamic>;
        final messageDto = MessageDto.fromJson(json);
        sendAck(messageDto.messageId, 3); // MESSAGE_HANDLING_FAILED
      } catch (_) {
        // Ignore ACK errors
      }
    }
  }

  void _handleError(dynamic error) {
    _logger.e('WebSocket error', error: error);
    _isConnected = false;
    _stopPingTimer();
    
    // Check if error indicates 403/Forbidden
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('403') || 
        errorString.contains('forbidden') ||
        errorString.contains('unauthorized')) {
      _logger.e('WebSocket error indicates 403 Forbidden');
      _handleUnauthorized();
      return;
    }
    
    if (_isAuthenticating && _tokenSentTime != null) {
      // If connection fails shortly after sending token, likely auth failure
      final timeSinceToken = DateTime.now().difference(_tokenSentTime!);
      if (timeSinceToken.inSeconds < 2) {
        _logger.e('WebSocket closed immediately after authentication, likely 403');
        _handleUnauthorized();
        return;
      }
    }
    
    // Only emit connection lost if we were actually connected (not during auth)
    if (!_isAuthenticating) {
      _eventController.add(SekretessEvent.websocketConnectionLost);
    }
  }

  void _handleDone() {
    _logger.i('WebSocket connection closed');
    _isConnected = false;
    _stopPingTimer();
    
    // If connection closed shortly after sending token, likely 403
    if (_isAuthenticating && _tokenSentTime != null) {
      final timeSinceToken = DateTime.now().difference(_tokenSentTime!);
      if (timeSinceToken.inSeconds < 2) {
        _logger.e('WebSocket closed immediately after authentication, likely 403');
        _handleUnauthorized();
        return;
      }
    }
    
    // Only emit connection lost if we were actually connected
    if (!_isAuthenticating) {
      _eventController.add(SekretessEvent.websocketConnectionLost);
    }
    _isAuthenticating = false;
  }
  
  void _handleUnauthorized() {
    _logger.e('WebSocket unauthorized (403), logging out user');
    _isAuthenticating = false;
    _isConnected = false;
    _eventController.add(SekretessEvent.authFailed);
    // Clear auth state and trigger logout
    _authRepository.clearUserData();
  }

  @override
  void disconnect() {
    _stopPingTimer();
    _channel?.sink.close();
    _isConnected = false;
    _eventController.add(SekretessEvent.websocketConnectionLost);
  }

  @override
  bool ping() {
    if (!_isConnected) {
      _logger.e('WebSocket is not connected');
      return false;
    }

    try {
      final pingMessage = 'sekretess-ping:${DateTime.now().millisecondsSinceEpoch}';
      _channel?.sink.add(pingMessage);
      _logger.i('Ping sent');
      return true;
    } catch (e) {
      _logger.e('Ping failed', error: e);
      return false;
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ping();
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void sendAck(String messageId, int status) {
    if (!_isConnected) return;

    try {
      final ack = MessageAckDto(messageId: messageId, status: status);
      _channel?.sink.add(ack.jsonString());
    } catch (e) {
      _logger.e('Failed to send ACK', error: e);
    }
  }

  void dispose() {
    disconnect();
    _eventController.close();
    _messageController.close();
  }
}
