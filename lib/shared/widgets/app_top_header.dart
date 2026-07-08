import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/notifications/providers/notifications_provider.dart';
import 'package:sacred_app/features/shop/providers/shop_providers.dart';
import 'package:sacred_app/shared/widgets/gevabal_logo.dart';
import 'package:sacred_app/shared/widgets/native_app_header.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

/// Global app bar — logo left, actions right (notification, cart, menu).
class AppTopHeader extends ConsumerWidget {
  const AppTopHeader({super.key});

  void _openMenu(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceEl,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.borderSub,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text('Цэс', style: AppText.h3),
              const SizedBox(height: 8),
              _MenuTile(
              icon: Icons.search_rounded,
              label: 'Хайх',
              onTap: () {
                Navigator.pop(ctx);
                context.push('/search');
              },
            ),
            _MenuTile(
              icon: Icons.receipt_long_outlined,
              label: 'Дэлгүүрийн захиалга',
              onTap: () {
                Navigator.pop(ctx);
                context.push('/shop/orders');
              },
            ),
            _MenuTile(
              icon: Icons.person_outline_rounded,
              label: 'Профайл',
              onTap: () {
                Navigator.pop(ctx);
                context.go('/profile');
              },
            ),
          ],
        ),
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsCountProvider);
    final cartCount = ref.watch(cartCountProvider);
    final top = MediaQuery.of(context).padding.top;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.creamBg.withOpacity(0.94),
        border: Border(
          bottom: BorderSide(color: AppColors.borderSub.withOpacity(0.75)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, top + 10, 16, 14),
        child: Row(
          children: [
            ScaleTap(
              pressedScale: 0.97,
              onTap: () {
                HapticFeedback.lightImpact();
                context.go('/home');
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GevabalLogo(height: 34, glow: false),
                  SizedBox(width: 10),
                  Text(
                    'Gevabal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkDeep,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            NativeHeaderIconButton(
              icon: Icons.notifications_outlined,
              badgeCount: unread > 0 ? unread : null,
              size: 42,
              onTap: () => context.push('/notifications'),
            ),
            const SizedBox(width: 8),
            NativeHeaderIconButton(
              icon: Icons.shopping_bag_outlined,
              badgeCount: cartCount > 0 ? cartCount : null,
              size: 42,
              onTap: () => context.push('/shop/cart'),
            ),
            const SizedBox(width: 8),
            NativeHeaderIconButton(
              icon: Icons.menu_rounded,
              size: 42,
              iconColor: AppColors.inkDeep,
              onTap: () => _openMenu(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.orange, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }
}
