import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/widgets/admin_logout_button.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/admin/monks')) return 1;
    if (loc.startsWith('/admin/users')) return 2;
    if (loc.startsWith('/admin/bookings')) return 3;
    if (loc.startsWith('/admin/finance')) return 4;
    if (loc.startsWith('/admin/products')) return 5;
    return 0;
  }

  void _onTap(BuildContext context, int i) {
    const routes = [
      '/admin/dashboard',
      '/admin/monks',
      '/admin/users',
      '/admin/bookings',
      '/admin/finance',
      '/admin/products',
    ];
    context.go(routes[i]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = _selectedIndex(context);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
              child: Row(
                children: [
                  Text('Gevabal Admin', style: AppText.caption),
                  const Spacer(),
                  const AdminLogoutButton(compact: true),
                ],
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, bottom > 0 ? bottom : 10),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceEl.withOpacity(0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderSub),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(6, (i) {
              final selected = i == index;
              final icons = [
                Icons.dashboard_outlined,
                Icons.self_improvement_outlined,
                Icons.people_outline,
                Icons.calendar_today_outlined,
                Icons.account_balance_wallet_outlined,
                Icons.storefront_outlined,
              ];
              final activeIcons = [
                Icons.dashboard_rounded,
                Icons.self_improvement,
                Icons.people_rounded,
                Icons.calendar_today_rounded,
                Icons.account_balance_wallet_rounded,
                Icons.storefront_rounded,
              ];
              return ScaleTap(
                pressedScale: 0.92,
                onTap: () => _onTap(context, i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: selected
                      ? BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(16),
                        )
                      : null,
                  child: Icon(
                    selected ? activeIcons[i] : icons[i],
                    size: 22,
                    color: selected ? Colors.white : AppColors.textHint,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
