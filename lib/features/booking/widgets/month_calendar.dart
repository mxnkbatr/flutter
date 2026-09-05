import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/utils/app_timezone.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_profile/models/day_availability.dart';

const _weekdayLabels = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];
const _monthNames = [
  '1-р сар',
  '2-р сар',
  '3-р сар',
  '4-р сар',
  '5-р сар',
  '6-р сар',
  '7-р сар',
  '8-р сар',
  '9-р сар',
  '10-р сар',
  '11-р сар',
  '12-р сар',
];

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.focusedMonth,
    required this.availableDays,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  final DateTime focusedMonth;
  final List<DayAvailability> availableDays;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DayAvailability? _availabilityFor(DateTime date) {
    for (final day in availableDays) {
      if (_isSameDay(day.date, date)) return day;
    }
    return null;
  }

  bool _isAvailable(DateTime date) {
    final todayDate = AppTimezone.startOfToday();
    if (date.isBefore(todayDate)) return false;
    final avail = _availabilityFor(date);
    if (avail == null) return false;
    return avail.isAvailable && !avail.isBooked;
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final today = AppTimezone.startOfToday();
    final canGoPrev = focusedMonth.year > today.year ||
        (focusedMonth.year == today.year && focusedMonth.month > today.month);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          Row(
            children: [
              _MonthNavBtn(
                icon: Icons.chevron_left_rounded,
                enabled: canGoPrev,
                onTap: () => onMonthChanged(
                  DateTime(focusedMonth.year, focusedMonth.month - 1),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${focusedMonth.year}',
                      style: AppText.caption.copyWith(
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _monthNames[focusedMonth.month - 1],
                      style: AppText.h3.copyWith(
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              _MonthNavBtn(
                icon: Icons.chevron_right_rounded,
                enabled: true,
                onTap: () => onMonthChanged(
                  DateTime(focusedMonth.year, focusedMonth.month + 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final label in _weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: AppText.caption.copyWith(
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (var row = 0; row < rows; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(
                      child: _buildCell(row, col, startWeekday, daysInMonth),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCell(int row, int col, int startWeekday, int daysInMonth) {
    final index = row * 7 + col;
    final dayNum = index - startWeekday + 1;
    if (dayNum < 1 || dayNum > daysInMonth) {
      return const SizedBox(height: 44);
    }

    final date = DateTime(focusedMonth.year, focusedMonth.month, dayNum);
    final available = _isAvailable(date);
    final selected =
        selectedDate != null && _isSameDay(date, selectedDate!);
    final isToday = _isSameDay(date, AppTimezone.startOfToday());
    final isPast = date.isBefore(AppTimezone.startOfToday());

    return GestureDetector(
      onTap: available
          ? () {
              HapticFeedback.selectionClick();
              onDateSelected(date);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.primary : null,
          color: selected
              ? null
              : available
                  ? AppColors.orangeSoft
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? null
              : available
                  ? Border.all(color: AppColors.orange.withValues(alpha: 0.28))
                  : isToday
                      ? Border.all(color: AppColors.border)
                      : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '$dayNum',
          style: AppText.bodySmall.copyWith(
            color: selected
                ? Colors.white
                : isPast
                    ? AppColors.textHint
                    : available
                        ? AppColors.inkDeep
                        : AppColors.textHint,
            fontWeight:
                selected || available || isToday ? FontWeight.w700 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _MonthNavBtn extends StatelessWidget {
  const _MonthNavBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.orangeSoft : AppColors.borderSub,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onTap();
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: enabled ? AppColors.orangeDeep : AppColors.textHint,
            size: 22,
          ),
        ),
      ),
    );
  }
}
