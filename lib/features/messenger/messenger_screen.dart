import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/features/messenger/providers/messenger_provider.dart';
import 'package:sacred_app/shared/widgets/error_state.dart';
import 'package:sacred_app/features/messenger/widgets/messenger_page_scaffold.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

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
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.orangeLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 36,
                      color: AppColors.orange.withOpacity(0.65),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Чат байхгүй',
                    style: AppText.h3.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: constraints.maxWidth * 0.88,
                    child: Text(
                      'Ламын профайлаас\nмессеж илгээнэ үү',
                      style: AppText.bodySmall.copyWith(
                        color: AppColors.textSec,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SacredButton(
                    label: 'Лам олох',
                    small: true,
                    sunShadow: true,
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

  Widget _filterEmpty(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.filter_list_off_rounded,
                  color: AppColors.orange.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: AppText.bodySmall.copyWith(color: AppColors.textSec),
              ),
            ],
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

  String get _role {
    if (name.toLowerCase().contains('дэмжлэг')) return 'Дэмжлэг';
    return 'Лам';
  }

  @override
  Widget build(BuildContext context) {
    String timeStr = '';
    if (time != null && time!.isNotEmpty) {
      try {
        final dt = DateTime.parse(time!).toLocal();
        final now = DateTime.now();
        if (dt.year == now.year &&
            dt.month == now.month &&
            dt.day == now.day) {
          timeStr = DateFormat('HH:mm').format(dt);
        } else {
          timeStr = DateFormat('MM/dd').format(dt);
        }
      } catch (_) {
        timeStr = '';
      }
    }

    return ScaleTap(
      pressedScale: 0.98,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: MinimalStyle.card(radius: MinimalStyle.cardRadiusLg),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: MinimalStyle.avatarBox(radius: 26),
                  alignment: Alignment.center,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AppColors.orange.withOpacity(0.75),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
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
                          style: AppText.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeStr.isNotEmpty)
                        Text(
                          timeStr,
                          style: AppText.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orangeLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _role,
                          style: AppText.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.orangeDeep,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          preview,
                          style: AppText.bodySmall.copyWith(
                            color: AppColors.textSec,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textHint.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}
