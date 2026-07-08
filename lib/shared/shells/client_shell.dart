import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/shared/widgets/app_top_header.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

class ClientShell extends StatelessWidget {
  const ClientShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _Tab('/home', Icons.home_outlined, Icons.home_rounded, 'Нүүр'),
    _Tab('/bookings', Icons.calendar_today_outlined, Icons.calendar_today_rounded, 'Захиалга'),
    _Tab('/shop', Icons.storefront_outlined, Icons.storefront_rounded, 'Дэлгүүр'),
    _Tab('/messenger', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Чат'),
    _Tab('/profile', Icons.person_outline_rounded, Icons.person_rounded, 'Профайл'),
  ];

  int _indexFromLocation(String location) {
    if (location.startsWith('/bookings')) return 1;
    if (location.startsWith('/shop')) return 2;
    if (location.startsWith('/messenger')) return 3;
    if (location.startsWith('/profile') || location.startsWith('/subscription')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      extendBody: true,
      body: Column(
        children: [
          const AppTopHeader(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottom > 0 ? bottom : 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.surfaceEl.withOpacity(0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.borderSub.withOpacity(0.9),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final selected = i == index;
              return _NavItem(
                icon: selected ? tab.activeIcon : tab.icon,
                label: tab.label,
                selected: selected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.go(tab.path);
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      pressedScale: 0.92,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: selected
            ? BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 21,
              color: selected ? Colors.white : AppColors.textHint,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textHint,
                fontSize: 9.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab(this.path, this.icon, this.activeIcon, this.label);
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
