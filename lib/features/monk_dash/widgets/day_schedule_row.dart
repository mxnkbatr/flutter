import 'package:flutter/material.dart';
import 'package:sacred_app/core/utils/app_timezone.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/models/monk_schedule_day.dart';

class DayScheduleRow extends StatelessWidget {
  const DayScheduleRow({
    super.key,
    required this.day,
    required this.onToggle,
    required this.onTimeChange,
  });

  final MonkScheduleDay day;
  final ValueChanged<bool> onToggle;
  final void Function(String start, String end) onTimeChange;

  Future<void> _pickTime(
    BuildContext context,
    String current,
    void Function(String) onSelected,
  ) async {
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 9,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final total = picked.hour * 60 + picked.minute;
      final snapped = ((total + AppTimezone.slotIntervalMinutes ~/ 2) ~/
              AppTimezone.slotIntervalMinutes) *
          AppTimezone.slotIntervalMinutes;
      final hour = (snapped ~/ 60).clamp(0, 23);
      final minute = snapped % 60;
      final formatted =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      onSelected(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Switch(
            value: day.active,
            activeColor: AppColors.goldPrime,
            onChanged: onToggle,
          ),
          SizedBox(
            width: 72,
            child: Text(
              day.name,
              style: AppText.body.copyWith(
                color: day.active ? AppColors.goldPrime : AppColors.textSec,
                fontWeight: day.active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: day.active
                  ? () => _pickTime(context, day.start, (s) {
                        onTimeChange(s, day.end);
                      })
                  : null,
              child: _TimeChip(label: day.start, enabled: day.active),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('—', style: AppText.bodySmall),
          ),
          Expanded(
            child: GestureDetector(
              onTap: day.active
                  ? () => _pickTime(context, day.end, (e) {
                        onTimeChange(day.start, e);
                      })
                  : null,
              child: _TimeChip(label: day.end, enabled: day.active),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: enabled ? AppColors.goldLight : AppColors.borderSub,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: enabled ? AppColors.goldPrime : AppColors.border,
          width: 0.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppText.bodySmall.copyWith(
          color: enabled ? AppColors.inkDeep : AppColors.textHint,
        ),
      ),
    );
  }
}
