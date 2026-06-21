import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/utils/app_timezone.dart';
import 'package:sacred_app/features/booking/utils/slot_utils.dart';

class DaySchedule {
  const DaySchedule({
    required this.slots,
    required this.bookedSlots,
    this.pastSlots = const [],
  });

  final List<String> slots;
  final List<String> bookedSlots;
  final List<String> pastSlots;

  factory DaySchedule.fromJson(Map<String, dynamic> json, {String? date}) {
    final slots = (json['slots'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (json['availableSlots'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        DaySchedule.defaultSlots();
    final booked = (json['bookedSlots'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (json['alreadyBooked'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final pastFromApi = (json['pastSlots'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();
    final resolvedDate = date ?? json['date']?.toString() ?? '';
    final past = pastFromApi ??
        (resolvedDate.isNotEmpty
            ? AppTimezone.pastSlotsForDate(resolvedDate, slots)
            : const <String>[]);
    return DaySchedule(slots: slots, bookedSlots: booked, pastSlots: past);
  }

  /// 30-minute slots, 09:00–17:30 (Mon–Fri default window).
  static List<String> defaultSlots() {
    final slots = <String>[];
    for (var m = 9 * 60; m < 18 * 60; m += 30) {
      final h = m ~/ 60;
      final min = m % 60;
      slots.add(
        '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}',
      );
    }
    return slots;
  }

  bool isUnavailable(String slot, String dateStr) => SlotUtils.isUnavailable(
        slot: slot,
        dateStr: dateStr,
        isBooked: bookedSlots.contains(slot),
        pastSlots: pastSlots,
      );
}

DaySchedule _withFallbackSlots(DaySchedule schedule) {
  if (schedule.slots.isNotEmpty) return schedule;
  return DaySchedule(slots: DaySchedule.defaultSlots(), bookedSlots: schedule.bookedSlots);
}

typedef ScheduleQuery = ({String monkId, String date});

final dayScheduleProvider =
    FutureProvider.family<DaySchedule, ScheduleQuery>((ref, query) async {
  try {
    final res = await ref.read(apiClientProvider).get(
          '/monks/${query.monkId}/schedule',
          queryParameters: {'date': query.date},
        );
    final raw = res.data;
    if (raw is Map<String, dynamic>) {
      return _withFallbackSlots(
        DaySchedule.fromJson(raw, date: query.date),
      );
    }
    if (raw is List) {
      for (final item in raw) {
        final map = item as Map<String, dynamic>;
        final date = map['date']?.toString() ?? '';
        if (date.startsWith(query.date)) {
          return _withFallbackSlots(
            DaySchedule.fromJson(map, date: query.date),
          );
        }
      }
    }
    return DaySchedule(slots: DaySchedule.defaultSlots(), bookedSlots: const []);
  } catch (_) {
    return DaySchedule(slots: DaySchedule.defaultSlots(), bookedSlots: const []);
  }
});
