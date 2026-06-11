import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_profile/models/day_availability.dart';

const _weekdayLabels = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];

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
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (date.isBefore(todayDate)) return false;
    final avail = _availabilityFor(date);
    if (avail == null) {
      return date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday;
    }
    return avail.isAvailable && !avail.isBooked;
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onMonthChanged(
                  DateTime(focusedMonth.year, focusedMonth.month - 1),
                ),
              ),
              Text(
                '${focusedMonth.year}.${focusedMonth.month.toString().padLeft(2, '0')}',
                style: AppText.h3,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onMonthChanged(
                  DateTime(focusedMonth.year, focusedMonth.month + 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final label in _weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(label, style: AppText.caption),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (var row = 0; row < rows; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(child: _buildCell(row, col, startWeekday, daysInMonth)),
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
      return const SizedBox(height: 40);
    }

    final date = DateTime(focusedMonth.year, focusedMonth.month, dayNum);
    final available = _isAvailable(date);
    final selected =
        selectedDate != null && _isSameDay(date, selectedDate!);
    final isPast = date.isBefore(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );

    return GestureDetector(
      onTap: available ? () => onDateSelected(date) : null,
      child: Container(
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.inkDeep
              : available
                  ? AppColors.goldLight
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          '$dayNum',
          style: AppText.bodySmall.copyWith(
            color: selected
                ? AppColors.goldPrime
                : isPast
                    ? AppColors.textHint
                    : available
                        ? AppColors.inkDeep
                        : AppColors.textHint,
            fontWeight: selected || available ? FontWeight.w600 : FontWeight.w400,
            decoration: isPast ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
