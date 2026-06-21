import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/booking/providers/schedule_slots_provider.dart';
import 'package:sacred_app/features/booking/widgets/time_slot_chip.dart';
import 'package:sacred_app/features/monk_profile/providers/monk_profile_provider.dart';

class ScheduleAccordion extends ConsumerStatefulWidget {
  const ScheduleAccordion({super.key, required this.monkId});

  final String monkId;

  @override
  ConsumerState<ScheduleAccordion> createState() => _ScheduleAccordionState();
}

class _ScheduleAccordionState extends ConsumerState<ScheduleAccordion> {
  int? _expandedIndex;

  void _bookSlot(DateTime date, String slot) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final encodedSlot = Uri.encodeComponent(slot);
    context.go('/booking/${widget.monkId}?date=$dateStr&slot=$encodedSlot');
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(monkScheduleProvider(widget.monkId));

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
        final available = days
            .where((d) => d.isAvailable && !d.isBooked)
            .take(7)
            .toList();

        if (available.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Ойрын хугацаанд боломжит цаг байхгүй',
              style: AppText.bodySmall,
            ),
          );
        }

        if (_expandedIndex == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _expandedIndex == null) {
              setState(() => _expandedIndex = 0);
            }
          });
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: List.generate(available.length, (i) {
              final day = available[i];
              final expanded = _expandedIndex == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DayAccordionTile(
                  date: day.date,
                  slotCount: day.slotCount,
                  expanded: expanded,
                  monkId: widget.monkId,
                  onToggle: () {
                    HapticFeedback.lightImpact();
                    setState(() => _expandedIndex = expanded ? null : i);
                  },
                  onBook: (slot) => _bookSlot(day.date, slot),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _DayAccordionTile extends ConsumerWidget {
  const _DayAccordionTile({
    required this.date,
    required this.slotCount,
    required this.expanded,
    required this.monkId,
    required this.onToggle,
    required this.onBook,
  });

  final DateTime date;
  final int slotCount;
  final bool expanded;
  final String monkId;
  final VoidCallback onToggle;
  final void Function(String slot) onBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final slotsAsync = expanded
        ? ref.watch(dayScheduleProvider((monkId: monkId, date: dateStr)))
        : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: AppColors.surfaceEl,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: expanded ? AppColors.sunGold.withOpacity(0.4) : AppColors.border,
        ),
        boxShadow: expanded
            ? [
                BoxShadow(
                  color: AppColors.sunGold.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: expanded ? AppGradients.sunSoft : null,
                      color: expanded ? null : AppColors.sunLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('MMM').format(date),
                          style: AppText.caption.copyWith(fontSize: 10),
                        ),
                        Text(
                          '${date.day}',
                          style: AppText.h3.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(date),
                          style: AppText.body.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '$slotCount цаг боломжтой',
                          style: AppText.caption.copyWith(color: AppColors.sunGold),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSec,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded && slotsAsync != null)
            slotsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.sunGold),
                ),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 16),
                child: Text('Цаг ачаалахад алдаа гарлаа', style: AppText.bodySmall),
              ),
              data: (schedule) {
                if (schedule.slots.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(14, 0, 14, 16),
                    child: Text(
                      'Энэ өдөр боломжит цаг байхгүй',
                      style: AppText.bodySmall,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 14),
                      Text('Боломжит цагууд', style: AppText.bodySmall),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: schedule.slots.map((slot) {
                          final unavailable =
                              schedule.isUnavailable(slot, dateStr);
                          return TimeSlotChip(
                            time: slot,
                            isSelected: false,
                            isBooked: unavailable,
                            onTap: unavailable ? null : () => onBook(slot),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
