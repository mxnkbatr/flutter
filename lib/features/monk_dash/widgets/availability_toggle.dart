import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';

class AvailabilityToggle extends ConsumerWidget {
  const AvailabilityToggle({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = ref.watch(monkAvailabilityProvider);

    final label = isAvailable ? 'Онлайн' : 'Офлайн';
    final labelColor = isAvailable ? AppColors.success : AppColors.textHint;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isAvailable
              ? AppColors.success.withOpacity(0.1)
              : AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAvailable
                ? AppColors.success.withOpacity(0.35)
                : AppColors.borderSub,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isAvailable ? AppColors.success : AppColors.textHint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppText.caption.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Transform.scale(
              scale: 0.82,
              child: Switch(
                value: isAvailable,
                activeColor: AppColors.orange,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (v) =>
                    ref.read(monkAvailabilityProvider.notifier).toggle(v),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: MinimalStyle.card(radius: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppText.bodySmall.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: isAvailable,
            activeColor: AppColors.orange,
            onChanged: (v) =>
                ref.read(monkAvailabilityProvider.notifier).toggle(v),
          ),
        ],
      ),
    );
  }
}
