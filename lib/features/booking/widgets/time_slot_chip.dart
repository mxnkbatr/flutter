import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
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
          gradient: isSelected && !isBooked ? AppGradients.sun : null,
          color: isBooked
              ? AppColors.surface
              : isSelected
                  ? null
                  : AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isBooked
                ? AppColors.border
                : isSelected
                    ? Colors.transparent
                    : AppColors.sunGold.withOpacity(0.35),
            width: isSelected ? 0 : 0.5,
          ),
          boxShadow: isSelected && !isBooked
              ? [
                  BoxShadow(
                    color: AppColors.sunGold.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          time,
          style: AppText.bodySmall.copyWith(
            color: isBooked
                ? AppColors.textHint
                : isSelected
                    ? AppColors.surfaceEl
                    : AppColors.textPri,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            decoration: isBooked ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
