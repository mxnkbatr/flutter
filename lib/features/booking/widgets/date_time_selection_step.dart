import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/booking/providers/booking_draft_provider.dart';
import 'package:sacred_app/features/booking/providers/schedule_slots_provider.dart';
import 'package:sacred_app/features/booking/widgets/month_calendar.dart';
import 'package:sacred_app/features/booking/widgets/time_slot_chip.dart';
import 'package:sacred_app/features/monk_profile/providers/monk_profile_provider.dart';

class DateTimeSelectionStep extends ConsumerStatefulWidget {
  const DateTimeSelectionStep({super.key, required this.monkId});

  final String monkId;

  @override
  ConsumerState<DateTimeSelectionStep> createState() =>
      _DateTimeSelectionStepState();
}

class _DateTimeSelectionStepState extends ConsumerState<DateTimeSelectionStep> {
  DateTime? _focusedMonth;

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final focusedMonth = _focusedMonth ?? draft.date ?? DateTime.now();
    final scheduleAsync = ref.watch(monkScheduleProvider(widget.monkId));
    final dateStr = draft.date != null
        ? DateFormat('yyyy-MM-dd').format(draft.date!)
        : null;
    final slotsAsync = dateStr != null
        ? ref.watch(dayScheduleProvider((
            monkId: widget.monkId,
            date: dateStr,
          )))
        : null;

    return Column(
      children: [
        scheduleAsync.when(
          loading: () => const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (days) => MonthCalendar(
            focusedMonth: focusedMonth,
            availableDays: days,
            selectedDate: draft.date,
            onMonthChanged: (m) => setState(() => _focusedMonth = m),
            onDateSelected: (date) {
              ref.read(bookingDraftProvider.notifier).setDate(date);
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Боломжит цагууд', style: AppText.h3),
                const SizedBox(height: 12),
                if (draft.date == null)
                  const Text(
                    'Эхлээд өдөр сонгоно уу',
                    style: AppText.bodySmall,
                  )
                else if (slotsAsync == null)
                  const SizedBox.shrink()
                else
                  slotsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (_, __) => const Text(
                      'Цаг ачаалахад алдаа гарлаа',
                      style: AppText.bodySmall,
                    ),
                    data: (schedule) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: schedule.slots.map((slot) {
                        final isBooked = schedule.bookedSlots.contains(slot);
                        return TimeSlotChip(
                          time: slot,
                          isSelected: draft.slot == slot,
                          isBooked: isBooked,
                          onTap: isBooked
                              ? null
                              : () => ref
                                  .read(bookingDraftProvider.notifier)
                                  .setSlot(slot),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
