import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

abstract class ICryptographicService {
  Future<bool> init();
  Future<String?> decryptGroupChatMessage(String sender, String base64Message);
  Future<String?> decryptPrivateMessage(String sender, String base64Message);
  Future<void> processKeyDistributionMessage(String name, String base64Key);
  Future<void> updateOneTimeKeys();
  Future<void> clearSignalKeys();
  Future<Map<String, dynamic>?> initializeKeyBundle();
}

@lazySingleton
class CryptographicService implements ICryptographicService {
  static const MethodChannel _channel = MethodChannel('io.sekretess/signal_protocol');
  final Logger _logger = Logger();

  @override
  Future<bool> init() async {
    try {
      final result = await _channel.invokeMethod<bool>('init');
      return result ?? false;
    } catch (e) {
      _logger.e('Failed to initialize Signal protocol', error: e);
      return false;
    }
  }

  @override
  Future<String?> decryptGroupChatMessage(String sender, String base64Message) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'decryptGroupChatMessage',
        {
          'sender': sender,
          'base64Message': base64Message,
        },
      );
      return result;
    } catch (e) {
      _logger.e('Failed to decrypt group chat message', error: e);
      return null;
    }
  }

  @override
  Future<String?> decryptPrivateMessage(String sender, String base64Message) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'decryptPrivateMessage',
        {
          'sender': sender,
          'base64Message': base64Message,
        },
      );
      return result;
    } catch (e) {
      _logger.e('Failed to decrypt private message', error: e);
      return null;
    }
  }

  @override
  Future<void> processKeyDistributionMessage(String name, String base64Key) async {
    try {
      await _channel.invokeMethod<void>(
        'processKeyDistributionMessage',
        {
          'name': name,
          'base64Key': base64Key,
        },
      );
    } catch (e) {
      _logger.e('Failed to process key distribution message', error: e);
    }
  }

  @override
  Future<void> updateOneTimeKeys() async {
    try {
      await _channel.invokeMethod<void>('updateOneTimeKeys');
    } catch (e) {
      _logger.e('Failed to update one-time keys', error: e);
    }
  }

  @override
  Future<void> clearSignalKeys() async {
    try {
      await _channel.invokeMethod<void>('clearSignalKeys');
    } catch (e) {
      _logger.e('Failed to clear Signal keys', error: e);
    }
  }

  @override
  Future<Map<String, dynamic>?> initializeKeyBundle() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('initializeKeyBundle');
      if (result == null) return null;
      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      return result.map((key, value) => MapEntry(key.toString(), value));
    } catch (e) {
      _logger.e('Failed to initialize key bundle', error: e);
      return null;
    }
  }
}
