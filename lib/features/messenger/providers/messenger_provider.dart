import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/features/messenger/models/chat_message.dart';
import 'package:sacred_app/features/messenger/models/conversation.dart';

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final res = await ref.read(apiClientProvider).get('/messenger/conversations');
  final list = res.data is List
      ? res.data as List
      : (res.data as Map<String, dynamic>)['conversations'] as List? ?? [];
  return list
      .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
      .toList();
});

final messagesProvider =
    FutureProvider.family<List<ChatMessage>, String>((ref, conversationId) async {
  final res = await ref.read(apiClientProvider).get(
        '/messenger/conversations/$conversationId/messages',
      );
  final list = res.data is List ? res.data as List : [];
  return list
      .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
      .toList();
});

Future<String> startConversation(WidgetRef ref, String monkId) async {
  final res = await ref.read(apiClientProvider).post(
        '/messenger/conversations',
        data: {'monkId': monkId},
      );
  final data = res.data as Map<String, dynamic>;
  ref.invalidate(conversationsProvider);
  return data['id'] as String;
}

Future<void> sendMessage(
  WidgetRef ref, {
  required String conversationId,
  required String text,
}) async {
  await ref.read(apiClientProvider).post(
        '/messenger/conversations/$conversationId/messages',
        data: {'text': text},
      );
  ref.invalidate(messagesProvider(conversationId));
  ref.invalidate(conversationsProvider);
}
