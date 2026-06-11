import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/booking/providers/schedule_slots_provider.dart';
import 'package:sacred_app/features/booking/widgets/time_slot_chip.dart';
import 'package:sacred_app/features/monk_profile/providers/monk_profile_provider.dart';

const _dayLabels = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];

class WeeklyAvailability extends ConsumerStatefulWidget {
  const WeeklyAvailability({super.key, required this.monkId});

  final String monkId;

  @override
  ConsumerState<WeeklyAvailability> createState() =>
      _WeeklyAvailabilityState();
}

class _WeeklyAvailabilityState extends ConsumerState<WeeklyAvailability> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(monkScheduleProvider(widget.monkId));
    final dateStr = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : null;
    final slotsAsync = dateStr != null
        ? ref.watch(dayScheduleProvider((
            monkId: widget.monkId,
            date: dateStr,
          )))
        : null;

    return scheduleAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.goldPrime),
        ),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('Хуваарь ачаалахад алдаа гарлаа', style: AppText.bodySmall),
      ),
      data: (days) {
        final week = days.take(7).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: week.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final day = week[i];
                  final selected = _selectedDate != null &&
                      _sameDay(_selectedDate!, day.date);
                  final enabled = day.isAvailable && !day.isBooked;
                  return _DayChip(
                    label: _dayLabels[day.date.weekday % 7],
                    day: day.date.day,
                    selected: selected,
                    enabled: enabled,
                    booked: day.isBooked,
                    onTap: enabled
                        ? () {
                            HapticFeedback.lightImpact();
                            setState(() => _selectedDate = day.date);
                          }
                        : null,
                  );
                },
              ),
            ),
            if (_selectedDate != null && slotsAsync != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  DateFormat('yyyy оны M сарын d').format(_selectedDate!),
                  style: AppText.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: slotsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.goldPrime,
                      ),
                    ),
                  ),
                  error: (_, __) => const Text(
                    'Цаг ачаалахад алдаа гарлаа',
                    style: AppText.bodySmall,
                  ),
                  data: (schedule) {
                    if (schedule.slots.isEmpty) {
                      return const Text(
                        'Боломжит цаг байхгүй',
                        style: AppText.bodySmall,
                      );
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: schedule.slots.map((slot) {
                        final isBooked = schedule.bookedSlots.contains(slot);
                        return TimeSlotChip(
                          time: slot,
                          isSelected: false,
                          isBooked: isBooked,
                          onTap: isBooked
                              ? null
                              : () {
                                  final date = DateFormat('yyyy-MM-dd')
                                      .format(_selectedDate!);
                                  context.go(
                                    '/booking/${widget.monkId}?date=$date',
                                  );
                                },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.day,
    required this.selected,
    required this.enabled,
    required this.booked,
    this.onTap,
  });

  final String label;
  final int day;
  final bool selected;
  final bool enabled;
  final bool booked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: AppText.caption.copyWith(
              color: selected ? AppColors.goldPrime : AppColors.textSec,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.inkDeep
                  : enabled
                      ? AppColors.goldLight
                      : AppColors.borderSub,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppColors.goldPrime
                    : enabled
                        ? AppColors.goldPrime
                        : AppColors.border,
                width: selected ? 1.5 : 0.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: AppText.bodySmall.copyWith(
                color: selected
                    ? AppColors.goldPrime
                    : booked
                        ? AppColors.textHint
                        : AppColors.textPri,
                decoration: booked ? TextDecoration.lineThrough : null,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
