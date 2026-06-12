import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/features/monk_profile/models/day_availability.dart';
import 'package:sacred_app/features/monk_profile/models/monk_review.dart';
import 'package:sacred_app/features/monk_profile/models/monk_service.dart';

part 'monk_profile_provider.g.dart';

@riverpod
Future<Monk> monkDetail(MonkDetailRef ref, String monkId) async {
  final res = await ref.read(apiClientProvider).get('/monks/$monkId');
  final raw = res.data as Map<String, dynamic>;
  final data = raw.containsKey('monk')
      ? raw['monk'] as Map<String, dynamic>
      : raw;
  return Monk.fromJson(data);
}

@riverpod
Future<List<MonkService>> monkServices(MonkServicesRef ref, String monkId) async {
  final res = await ref.read(apiClientProvider).get('/monks/$monkId/services');
  final list = res.data is List
      ? res.data as List
      : (res.data as Map<String, dynamic>)['services'] as List? ?? [];
  return list
      .map((e) => MonkService.fromJson(e as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<List<DayAvailability>> monkSchedule(
  MonkScheduleRef ref,
  String monkId,
) async {
  final res = await ref.read(apiClientProvider).get('/monks/$monkId/schedule');
  final list = res.data is List
      ? res.data as List
      : (res.data as Map<String, dynamic>)['days'] as List? ??
          (res.data as Map<String, dynamic>)['schedule'] as List? ??
          [];
  if (list.isEmpty) {
    return _defaultWeek();
  }
  return list
      .map((e) => DayAvailability.fromJson(e as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<List<MonkReview>> monkReviews(MonkReviewsRef ref, String monkId) async {
  try {
    final res = await ref.read(apiClientProvider).get('/monks/$monkId/reviews');
    final list = res.data is List
        ? res.data as List
        : (res.data as Map<String, dynamic>)['reviews'] as List? ?? [];
    return list
        .map((e) => MonkReview.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

List<DayAvailability> _defaultWeek() {
  final now = DateTime.now();
  return List.generate(7, (i) {
    final date = DateTime(now.year, now.month, now.day + i);
    final isWeekend = date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;
    return DayAvailability(
      date: date,
      isAvailable: !isWeekend,
      isBooked: false,
      slotCount: isWeekend ? 0 : 6,
    );
  });
}
