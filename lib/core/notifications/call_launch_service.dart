import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/notifications/local_notification_service.dart';
import 'package:sacred_app/core/router/app_router.dart';
import 'package:sacred_app/core/utils/app_timezone.dart';
import 'package:sacred_app/features/booking/models/client_booking.dart';
import 'package:sacred_app/features/booking/providers/my_bookings_provider.dart';
import 'package:sacred_app/features/monk_dash/models/monk_booking_item.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';
import 'package:sacred_app/features/video_call/providers/incoming_call_provider.dart';

class CallLaunchService {
  static Future<void> handlePendingLaunch(WidgetRef ref) async {
    final pending = await LocalNotificationService.consumePendingLaunch();
    if (pending == null || pending.bookingId.isEmpty) return;

    if (pending.directJoin) {
      _goToCall(ref, pending.bookingId, pending.role);
      return;
    }

    ref.read(incomingCallProvider.notifier).state = IncomingCallState(
      callerName: pending.callerName,
      callerImage: pending.callerImage,
      bookingId: pending.bookingId,
      recipientRole: pending.role,
    );
  }

  static Future<void> checkActiveCallWindow(WidgetRef ref) async {
    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth == null || !auth.isAuthenticated) return;

    final role = auth.role;
    if (role == 'monk') {
      await _checkMonkCallWindow(ref);
    } else if (role == 'client') {
      await _checkClientCallWindow(ref);
    }
  }

  static Future<void> _checkClientCallWindow(WidgetRef ref) async {
    try {
      final bookings = await ref.read(myBookingsProvider.future);
      final active = _findActiveBooking(bookings);
      if (active == null) return;

      _goToCall(ref, active.id, 'client');
    } catch (_) {}
  }

  static Future<void> _checkMonkCallWindow(WidgetRef ref) async {
    try {
      final bookings = await ref.read(monkBookingsProvider.future);
      final active = _findActiveMonkBooking(bookings);
      if (active == null) return;

      ref.read(incomingCallProvider.notifier).state = IncomingCallState(
        callerName: active.clientName,
        callerImage: '',
        bookingId: active.id,
        recipientRole: 'monk',
        isScheduledStart: true,
      );
    } catch (_) {}
  }

  static ClientBooking? _findActiveBooking(List<ClientBooking> bookings) {
    for (final b in bookings) {
      if (!b.canJoinCall) continue;
      if (AppTimezone.isInCallWindow(b.date, b.slot)) return b;
    }
    return null;
  }

  static MonkBookingItem? _findActiveMonkBooking(List<MonkBookingItem> bookings) {
    for (final b in bookings) {
      if (b.status != 'confirmed' || b.paid != true) continue;
      if (AppTimezone.isInCallWindow(b.date, b.slot)) return b;
    }
    return null;
  }

  static void _goToCall(WidgetRef ref, String bookingId, String role) {
    ref.read(incomingCallProvider.notifier).state = null;
    ref.read(appRouterProvider).go('/call/$bookingId?role=$role');
  }

  static void acceptCall(WidgetRef ref, IncomingCallState call) {
    ref.read(incomingCallProvider.notifier).state = null;
    LocalNotificationService.cancelIncomingCall(call.bookingId);
    ref.read(appRouterProvider).go(
          '/call/${call.bookingId}?role=${call.recipientRole}',
        );
  }

  static void declineCall(WidgetRef ref, IncomingCallState call) {
    ref.read(incomingCallProvider.notifier).state = null;
    LocalNotificationService.cancelIncomingCall(call.bookingId);
  }
}
