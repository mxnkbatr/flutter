import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_schedule_manager_provider.dart';
import 'package:sacred_app/features/monk_dash/widgets/day_schedule_row.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

class ScheduleTab extends ConsumerWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(monkScheduleManagerProvider);
    final isSaving = scheduleAsync.isLoading && scheduleAsync.hasValue;

    return scheduleAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.goldPrime),
      ),
      error: (e, _) => Center(child: Text(formatUserError(e))),
      data: (schedule) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Долоо хоногийн хуваарь', style: AppText.h3),
          const SizedBox(height: 4),
          const Text(
            'Идэвхтэй өдрүүд болон цагуудаа тохируулна уу',
            style: AppText.bodySmall,
          ),
          const SizedBox(height: 20),
          ...schedule.days.map(
            (day) => DayScheduleRow(
              day: day,
              onToggle: (active) => ref
                  .read(monkScheduleManagerProvider.notifier)
                  .toggleDay(day.name, active),
              onTimeChange: (start, end) => ref
                  .read(monkScheduleManagerProvider.notifier)
                  .setHours(day.name, start, end),
            ),
          ),
          const SizedBox(height: 24),
          SacredButton(
            label: 'Хуваарь хадгалах',
            isLoading: isSaving,
            onTap: () =>
                ref.read(monkScheduleManagerProvider.notifier).save(),
          ),
        ],
      ),
    );
  }
}
