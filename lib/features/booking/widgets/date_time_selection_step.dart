import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: AppColors.surfaceEl,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: scheduleAsync.when(
            loading: () => const SizedBox(
              height: 280,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.sunGold),
              ),
            ),
            error: (_, __) => MonthCalendar(
              focusedMonth: focusedMonth,
              availableDays: const [],
              selectedDate: draft.date,
              onMonthChanged: (m) => setState(() => _focusedMonth = m),
              onDateSelected: (date) {
                HapticFeedback.lightImpact();
                ref.read(bookingDraftProvider.notifier).setDate(date);
              },
            ),
            data: (days) => MonthCalendar(
              focusedMonth: focusedMonth,
              availableDays: days,
              selectedDate: draft.date,
              onMonthChanged: (m) => setState(() => _focusedMonth = m),
              onDateSelected: (date) {
                HapticFeedback.lightImpact();
                ref.read(bookingDraftProvider.notifier).setDate(date);
              },
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (draft.date != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppGradients.sunSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.sunGold.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'Сонгосон: ${DateFormat('yyyy оны M сарын d').format(draft.date!)}',
                      style: AppText.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Боломжит цагууд', style: AppText.h3),
                    const Spacer(),
                    if (draft.slot != null)
                      Text(
                        draft.slot!,
                        style: AppText.bodySmall.copyWith(
                          color: AppColors.sunGold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (draft.date == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceEl,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.sunGold.withOpacity(0.7),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Эхлээд дээрх хуанлиас өдөр сонгоно уу',
                          style: AppText.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else if (slotsAsync == null)
                  const SizedBox.shrink()
                else
                  slotsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
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
                      final available = schedule.slots
                          .where((s) => !schedule.bookedSlots.contains(s))
                          .toList();
                      if (available.isEmpty) {
                        return const Text(
                          'Энэ өдөр боломжит цаг байхгүй. Өөр өдөр сонгоно уу.',
                          style: AppText.bodySmall,
                        );
                      }
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: schedule.slots.map((slot) {
                          final isBooked = schedule.bookedSlots.contains(slot);
                          return TimeSlotChip(
                            time: slot,
                            isSelected: draft.slot == slot,
                            isBooked: isBooked,
                            onTap: isBooked
                                ? null
                                : () {
                                    HapticFeedback.lightImpact();
                                    ref
                                        .read(bookingDraftProvider.notifier)
                                        .setSlot(slot);
                                  },
                          );
                        }).toList(),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
