import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class TimeSlotChip extends StatelessWidget {
  const TimeSlotChip({
    super.key,
    required this.time,
    required this.isSelected,
    required this.isBooked,
    required this.onTap,
  });

  final String time;
  final bool isSelected;
  final bool isBooked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBooked
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap?.call();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 40,
        decoration: BoxDecoration(
          color: isBooked
              ? AppColors.surface
              : isSelected
                  ? AppColors.inkDeep
                  : AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isBooked
                ? AppColors.border
                : isSelected
                    ? AppColors.goldPrime
                    : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          time,
          style: AppText.bodySmall.copyWith(
            color: isBooked
                ? AppColors.textHint
                : isSelected
                    ? AppColors.goldPrime
                    : AppColors.textPri,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            decoration: isBooked ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
