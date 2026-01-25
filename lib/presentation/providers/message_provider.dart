import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection.dart';
import '../../core/network/websocket_service.dart';
import '../../data/models/message_brief_dto.dart';
import '../../data/services/message_service.dart';

final messageServiceProvider = Provider<IMessageService>((ref) {
  return getIt<MessageService>();
});

// Stream provider for message events
final messageEventStreamProvider = StreamProvider<String>((ref) {
  final webSocketService = getIt<WebSocketService>();
  return webSocketService.messageEventStream;
});

final messageBriefsProvider = FutureProvider<List<MessageBriefDto>>((ref) async {
  final messageService = ref.watch(messageServiceProvider);
  
  // Watch message events to refresh when new messages arrive
  ref.watch(messageEventStreamProvider);
  
  return await messageService.getMessageBriefs();
});

final topSendersProvider = FutureProvider<List<String>>((ref) async {
  final messageService = ref.watch(messageServiceProvider);
  return await messageService.getTopSenders();
});

final filteredMessageBriefsProvider = Provider.family<List<MessageBriefDto>, String>((ref, query) {
  final messageBriefsAsync = ref.watch(messageBriefsProvider);
  
  return messageBriefsAsync.when(
    data: (briefs) {
      if (query.isEmpty) return briefs;
      
      final lowerQuery = query.toLowerCase();
      return briefs.where((brief) {
        return brief.sender.toLowerCase().contains(lowerQuery) ||
               brief.messageBody.toLowerCase().contains(lowerQuery);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
