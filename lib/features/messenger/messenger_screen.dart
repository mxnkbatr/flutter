import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/features/messenger/providers/messenger_provider.dart';
import 'package:sacred_app/features/messenger/widgets/chat_conversation_tile.dart';
import 'package:sacred_app/features/messenger/widgets/messenger_page_scaffold.dart';
import 'package:sacred_app/shared/widgets/empty_state.dart';
import 'package:sacred_app/shared/widgets/error_state.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';

class MessengerScreen extends ConsumerStatefulWidget {
  const MessengerScreen({super.key});

  @override
  ConsumerState<MessengerScreen> createState() => _MessengerScreenState();
}

class _MessengerScreenState extends ConsumerState<MessengerScreen> {
  int _tab = 0;

  Widget _emptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
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

  Widget _filterEmpty(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 320,
          child: EmptyState(
            icon: Icons.filter_list_off_rounded,
            title: message,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final convosAsync = ref.watch(conversationsProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 80;

    return MessengerPageScaffold(
      segmentTabs: PremiumSegmentTabs(
        labels: const ['Бүгд', 'Лам', 'Дэмжлэг'],
        selected: _tab,
        onChanged: (i) => setState(() => _tab = i),
      ),
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
          if (convos.isEmpty) return _emptyState(context);

          final filtered = switch (_tab) {
            1 => convos.where((c) => c.monkName.isNotEmpty).toList(),
            2 => convos
                .where((c) => c.monkName.toLowerCase().contains('дэмжлэг'))
                .toList(),
            _ => convos,
          };

          if (filtered.isEmpty) {
            return _filterEmpty(
              _tab == 2 ? 'Дэмжлэгийн чат байхгүй' : 'Чат байхгүй',
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final c = filtered[i];
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
