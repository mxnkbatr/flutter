import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
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
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceEl,
          border: Border(
            top: BorderSide(color: AppColors.borderSub, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, bottom > 0 ? 4 : 8),
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
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 44,
              height: 44,
              decoration: selected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.orange,
                        width: 2,
                      ),
                    )
                  : null,
              child: Icon(
                icon,
                size: 22,
                color: selected ? AppColors.orange : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.orange : AppColors.textHint,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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
