import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection.dart';
import '../../core/network/websocket_service.dart';
import '../../data/models/message_brief_dto.dart';
import '../../data/services/message_service.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider.autoDispose<IAuthRepository>((ref) {
  return getIt<AuthRepository>();
});

final usernameProvider = FutureProvider.autoDispose<String?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.getUsername();
});

final messageServiceProvider = Provider.autoDispose<IMessageService>((ref) {
  return getIt<MessageService>();
});

// Stream provider for message events
final messageEventStreamProvider = StreamProvider.autoDispose<String>((ref) {
  final webSocketService = getIt<WebSocketService>();
  return webSocketService.messageEventStream;
});

final messageBriefsProvider = FutureProvider.autoDispose<List<MessageBriefDto>>((ref) async {
  final messageService = ref.watch(messageServiceProvider);
  final usernameAsyncValue = ref.watch(usernameProvider);
  
  // Watch message events to refresh when new messages arrive
  ref.watch(messageEventStreamProvider);
  
  final username = usernameAsyncValue.asData?.value;
  if (username == null) {
    // Return empty list or handle loading/error states appropriately
    return [];
  }
  
  return await messageService.getMessageBriefs(username);
});

final topSendersProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final messageService = ref.watch(messageServiceProvider);
  final usernameAsyncValue = ref.watch(usernameProvider);
  final username = usernameAsyncValue.asData?.value;
  if (username == null) {
    // Return empty list or handle loading/error states appropriately
    return [];
  }
  return await messageService.getTopSenders(username);
});

final filteredMessageBriefsProvider = Provider.autoDispose.family<List<MessageBriefDto>, String>((ref, query) {
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