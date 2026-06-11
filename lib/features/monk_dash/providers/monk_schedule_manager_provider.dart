import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/features/monk_dash/models/monk_schedule_day.dart';

final monkScheduleManagerProvider =
    AsyncNotifierProvider<MonkScheduleManagerNotifier, MonkWeeklySchedule>(
  MonkScheduleManagerNotifier.new,
);

class MonkScheduleManagerNotifier extends AsyncNotifier<MonkWeeklySchedule> {
  @override
  Future<MonkWeeklySchedule> build() async {
    try {
      final res = await ref.read(apiClientProvider).get('/monk/schedule');
      return MonkWeeklySchedule.fromJson(res.data);
    } catch (_) {
      return MonkWeeklySchedule.defaults();
    }
  }

  void toggleDay(String name, bool active) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      MonkWeeklySchedule(
        days: current.days
            .map((d) => d.name == name ? d.copyWith(active: active) : d)
            .toList(),
      ),
    );
  }

  void setHours(String name, String start, String end) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      MonkWeeklySchedule(
        days: current.days
            .map(
              (d) => d.name == name ? d.copyWith(start: start, end: end) : d,
            )
            .toList(),
      ),
    );
  }

  Future<void> save() async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(apiClientProvider).put(
            '/monk/schedule',
            data: current.toJson(),
          );
      return current;
    });
  }
}
