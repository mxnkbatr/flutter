import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';

class ClientShell extends StatelessWidget {
  const ClientShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _Tab('/home', Icons.home_outlined, Icons.home_rounded, 'Нүүр'),
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

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          backgroundColor: AppColors.surfaceEl,
          selectedItemColor: AppColors.sunGold,
          unselectedItemColor: AppColors.textSec,
          elevation: 0,
          onTap: (i) => context.go(_tabs[i].path),
          items: [
            for (var i = 0; i < _tabs.length; i++)
              BottomNavigationBarItem(
                icon: Icon(_tabs[i].icon),
                activeIcon: _GradientNavIcon(icon: _tabs[i].activeIcon),
                label: _tabs[i].label,
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

class _GradientNavIcon extends StatelessWidget {
  const _GradientNavIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppGradients.sun.createShader(bounds),
      child: Icon(icon, color: AppColors.surfaceEl),
    );
  }
}
