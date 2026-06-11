import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MonkShell extends StatelessWidget {
  const MonkShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _Tab('/monk/dashboard', Icons.dashboard_outlined, Icons.dashboard, 'Самбар'),
    _Tab('/monk/messenger', Icons.chat_outlined, Icons.chat, 'Мессенжер'),
  ];

  int _indexFromLocation(String location) {
    if (location.startsWith('/monk/messenger')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => context.go(_tabs[i].path),
        items: [
          for (final tab in _tabs)
            BottomNavigationBarItem(
              icon: Icon(tab.icon),
              activeIcon: Icon(tab.activeIcon),
              label: tab.label,
            ),
        ],
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
