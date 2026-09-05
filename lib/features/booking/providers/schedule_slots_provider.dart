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
        const <String>[];
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
    // Always re-check on client so device/API timezone drift cannot re-open past slots.
    final past = <String>{
      ...?pastFromApi,
      if (resolvedDate.isNotEmpty)
        ...AppTimezone.pastSlotsForDate(resolvedDate, slots),
    }.toList();
    return DaySchedule(slots: slots, bookedSlots: booked, pastSlots: past);
  }

  bool isUnavailable(String slot, String dateStr) => SlotUtils.isUnavailable(
        slot: slot,
        dateStr: dateStr,
        isBooked: bookedSlots.contains(slot),
        pastSlots: pastSlots,
      );
}

typedef ScheduleQuery = ({String monkId, String date});

final dayScheduleProvider =
    FutureProvider.family<DaySchedule, ScheduleQuery>((ref, query) async {
  final res = await ref.read(apiClientProvider).get(
        '/monks/${query.monkId}/schedule',
        queryParameters: {'date': query.date},
      );
  final raw = res.data;
  if (raw is Map<String, dynamic>) {
    return DaySchedule.fromJson(raw, date: query.date);
  }
  if (raw is List) {
    for (final item in raw) {
      final map = item as Map<String, dynamic>;
      final date = map['date']?.toString() ?? '';
      if (date.startsWith(query.date)) {
        return DaySchedule.fromJson(map, date: query.date);
      }
    }
  }
  return const DaySchedule(slots: [], bookedSlots: []);
});
