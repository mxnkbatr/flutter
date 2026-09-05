import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/features/messenger/providers/messenger_provider.dart';
import 'package:sacred_app/features/messenger/widgets/chat_conversation_tile.dart';
import 'package:sacred_app/features/messenger/widgets/messenger_page_scaffold.dart';
import 'package:sacred_app/shared/widgets/empty_state.dart';
import 'package:sacred_app/shared/widgets/error_state.dart';

class MessengerScreen extends ConsumerWidget {
  const MessengerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convosAsync = ref.watch(conversationsProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 80;

    return MessengerPageScaffold(
      body: convosAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ErrorState(
              error: e,
              fallback: 'Чатын жагсаалт ачаалахад алдаа гарлаа.',
              onRetry: () => ref.invalidate(conversationsProvider),
            ),
          ),
        ),
        data: (convos) {
          if (convos.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: EmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Чат байхгүй',
                      message: 'Ламын профайлаас мессеж илгээнэ үү',
                      actionLabel: 'Лам олох',
                      onAction: () => context.go('/home'),
                    ),
                  ),
                );
              },
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad),
            itemCount: convos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final c = convos[i];
              return ChatConversationTile(
                name: c.displayName,
                preview: c.lastMessage ?? 'Мессеж эхлүүлэх',
                time: c.lastMessageAt,
                onTap: () => context.push(
                  '/messenger/${c.id}?title=${Uri.encodeComponent(c.displayName)}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
