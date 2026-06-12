import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';

class DaySchedule {
  const DaySchedule({
    required this.slots,
    required this.bookedSlots,
  });

  final List<String> slots;
  final List<String> bookedSlots;

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    final slots = (json['slots'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (json['availableSlots'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        _defaultSlots();
    final booked = (json['bookedSlots'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (json['alreadyBooked'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    return DaySchedule(slots: slots, bookedSlots: booked);
  }

  static List<String> _defaultSlots() =>
      ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00'];
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
      return DaySchedule.fromJson(raw);
    }
    if (raw is List) {
      for (final item in raw) {
        final map = item as Map<String, dynamic>;
        final date = map['date']?.toString() ?? '';
        if (date.startsWith(query.date)) {
          return DaySchedule.fromJson(map);
        }
      }
    }
    return const DaySchedule(slots: [], bookedSlots: []);
  } catch (_) {
    return const DaySchedule(slots: [], bookedSlots: []);
  }
});
