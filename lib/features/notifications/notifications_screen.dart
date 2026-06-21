import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/features/notifications/models/app_notification.dart';
import 'package:sacred_app/features/notifications/providers/notifications_provider.dart';
import 'package:sacred_app/shared/widgets/native_app_header.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final notifications = ref.watch(notificationsProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 24;
    final initial = (auth?.userName?.isNotEmpty ?? false)
        ? auth!.userName![0].toUpperCase()
        : '?';

    final filtered = _tab == 1
        ? notifications.where((n) => !n.isRead).toList()
        : notifications;

    return PremiumLayeredScaffold(
      expandBody: true,
      showBackButton: true,
      headerContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NativeLargeTitleHeader(
            eyebrow: 'Таны',
            title: 'Мэдэгдэл',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NativeHeaderIconButton(
                  icon: Icons.settings_outlined,
                  onTap: () => context.push('/profile/notifications'),
                ),
                const SizedBox(width: 8),
                NativeAvatarButton(
                  initial: initial,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumSegmentTabs(
            labels: const ['Бүгд', 'Уншаагүй'],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
        ],
      ),
      body: filtered.isEmpty
          ? _emptyState()
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _NotificationCard(
                notification: filtered[i],
                onTap: () {
                  ref
                      .read(notificationsProvider.notifier)
                      .markRead(filtered[i].id);
                  HapticFeedback.lightImpact();
                },
              ),
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 34,
                color: AppColors.orange.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _tab == 1 ? 'Уншаагүй мэдэгдэл байхгүй' : 'Мэдэгдэл байхгүй',
              style: AppText.h3.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  IconData get _icon => switch (notification.type) {
        AppNotificationType.booking => Icons.notifications_active_outlined,
        AppNotificationType.message => Icons.chat_bubble_outline_rounded,
        AppNotificationType.promo => Icons.local_offer_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(notification.createdAt);

    return ScaleTap(
      pressedScale: 0.98,
      onTap: onTap,
      child: Container(
        decoration: MinimalStyle.card(radius: MinimalStyle.cardRadiusLg),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!notification.isRead)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(MinimalStyle.cardRadiusLg),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.orangeLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_icon, color: AppColors.orange, size: 22),
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
                                    notification.title,
                                    style: AppText.body.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Text(
                                  time,
                                  style: AppText.caption.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.body,
                              style: AppText.bodySmall.copyWith(
                                color: AppColors.textSec,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
