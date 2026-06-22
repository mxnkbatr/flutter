import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';

class MonkDashHeader extends ConsumerWidget {
  const MonkDashHeader({super.key, this.trailing});

  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final dashboard = ref.watch(monkDashboardProvider).valueOrNull;
    final name = dashboard?.monkName ?? auth?.userName ?? 'Лам';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'Л';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.orangePeach,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSub),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.saffronDeep,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сайн байна уу',
                  style: AppText.caption.copyWith(color: AppColors.textSec),
                ),
                Text(
                  name,
                  style: AppText.h3.copyWith(
                    color: AppColors.inkDeep,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
