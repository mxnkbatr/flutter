import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';

class ClientShell extends StatelessWidget {
  const ClientShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _Tab('/home', Icons.explore_outlined, Icons.explore_rounded, 'Нүүр'),
    _Tab('/bookings', Icons.calendar_today_outlined, Icons.calendar_today_rounded, 'Захиалга'),
    _Tab('/messenger', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Чат'),
    _Tab('/profile', Icons.person_outline_rounded, Icons.person_rounded, 'Профайл'),
  ];

  int _indexFromLocation(String location) {
    if (location.startsWith('/bookings')) return 1;
    if (location.startsWith('/messenger')) return 2;
    if (location.startsWith('/profile') || location.startsWith('/subscription')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: child,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: const Border(
            top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.sunOrange.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 10, 8, bottom > 0 ? 4 : 10),
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
                    HapticFeedback.lightImpact();
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: selected ? AppColors.saffron : AppColors.textHint,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.saffron : AppColors.textHint,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
