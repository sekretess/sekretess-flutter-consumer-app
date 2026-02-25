import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

import '../models/message_brief_dto.dart';
import '../models/message_dto.dart';
import '../models/message_record_dto.dart';
import '../models/business_dto.dart';
import '../repositories/message_repository.dart';
import '../repositories/auth_repository.dart';
import '../../core/enums/message_type.dart';
import 'cryptographic_service.dart';
import '../database/message_database.dart' as db;

abstract class IMessageService {
  Future<List<MessageBriefDto>> getMessageBriefs(String username);
  Future<List<String>> getTopSenders(String username);
  Future<void> handleMessage(MessageDto message);
  Future<List<MessageRecordDto>> loadMessages(String sender);
}

@lazySingleton
class MessageService implements IMessageService {
  final MessageRepository _messageRepository;
  final AuthRepository _authRepository;
  final CryptographicService _cryptographicService;
  final Logger _logger = Logger();

  MessageService(
    this._messageRepository,
    this._authRepository,
    this._cryptographicService,
  );

  @override
  Future<List<MessageBriefDto>> getMessageBriefs(String username) async {
    return await _messageRepository.getMessageBriefs(username);
  }

  @override
  Future<List<String>> getTopSenders(String username) async {
    return await _messageRepository.getTopSenders(username);
  }

  @override
  Future<void> handleMessage(MessageDto message) async {
    try {
      final messageType = MessageType.fromString(message.type);
      final encryptedText = message.text;
      final sender = message.sender;

      _logger.i('Handling message type: ${message.type} from $sender');

      switch (messageType) {
        case MessageType.advertisement:
          await _processAdvertisementMessage(encryptedText, sender);
          break;
        case MessageType.keyDistribution:
          await _processKeyDistributionMessage(encryptedText, sender);
          break;
        case MessageType.private:
          await _processPrivateMessage(encryptedText, sender);
          break;
        case MessageType.unknown:
          _logger.w('Unknown message type: ${message.type}');
          break;
      }
    } catch (e) {
      _logger.e('Error handling message', error: e);
    }
  }

  Future<void> _processAdvertisementMessage(
    String base64Message,
    String sender,
  ) async {
    try {
      final decryptedMessage =
          await _cryptographicService.decryptGroupChatMessage(sender, base64Message);
      if (decryptedMessage != null) {
        final username = await _authRepository.getUsername();
        await _messageRepository.storeDecryptedMessage(
          sender,
          decryptedMessage,
          username ?? 'unknown',
        );
        _logger.i('Stored decrypted advertisement message from $sender');
      }
    } catch (e) {
      _logger.e('Error processing advertisement message', error: e);
    }
  }

  Future<void> _processPrivateMessage(
    String encryptedText,
    String sender,
  ) async {
    try {
      final decryptedMessage =
          await _cryptographicService.decryptPrivateMessage(sender, encryptedText);
      if (decryptedMessage != null) {
        final username = await _authRepository.getUsername();
        await _messageRepository.storeDecryptedMessage(
          sender,
          decryptedMessage,
          username ?? 'unknown',
        );
        _logger.i('Stored decrypted private message from $sender');
      }
    } catch (e) {
      _logger.e('Error processing private message', error: e);
    }
  }

  Future<void> _processKeyDistributionMessage(
    String encryptedText,
    String sender,
  ) async {
    try {
      final decryptedMessage =
          await _cryptographicService.decryptPrivateMessage(sender, encryptedText);
      if (decryptedMessage != null) {
        await _cryptographicService.processKeyDistributionMessage(sender, decryptedMessage);
        _logger.i('Processed key distribution message from $sender');
      }
    } catch (e) {
      _logger.e('Error processing key distribution message', error: e);
    }
  }

  @override
  Future<List<MessageRecordDto>> loadMessages(String sender) async {
    try {
      final username = await _authRepository.getUsername();
      if (username == null) return [];

      final messages = await _messageRepository.getMessages(username, sender);
      final List<MessageRecordDto> messageRecords = [];
      String? lastDateText;

      for (final message in messages) {
        final messageDate = DateTime.fromMillisecondsSinceEpoch(message.createdAt);
        final dateText = _formatDateText(messageDate);

        // Add date header if date changed
        if (lastDateText != dateText) {
          messageRecords.add(MessageRecordDto(
            sender: message.sender,
            message: null,
            messageDate: message.createdAt,
            dateText: dateText,
            itemType: ItemType.header,
          ));
          lastDateText = dateText;
        }

        // Add message item
        messageRecords.add(MessageRecordDto(
          messageId: message.id,
          sender: message.sender,
          message: message.messageBody,
          messageDate: message.createdAt,
          dateText: dateText,
          itemType: ItemType.item,
        ));
      }

      return messageRecords;
    } catch (e) {
      _logger.e('Failed to load messages', error: e);
      return [];
    }
  }

  String _formatDateText(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final daysDifference = today.difference(messageDate).inDays;

    if (daysDifference == 0) {
      return 'Today';
    } else if (daysDifference <= 7) {
      return DateFormat('EEEE').format(dateTime); // Day of week
    } else {
      final monthsDifference = (now.year - dateTime.year) * 12 + (now.month - dateTime.month);
      if (monthsDifference >= 12) {
        return DateFormat('dd MMMM yyyy').format(dateTime); // Full date with year
      } else {
        return DateFormat('dd MMMM').format(dateTime); // Day and month
      }
    }
  }

  // Helper method to insert message with specific timestamp
  Future<void> _insertMessageWithTimestamp(
    String sender,
    String message,
    String username,
    DateTime timestamp,
  ) async {
    try {
      // Use the database directly to set custom timestamp
      final messageDatabase = db.MessageDatabase();
      await messageDatabase.insertMessageWithTimestamp(
        username,
        sender,
        message,
        timestamp.millisecondsSinceEpoch,
      );
    } catch (e) {
      _logger.e('Failed to insert message with timestamp', error: e);
    }
  }
}
