import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/features/monk_dash/models/monk_booking_item.dart';
import 'package:sacred_app/features/monk_dash/models/monk_dashboard_data.dart';

final monkDashboardProvider = FutureProvider<MonkDashboardData>((ref) async {
  final res = await ref.read(apiClientProvider).get('/monk/dashboard');
  final data = res.data as Map<String, dynamic>;
  return MonkDashboardData.fromJson(data);
});

final monkAvailabilityProvider =
    NotifierProvider<MonkAvailabilityNotifier, bool>(
  MonkAvailabilityNotifier.new,
);

class MonkAvailabilityNotifier extends Notifier<bool> {
  @override
  bool build() {
    final dashboard = ref.watch(monkDashboardProvider);
    return dashboard.valueOrNull?.isAvailable ?? true;
  }

  Future<void> toggle(bool value) async {
    final previous = state;
    state = value;
    try {
      await ref.read(apiClientProvider).put(
            '/monk/availability',
            data: {'isAvailable': value},
          );
      ref.invalidate(monkDashboardProvider);
    } catch (_) {
      state = previous;
    }
  }
}

// Ламын бүх захиалга
final monkBookingsProvider = FutureProvider<List<MonkBookingItem>>((ref) async {
  final res = await ref.read(apiClientProvider).get('/bookings');
  final list = res.data is List
      ? res.data as List
      : (res.data as Map<String, dynamic>)['bookings'] as List? ?? [];
  return list
      .map((e) => MonkBookingItem.fromJson(e as Map<String, dynamic>))
      .toList();
});

@Deprecated('Use monkBookingsProvider')
final monkBookingsListProvider = monkBookingsProvider;

Future<void> confirmBooking(WidgetRef ref, String bookingId) async {
  await ref.read(apiClientProvider).put('/bookings/$bookingId/confirm');
  ref.invalidate(monkBookingsProvider);
  ref.invalidate(monkDashboardProvider);
}

Future<void> cancelBooking(WidgetRef ref, String bookingId) async {
  await ref.read(apiClientProvider).put('/bookings/$bookingId/cancel');
  ref.invalidate(monkBookingsProvider);
  ref.invalidate(monkDashboardProvider);
}
