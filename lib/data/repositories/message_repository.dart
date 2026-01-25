import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../models/message_brief_dto.dart';
import '../database/message_database.dart';
import '../../core/di/injection.dart';
import 'auth_repository.dart';

// Import the generated Message class
import '../database/message_database.dart' as db;

abstract class IMessageRepository {
  Future<List<MessageBriefDto>> getMessageBriefs();
  Future<List<String>> getTopSenders();
  Future<void> storeDecryptedMessage(String sender, String message, String username);
  Future<List<Message>> getMessages(String username, String sender);
  Future<void> deleteMessage(int messageId);
  // TEMPORARY: Clear database for testing - REMOVE IN PRODUCTION
  Future<void> clearDatabase();
}

@lazySingleton
class MessageRepository implements IMessageRepository {
  final MessageDatabase _database;
  final Logger _logger = Logger();

  MessageRepository() : _database = MessageDatabase();

  @override
  Future<List<MessageBriefDto>> getMessageBriefs() async {
    try {
      final authRepository = getIt<AuthRepository>();
      final username = await authRepository.getUsername();
      if (username == null) return [];

      final messages = await _database.getMessageBriefs(username);
      return messages.map((msg) {
        return MessageBriefDto(
          sender: msg.sender,
          messageBody: msg.messageBody,
          timestamp: msg.createdAt,
        );
      }).toList();
    } catch (e) {
      _logger.e('Failed to get message briefs', error: e);
      return [];
    }
  }

  @override
  Future<List<String>> getTopSenders() async {
    try {
      return await _database.getTopSenders();
    } catch (e) {
      _logger.e('Failed to get top senders', error: e);
      return [];
    }
  }

  @override
  Future<void> storeDecryptedMessage(
    String sender,
    String message,
    String username,
  ) async {
    try {
      await _database.insertMessage(username, sender, message);
      _logger.i('Stored decrypted message from $sender');
    } catch (e) {
      _logger.e('Failed to store decrypted message', error: e);
    }
  }

  @override
  Future<List<db.Message>> getMessages(String username, String sender) async {
    try {
      return await _database.getMessages(username, sender);
    } catch (e) {
      _logger.e('Failed to get messages', error: e);
      return [];
    }
  }

  @override
  Future<void> deleteMessage(int messageId) async {
    try {
      await _database.deleteMessage(messageId);
    } catch (e) {
      _logger.e('Failed to delete message', error: e);
    }
  }

  // TEMPORARY: Clear database for testing - REMOVE IN PRODUCTION
  @override
  Future<void> clearDatabase() async {
    try {
      await _database.clear();
      _logger.i('Database cleared');
    } catch (e) {
      _logger.e('Failed to clear database', error: e);
    }
  }
}
