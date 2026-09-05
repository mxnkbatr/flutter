import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';

/// Large, easy-to-tap time slot.
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
    final enabled = !isBooked && onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onTap!();
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          decoration: BoxDecoration(
            gradient: isSelected && enabled ? AppGradients.primary : null,
            color: isBooked
                ? AppColors.borderSub
                : isSelected
                    ? null
                    : AppColors.surfaceEl,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isBooked
                  ? AppColors.border
                  : isSelected
                      ? Colors.transparent
                      : AppColors.border,
              width: 1.2,
            ),
            boxShadow: isSelected && enabled
                ? [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            time,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: isBooked
                  ? AppColors.textHint
                  : isSelected
                      ? Colors.white
                      : AppColors.inkDeep,
              decoration: isBooked ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }
}
