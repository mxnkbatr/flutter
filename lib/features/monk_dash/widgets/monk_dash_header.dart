import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';

class MonkDashHeader extends ConsumerWidget {
  const MonkDashHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final dashboard = ref.watch(monkDashboardProvider).valueOrNull;
    final name = dashboard?.monkName ?? auth?.userName ?? '';

    return Container(
      color: AppColors.inkDeep,
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Text(
        'Сайн байна уу, $name',
        style: AppText.body.copyWith(color: AppColors.goldMuted),
      ),
    );
  }
}
