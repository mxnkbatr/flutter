import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

class MonkShell extends StatelessWidget {
  const MonkShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _Tab('/monk/calls', Icons.work_outline_rounded, Icons.work_rounded, 'Ажил'),
    _Tab('/monk/messenger', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Чат'),
    _Tab('/monk/dashboard', Icons.tune_rounded, Icons.tune_rounded, 'Тохиргоо'),
  ];

  int _indexFromLocation(String location) {
    if (location.startsWith('/monk/messenger')) return 1;
    if (location.startsWith('/monk/dashboard')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);
    final bottom = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!location.startsWith('/monk/calls')) {
          context.go('/monk/calls');
          return;
        }
        if (context.canPop()) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.creamBg,
        extendBody: true,
        body: child,
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottom > 0 ? bottom : 12),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.surfaceEl.withOpacity(0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.borderSub.withOpacity(0.85)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.1),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                return _NavItem(
                  icon: i == index ? tab.activeIcon : tab.icon,
                  label: tab.label,
                  selected: i == index,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    // Тохиргоо → профайл tab (хуваарь/орлого тэндээс)
                    if (tab.path == '/monk/dashboard') {
                      context.go('/monk/dashboard?tab=4');
                    } else {
                      context.go(tab.path);
                    }
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 88,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: selected
            ? BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 21,
              color: selected ? Colors.white : AppColors.textHint,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppText.caption.copyWith(
                color: selected ? Colors.white : AppColors.textHint,
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
