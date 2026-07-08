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
      .where((c) => c.id.isNotEmpty)
      .toList();
});

final messagesProvider =
    FutureProvider.family<List<ChatMessage>, String>((ref, conversationId) async {
  final res = await ref.read(apiClientProvider).get(
        '/messenger/conversations/$conversationId/messages',
      );
  final list = res.data is List ? res.data as List : [];
  final messages = <ChatMessage>[];
  for (final item in list) {
    if (item is! Map<String, dynamic>) continue;
    try {
      final msg = ChatMessage.fromJson(item);
      if (msg.id.isNotEmpty) messages.add(msg);
    } catch (_) {}
  }
  return messages;
});

class StartConversationResult {
  const StartConversationResult({required this.id, required this.monkName});
  final String id;
  final String monkName;
}

Future<StartConversationResult> startConversation(
  WidgetRef ref,
  String monkId,
) async {
  final res = await ref.read(apiClientProvider).post(
        '/messenger/conversations',
        data: {'monkId': monkId},
      );
  final data = res.data as Map<String, dynamic>;
  ref.invalidate(conversationsProvider);
  final id = data['id']?.toString() ?? '';
  final monkName = data['monkName']?.toString() ?? '';
  return StartConversationResult(id: id, monkName: monkName);
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
  ref.invalidate(conversationsProvider);
  final _ = await ref.refresh(messagesProvider(conversationId).future);
}
