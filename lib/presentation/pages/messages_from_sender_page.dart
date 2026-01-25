import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/message_record_dto.dart';
import '../../data/models/business_dto.dart';
import '../../data/models/message_dto.dart';
import '../../data/services/message_service.dart';
import '../../data/repositories/message_repository.dart';
import '../../core/network/websocket_service.dart';

class MessagesFromSenderPage extends ConsumerStatefulWidget {
  final String sender;

  const MessagesFromSenderPage({
    super.key,
    required this.sender,
  });

  @override
  ConsumerState<MessagesFromSenderPage> createState() => _MessagesFromSenderPageState();
}

class _MessagesFromSenderPageState extends ConsumerState<MessagesFromSenderPage> {
  List<MessageRecordDto> _messages = [];
  bool _isLoading = true;
  StreamSubscription<MessageDto>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _listenToMessageEvents();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messageService = getIt<MessageService>();
      final messages = await messageService.loadMessages(widget.sender);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _listenToMessageEvents() {
    final webSocketService = getIt<WebSocketService>();
    _messageSubscription = webSocketService.messageStream.listen((message) {
      // Reload messages if the new message is from this sender
      if (message.sender == widget.sender) {
        _loadMessages();
      }
    });
  }

  Future<void> _deleteMessage(int messageId) async {
    try {
      final messageRepository = getIt<MessageRepository>();
      await messageRepository.deleteMessage(messageId);
      await _loadMessages(); // Reload messages after deletion
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete message: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(widget.sender),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.sekretessBlue),
              ),
            )
          : _messages.isEmpty
              ? _buildEmptyState()
              : _buildMessagesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with ${widget.sender}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return RefreshIndicator(
      onRefresh: _loadMessages,
      color: AppColors.sekretessBlue,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          if (message.itemType == ItemType.header) {
            return _buildDateHeader(message.dateText ?? '');
          } else {
            return Dismissible(
              key: Key('message_${message.messageId}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete,
                  color: AppColors.white,
                ),
              ),
              onDismissed: (direction) {
                if (message.messageId != null) {
                  _deleteMessage(message.messageId!);
                }
              },
              child: _buildMessageBubble(message),
            );
          }
        },
      ),
    );
  }

  Widget _buildDateHeader(String dateText) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Text(
        dateText,
        style: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageRecordDto message) {
    final messageTime = DateFormat('HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(message.messageDate),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.message != null)
              Text(
                message.message!,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              messageTime,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
