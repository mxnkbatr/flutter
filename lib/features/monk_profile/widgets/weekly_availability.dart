import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/utils/app_timezone.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/booking/providers/schedule_slots_provider.dart';
import 'package:sacred_app/features/booking/widgets/time_slot_chip.dart';
import 'package:sacred_app/features/monk_profile/models/day_availability.dart';
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
  String? _selectedSlot;
  bool _autoSelected = false;

  void _bookSlot(String slot) {
    if (_selectedDate == null) return;
    final date = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final encodedSlot = Uri.encodeComponent(slot);
    context.go('/booking/${widget.monkId}?date=$date&slot=$encodedSlot');
  }

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
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.sunGold),
        ),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('Хуваарь ачаалахад алдаа гарлаа', style: AppText.bodySmall),
      ),
      data: (days) {
        if (!_autoSelected && _selectedDate == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _autoSelected || _selectedDate != null) return;
            for (final day in days.take(14)) {
              if (day.isAvailable && !day.isBooked) {
                setState(() {
                  _autoSelected = true;
                  _selectedDate = day.date;
                });
                break;
              }
            }
          });
        }
        final week = days.take(14).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Өдөр сонгоод боломжит цагаа захиалаарай',
                style: AppText.bodySmall.copyWith(color: AppColors.textSec),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: week.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final day = week[i];
                  final selected = _selectedDate != null &&
                      _sameDay(_selectedDate!, day.date);
                  final enabled = day.isAvailable && !day.isBooked;
                  return _DayChip(
                    label: _dayLabels[day.date.weekday % 7],
                    day: day.date.day,
                    month: day.date.month,
                    selected: selected,
                    enabled: enabled,
                    booked: day.isBooked,
                    slotCount: day.slotCount,
                    onTap: enabled
                        ? () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedDate = day.date;
                              _selectedSlot = null;
                            });
                          }
                        : null,
                  );
                },
              ),
            ),
            if (_selectedDate != null && slotsAsync != null) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      DateFormat('yyyy оны M сарын d').format(_selectedDate!),
                      style: AppText.h3.copyWith(fontSize: 16),
                    ),
                    const Spacer(),
                    slotsAsync.when(
                      data: (s) => Text(
                        '${s.slots.where((slot) => !s.isUnavailable(slot, dateStr!)).length} цаг боломжтой',
                        style: AppText.caption.copyWith(
                          color: AppColors.sunGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: slotsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.sunGold,
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
                        'Энэ өдөр боломжит цаг байхгүй',
                        style: AppText.bodySmall,
                      );
                    }
                    final dateKey = dateStr!;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: schedule.slots.map((slot) {
                        final unavailable =
                            schedule.isUnavailable(slot, dateKey);
                        final isSelected = _selectedSlot == slot;
                        return TimeSlotChip(
                          time: slot,
                          isSelected: isSelected,
                          isBooked: unavailable,
                          onTap: unavailable
                              ? null
                              : () {
                                  setState(() => _selectedSlot = slot);
                                  _bookSlot(slot);
                                },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 8),
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
    required this.month,
    required this.selected,
    required this.enabled,
    required this.booked,
    this.slotCount = 0,
    this.onTap,
  });

  final String label;
  final int day;
  final int month;
  final bool selected;
  final bool enabled;
  final bool booked;
  final int slotCount;
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
              color: selected ? AppColors.sunGold : AppColors.textSec,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 58,
            decoration: BoxDecoration(
              gradient: selected ? AppGradients.sun : null,
              color: selected
                  ? null
                  : enabled
                      ? AppColors.sunLight
                      : AppColors.borderSub,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : enabled
                        ? AppColors.sunGold.withOpacity(0.4)
                        : AppColors.border,
                width: selected ? 0 : 0.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.sunGold.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: AppText.body.copyWith(
                    color: selected
                        ? AppColors.surfaceEl
                        : booked
                            ? AppColors.textHint
                            : AppColors.textPri,
                    decoration: booked ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                if (enabled && slotCount > 0)
                  Text(
                    '$slotCount цаг',
                    style: AppText.caption.copyWith(
                      fontSize: 9,
                      color: selected
                          ? AppColors.surfaceEl.withOpacity(0.9)
                          : AppColors.sunMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
