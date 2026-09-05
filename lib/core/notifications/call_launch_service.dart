import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/notifications/call_join_guard.dart';
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
      await tryAutoJoin(
        ref,
        bookingId: pending.bookingId,
        role: _safeRole(ref, pending.role),
        reason: 'pending',
      );
      return;
    }

    if (await CallJoinGuard.isSuppressed(pending.bookingId)) return;

    ref.read(incomingCallProvider.notifier).state = IncomingCallState(
      callerName: pending.callerName,
      callerImage: pending.callerImage,
      bookingId: pending.bookingId,
      recipientRole: _safeRole(ref, pending.role),
    );
  }

  static Future<void> checkActiveCallWindow(WidgetRef ref) async {
    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth == null || !auth.isAuthenticated) return;
    if (_isInAnyCall(ref)) return;
    if (_isOnSensitiveRoute(ref)) return;

    final role = auth.role;
    if (role == 'monk') {
      await _checkMonkCallWindow(ref);
    } else if (role == 'client') {
      await _checkClientCallWindow(ref);
    }
  }

  /// Safe auto-join used by call_time / resume / pending launch.
  static Future<bool> tryAutoJoin(
    WidgetRef ref, {
    required String bookingId,
    required String role,
    String reason = 'auto',
  }) async {
    if (bookingId.isEmpty) return false;
    if (_isAlreadyInCall(ref, bookingId)) return true;
    if (_isInAnyCall(ref)) return false;
    if (_isOnSensitiveRoute(ref)) return false;
    if (await CallJoinGuard.isSuppressed(bookingId)) return false;

    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth == null || !auth.isAuthenticated) return false;

    final safeRole = _safeRole(ref, role);
    if (!_roleAllowsCall(safeRole)) return false;

    _goToCall(ref, bookingId, safeRole);
    return true;
  }

  static Future<void> _checkClientCallWindow(WidgetRef ref) async {
    try {
      final bookings = await ref.read(myBookingsProvider.future);
      final active = _findActiveBooking(bookings);
      if (active == null) return;
      await tryAutoJoin(ref, bookingId: active.id, role: 'client', reason: 'window');
    } catch (_) {}
  }

  static Future<void> _checkMonkCallWindow(WidgetRef ref) async {
    try {
      final bookings = await ref.read(monkBookingsProvider.future);
      final active = _findActiveMonkBooking(bookings);
      if (active == null) return;
      await tryAutoJoin(ref, bookingId: active.id, role: 'monk', reason: 'window');
    } catch (_) {}
  }

  static String _currentPath(WidgetRef ref) {
    try {
      return ref
          .read(appRouterProvider)
          .routerDelegate
          .currentConfiguration
          .uri
          .path;
    } catch (_) {
      return '';
    }
  }

  static bool _isAlreadyInCall(WidgetRef ref, String bookingId) {
    if (bookingId.isEmpty) return false;
    return _currentPath(ref).contains('/call/$bookingId');
  }

  /// Another LiveKit session already open — do not yank the user.
  static bool _isInAnyCall(WidgetRef ref) {
    final path = _currentPath(ref);
    return path.contains('/call/');
  }

  /// Avoid interrupting payment / auth flows.
  static bool _isOnSensitiveRoute(WidgetRef ref) {
    final path = _currentPath(ref);
    return path.contains('/payment') ||
        path.contains('/login') ||
        path.contains('/signup') ||
        path.contains('/splash') ||
        path.contains('/shop/checkout');
  }

  static String _safeRole(WidgetRef ref, String? fromPush) {
    final authRole = ref.read(authStateProvider).valueOrNull?.role;
    if (authRole == 'monk' || authRole == 'client' || authRole == 'admin') {
      // Admin joining as observer still uses query role if provided.
      if (authRole == 'admin' && (fromPush == 'monk' || fromPush == 'client')) {
        return fromPush!;
      }
      if (authRole == 'monk' || authRole == 'client') return authRole!;
    }
    if (fromPush == 'monk' || fromPush == 'client') return fromPush!;
    return 'client';
  }

  static bool _roleAllowsCall(String role) =>
      role == 'client' || role == 'monk' || role == 'admin';

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
    if (_isAlreadyInCall(ref, bookingId)) return;
    ref.read(incomingCallProvider.notifier).state = null;
    LocalNotificationService.cancelIncomingCall(bookingId);
    ref.read(appRouterProvider).go('/call/$bookingId?role=$role');
  }

  static Future<void> acceptCall(WidgetRef ref, IncomingCallState call) async {
    await CallJoinGuard.clear(call.bookingId);
    ref.read(incomingCallProvider.notifier).state = null;
    LocalNotificationService.cancelIncomingCall(call.bookingId);
    ref.read(appRouterProvider).go(
          '/call/${call.bookingId}?role=${_safeRole(ref, call.recipientRole)}',
        );
  }

  static Future<void> declineCall(WidgetRef ref, IncomingCallState call) async {
    await CallJoinGuard.suppress(call.bookingId);
    ref.read(incomingCallProvider.notifier).state = null;
    LocalNotificationService.cancelIncomingCall(call.bookingId);
  }

  /// User left the room on purpose — do not auto-reopen until they accept again.
  static Future<void> markLeftCall(String bookingId) async {
    await CallJoinGuard.suppress(bookingId);
  }
}
