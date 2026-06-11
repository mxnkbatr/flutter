import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/admin/monks')) return 1;
    if (loc.startsWith('/admin/users')) return 2;
    if (loc.startsWith('/admin/bookings')) return 3;
    if (loc.startsWith('/admin/finance')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int i) {
    const routes = [
      '/admin/dashboard',
      '/admin/monks',
      '/admin/users',
      '/admin/bookings',
      '/admin/finance',
    ];
    context.go(routes[i]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.inkDeep,
          border: Border(top: BorderSide(color: AppColors.inkLight, width: 0.5)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.inkDeep,
          selectedItemColor: AppColors.goldPrime,
          unselectedItemColor: AppColors.goldMuted,
          selectedLabelStyle: AppText.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppText.caption,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          currentIndex: _selectedIndex(context),
          onTap: (i) => _onTap(context, i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Самбар',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement_outlined),
              label: 'Лам нар',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              label: 'Хэрэглэгч',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              label: 'Захиалга',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Санхүү',
            ),
          ],
        ),
      ),
    );
  }
}
