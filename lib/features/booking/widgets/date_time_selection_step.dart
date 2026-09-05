import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/app_timezone.dart';
import 'package:sacred_app/features/booking/providers/booking_draft_provider.dart';
import 'package:sacred_app/features/booking/providers/schedule_slots_provider.dart';
import 'package:sacred_app/features/booking/widgets/month_calendar.dart';
import 'package:sacred_app/features/booking/widgets/time_slot_chip.dart';
import 'package:sacred_app/features/monk_profile/models/day_availability.dart';
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
  final _slotsAnchorKey = GlobalKey();
  bool _didAutoPickDay = false;

  void _selectDate(DateTime date) {
    HapticFeedback.lightImpact();
    ref.read(bookingDraftProvider.notifier).setDate(date);
    ref.read(bookingDateConfirmedProvider.notifier).state = true;
    setState(() => _focusedMonth = DateTime(date.year, date.month));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _slotsAnchorKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: 0.08,
        );
      }
    });
  }

  void _maybeAutoPickDay(List<DayAvailability> days) {
    if (_didAutoPickDay) return;
    final draft = ref.read(bookingDraftProvider);
    if (draft.date != null) {
      _didAutoPickDay = true;
      return;
    }
    DayAvailability? next;
    for (final d in days) {
      if (d.isAvailable && !d.isBooked) {
        next = d;
        break;
      }
    }
    if (next == null) return;
    _didAutoPickDay = true;
    final pick = next;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(bookingDraftProvider).date != null) return;
      _selectDate(pick.date);
    });
  }

  String _friendlyDate(DateTime date) {
    final today = AppTimezone.startOfToday();
    final tomorrow = today.add(const Duration(days: 1));
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Өнөөдөр';
    }
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Маргааш';
    }
    return DateFormat('M сарын d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final focusedMonth = _focusedMonth ?? draft.date ?? AppTimezone.now();
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

    final step = draft.date == null
        ? 0
        : draft.slot == null
            ? 1
            : 2;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        MediaQuery.of(context).padding.bottom + 120,
      ),
      children: [
        _GuideBanner(step: step),
        const SizedBox(height: 14),
        _SectionLabel(
          number: '1',
          title: 'Өдөр сонгоно уу',
          done: draft.date != null,
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceEl,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderSub),
            boxShadow: AppGradients.softCardShadow,
          ),
          child: scheduleAsync.when(
            loading: () => const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.orange),
              ),
            ),
            error: (e, _) => SizedBox(
              height: 300,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Хуанли ачаалж чадсангүй',
                        style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Дахин оролдоно уу',
                        style: AppText.caption.copyWith(color: AppColors.textSec),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () =>
                            ref.invalidate(monkScheduleProvider(widget.monkId)),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Дахин ачаалах'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (days) {
              _maybeAutoPickDay(days);
              return MonthCalendar(
                focusedMonth: focusedMonth,
                availableDays: days,
                selectedDate: draft.date,
                onMonthChanged: (m) => setState(() => _focusedMonth = m),
                onDateSelected: _selectDate,
              );
            },
          ),
        ),
        const SizedBox(height: 22),
        _SectionLabel(
          key: _slotsAnchorKey,
          number: '2',
          title: 'Цаг сонгоно уу',
          done: draft.slot != null,
        ),
        const SizedBox(height: 10),
        if (draft.date == null)
          const _EmptyHint(
            icon: Icons.touch_app_rounded,
            text: 'Дээрх хуанлиас өдөр сонгоод цагаа харна уу',
          )
        else if (slotsAsync == null)
          const SizedBox.shrink()
        else
          slotsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.orange),
              ),
            ),
            error: (_, __) => const _EmptyHint(
              icon: Icons.error_outline_rounded,
              text: 'Цаг ачаалахад алдаа гарлаа. Дахин оролдоно уу.',
            ),
            data: (schedule) {
              final dateKey = dateStr!;
              final available = schedule.slots
                  .where((s) => !schedule.isUnavailable(s, dateKey))
                  .toList();
              if (available.isEmpty) {
                return const _EmptyHint(
                  icon: Icons.event_busy_rounded,
                  text: 'Энэ өдөр сул цаг байхгүй.\nӨөр өдөр сонгоно уу.',
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${_friendlyDate(draft.date!)} — ${available.length} цаг боломжтой',
                    style: AppText.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSec,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: available.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.1,
                    ),
                    itemBuilder: (_, i) {
                      final slot = available[i];
                      return TimeSlotChip(
                        time: slot,
                        isSelected: draft.slot == slot,
                        isBooked: false,
                        onTap: () {
                          ref
                              .read(bookingDraftProvider.notifier)
                              .setSlot(slot);
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        if (draft.date != null && draft.slot != null) ...[
          const SizedBox(height: 20),
          _SelectionSummary(
            dateLabel: _friendlyDate(draft.date!),
            fullDate: DateFormat('yyyy.MM.dd').format(draft.date!),
            slot: draft.slot!,
          ),
        ],
      ],
    );
  }
}

class _GuideBanner extends StatelessWidget {
  const _GuideBanner({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final text = switch (step) {
      0 => 'Өдөр сонгоод, дараа нь цагаа сонгоно уу',
      1 => 'Одоо доороос цагаа сонгоно уу',
      _ => 'Боллоо — доорх товчоор төлбөр төлнө',
    };
    final icon = switch (step) {
      0 => Icons.calendar_month_rounded,
      1 => Icons.schedule_rounded,
      _ => Icons.check_circle_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppGradients.cardSunrise,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSub),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.orangeSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.orangeDeep, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppText.bodySmall.copyWith(
                color: AppColors.inkDeep,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    super.key,
    required this.number,
    required this.title,
    required this.done,
  });

  final String number;
  final String title;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: done ? AppGradients.primary : null,
            color: done ? null : AppColors.orangeSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: done
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : Text(
                  number,
                  style: AppText.caption.copyWith(
                    color: AppColors.orangeDeep,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppText.h3.copyWith(
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceEl,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSub),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.orange.withValues(alpha: 0.75), size: 34),
          const SizedBox(height: 10),
          Text(
            text,
            style: AppText.bodySmall.copyWith(
              color: AppColors.textSec,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({
    required this.dateLabel,
    required this.fullDate,
    required this.slot,
  });

  final String dateLabel;
  final String fullDate;
  final String slot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.orangeSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Таны сонголт',
                  style: AppText.caption.copyWith(
                    color: AppColors.orangeDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateLabel · $slot',
                  style: AppText.h3.copyWith(fontSize: 16),
                ),
                Text(
                  fullDate,
                  style: AppText.caption.copyWith(color: AppColors.textSec),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
