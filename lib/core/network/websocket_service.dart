import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
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
class WebSocketService extends WidgetsBindingObserver implements IWebSocketService {
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
  
  // Reconnection logic
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isManualDisconnect = false;
  static const int _maxReconnectDelaySeconds = 60;

  WebSocketService(this._authRepository, this._messageService) {
    WidgetsBinding.instance.addObserver(this);
  }

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

    // Don't try to connect if user is not authorized
    // We check this without forcing a refresh if possible, or handling the null
    final token = await _authRepository.getAccessToken();
    if (token == null) {
      _logger.w('WebSocket connect: No access token available (User might be logged out or refresh failed)');
      // If we don't have a token, we just wait and retry later. 
      // We do NOT call _handleUnauthorized() here because that forces a logout.
      // The AuthRepository will force a logout itself if the refresh token is actually expired.
      _scheduleReconnect();
      return;
    }

    _isManualDisconnect = false;
    _reconnectTimer?.cancel();

    try {
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
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!_isAuthenticating) {
        return;
      }
      
      _isConnected = true;
      _isAuthenticating = false;
      _reconnectAttempts = 0; // Reset attempts on successful connection
      _eventController.add(SekretessEvent.websocketConnectionEstablished);
      _startPingTimer();
      _logger.i('WebSocket connected and authenticated');
    } catch (e) {
      _logger.e('WebSocket connection failed', error: e);
      _isConnected = false;
      _isAuthenticating = false;
      
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('403') || 
          errorString.contains('forbidden') ||
          errorString.contains('unauthorized')) {
        _logger.e('WebSocket connection forbidden (403)');
        _handleUnauthorized();
      } else {
        _eventController.add(SekretessEvent.websocketConnectionLost);
        _scheduleReconnect();
      }
    }
  }

  void _scheduleReconnect() {
    if (_isManualDisconnect || (_reconnectTimer?.isActive ?? false)) return;

    _reconnectAttempts++;
    final delaySeconds = (_reconnectAttempts * 2).clamp(2, _maxReconnectDelaySeconds);
    
    _logger.i('Scheduling WebSocket reconnect in $delaySeconds seconds (attempt $_reconnectAttempts)');
    
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isConnected && !_isManualDisconnect) {
        connect();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logger.i('App lifecycle state changed: $state');
    if (state == AppLifecycleState.resumed) {
      if (!_isConnected && !_isManualDisconnect) {
        _logger.i('App resumed, attempting to reconnect WebSocket');
        // When resuming, we try to connect immediately
        _reconnectTimer?.cancel();
        connect();
      }
    }
  }

  void _handleMessage(dynamic message) {
    try {
      String messageString;
      if (message is String) {
        messageString = message;
      } else if (message is List<int>) {
        messageString = utf8.decode(message);
        _logger.d('Received binary message, converted to string: $messageString');
      } else {
        _logger.w('Received message of unsupported type: ${message.runtimeType}');
        return;
      }
      
      final json = jsonDecode(messageString) as Map<String, dynamic>;
      final messageDto = MessageDto.fromJson(json);
      _messageService.handleMessage(messageDto);
      sendAck(messageDto.messageId, 2); 
      _messageController.add(messageDto);
    } catch (e) {
      _logger.e('Error handling WebSocket message', error: e);
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
        sendAck(messageDto.messageId, 3);
      } catch (_) {}
    }
  }

  void _handleError(dynamic error) {
    _logger.e('WebSocket error', error: error);
    _isConnected = false;
    _stopPingTimer();
    
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('403') || 
        errorString.contains('forbidden') ||
        errorString.contains('unauthorized')) {
      _logger.e('WebSocket error indicates 403 Forbidden');
      _handleUnauthorized();
      return;
    }
    
    if (_isAuthenticating && _tokenSentTime != null) {
      final timeSinceToken = DateTime.now().difference(_tokenSentTime!);
      if (timeSinceToken.inSeconds < 2) {
        _logger.e('WebSocket closed immediately after authentication, likely 403');
        _handleUnauthorized();
        return;
      }
    }
    
    if (!_isAuthenticating) {
      _eventController.add(SekretessEvent.websocketConnectionLost);
      _scheduleReconnect();
    }
  }

  void _handleDone() {
    _logger.i('WebSocket connection closed');
    _isConnected = false;
    _stopPingTimer();
    
    if (_isAuthenticating && _tokenSentTime != null) {
      final timeSinceToken = DateTime.now().difference(_tokenSentTime!);
      if (timeSinceToken.inSeconds < 2) {
        _logger.e('WebSocket closed immediately after authentication, likely 403');
        _handleUnauthorized();
        return;
      }
    }
    
    if (!_isAuthenticating) {
      _eventController.add(SekretessEvent.websocketConnectionLost);
      _scheduleReconnect();
    }
    _isAuthenticating = false;
  }
  
  void _handleUnauthorized() {
    // Only force logout if we are absolutely sure the session is invalid
    _logger.e('WebSocket unauthorized (403), logging out user');
    _isAuthenticating = false;
    _isConnected = false;
    _eventController.add(SekretessEvent.authFailed);
    _authRepository.clearUserData();
  }

  @override
  void disconnect() {
    _isManualDisconnect = true;
    _reconnectTimer?.cancel();
    _stopPingTimer();
    _channel?.sink.close();
    _isConnected = false;
    _eventController.add(SekretessEvent.websocketConnectionLost);
  }

  @override
  bool ping() {
    if (!_isConnected) {
      return false;
    }

    try {
      final pingMessage = 'sekretess-ping:${DateTime.now().millisecondsSinceEpoch}';
      _channel?.sink.add(pingMessage);
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
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
    _eventController.close();
    _messageController.close();
  }
}