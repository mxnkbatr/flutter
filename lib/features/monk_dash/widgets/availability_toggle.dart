import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';

class AvailabilityToggle extends ConsumerWidget {
  const AvailabilityToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = ref.watch(monkAvailabilityProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isAvailable ? 'Онлайн' : 'Офлайн',
          style: AppText.caption.copyWith(color: AppColors.goldMuted),
        ),
        const SizedBox(width: 6),
        Switch(
          value: isAvailable,
          activeColor: AppColors.goldPrime,
          onChanged: (v) =>
              ref.read(monkAvailabilityProvider.notifier).toggle(v),
        ),
      ],
    );
  }
}
