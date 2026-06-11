import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_profile/models/day_availability.dart';

const _dayLabels = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];

class AvailabilityPreview extends StatelessWidget {
  const AvailabilityPreview({
    super.key,
    required this.days,
    required this.monkId,
  });

  final List<DayAvailability> days;
  final String monkId;

  @override
  Widget build(BuildContext context) {
    final displayDays = days.take(7).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < displayDays.length; i++)
          _DayChip(
            label: _dayLabels[displayDays[i].date.weekday % 7],
            day: displayDays[i],
            onTap: displayDays[i].isAvailable && !displayDays[i].isBooked
                ? () {
                    final date = DateFormat('yyyy-MM-dd').format(displayDays[i].date);
                    context.go('/booking/$monkId?date=$date');
                  }
                : null,
          ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.day,
    this.onTap,
  });

  final String label;
  final DayAvailability day;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isAvailable = day.isAvailable && !day.isBooked;
    final isBooked = day.isBooked;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(label, style: AppText.caption),
          const SizedBox(height: 6),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppColors.goldLight
                  : isBooked
                      ? AppColors.inkLight.withOpacity(0.15)
                      : AppColors.borderSub,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isAvailable ? AppColors.goldPrime : AppColors.border,
                width: isAvailable ? 1.5 : 0.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.date.day}',
              style: AppText.bodySmall.copyWith(
                color: isBooked ? AppColors.textHint : AppColors.textPri,
                decoration: isBooked ? TextDecoration.lineThrough : null,
                fontWeight: isAvailable ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
