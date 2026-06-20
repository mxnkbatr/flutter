import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/features/messenger/providers/messenger_provider.dart';
import 'package:sacred_app/shared/widgets/error_state.dart';
import 'package:sacred_app/features/messenger/widgets/messenger_page_scaffold.dart';
import 'package:sacred_app/features/messenger/widgets/messenger_segment_tabs.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0EB),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.9),
                      ),
                    ),
                    child: Transform.translate(
                      offset: const Offset(0, -1),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 36,
                        color: AppColors.inkDeep,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Чат байхгүй',
                    style: AppText.h3.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkDeep,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: constraints.maxWidth * 0.92,
                    child: Text(
                      'Ламын профайлаас\nмессеж илгээнэ үү',
                      style: AppText.bodySmall.copyWith(
                        color: const Color(0xFF666666),
                        fontSize: 13.5,
                        height: 20 / 13.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SacredButton(
                    label: 'Лам олох',
                    small: true,
                    sunShadow: true,
                    prominent: true,
                    onTap: () => context.go('/home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final convosAsync = ref.watch(conversationsProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 80;

    return MessengerPageScaffold(
      segmentTabs: MessengerSegmentTabs(
        labels: const ['Бүгд', 'Лам', 'Дэмжлэг'],
        selected: _tab,
        onChanged: (i) => setState(() => _tab = i),
      ),
      body: convosAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.saffron),
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
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Text(
                    _tab == 2 ? 'Дэмжлэгийн чат байхгүй' : 'Чат байхгүй',
                    style: AppText.bodySmall,
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPad),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) {
              final c = filtered[i];
              return _ChatListTile(
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

class _ChatListTile extends StatelessWidget {
  const _ChatListTile({
    required this.name,
    required this.preview,
    required this.onTap,
    this.time,
  });

  final String name;
  final String preview;
  final String? time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String timeStr = '';
    if (time != null && time!.isNotEmpty) {
      try {
        timeStr =
            DateFormat('HH:mm').format(DateTime.parse(time!).toLocal());
      } catch (_) {
        timeStr = '';
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.inkDeep,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppText.h3.copyWith(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timeStr.isNotEmpty)
                          Text(timeStr, style: AppText.caption),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      style: AppText.bodySmall.copyWith(
                        color: AppColors.saffron,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
