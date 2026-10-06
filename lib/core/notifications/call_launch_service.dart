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
import 'package:sacred_app/features/video_call/providers/call_session_lock_provider.dart';
import 'package:sacred_app/features/video_call/providers/incoming_call_provider.dart';

class CallLaunchService {
  /// Slot цонх эхэлсэн үед түгжих эсэх (chat/window/call_time).
  static bool _shouldLockForReason(String reason) {
    return reason == 'window' ||
        reason == 'chat_slot' ||
        reason == 'chat_banner' ||
        reason == 'push' ||
        reason == 'call_time' ||
        reason == 'pending';
  }

  static Future<void> handlePendingLaunch(WidgetRef ref) async {
    final pending = await LocalNotificationService.consumePendingLaunch();
    if (pending == null || pending.bookingId.isEmpty) return;

    if (pending.directJoin) {
      await tryAutoJoin(
        ref,
        bookingId: pending.bookingId,
        role: _safeRole(ref, pending.role),
        reason: 'pending',
        userInitiated: true,
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
  /// [userInitiated] — мэдэгдэл дээр дарсан: "гарсан" хаалтыг үл тооно.
  static Future<bool> tryAutoJoin(
    WidgetRef ref, {
    required String bookingId,
    required String role,
    String reason = 'auto',
    bool userInitiated = false,
    String? slot,
    String? date,
  }) async {
    if (bookingId.isEmpty) return false;
    if (_isAlreadyInCall(ref, bookingId)) {
      if (_shouldLockForReason(reason)) {
        ref.read(callSessionLockProvider.notifier).lock(
              bookingId: bookingId,
              role: _safeRole(ref, role),
              slot: slot,
              date: date,
            );
      }
      return true;
    }
    if (_isInAnyCall(ref)) return false;
    if (_isOnSensitiveRoute(ref)) return false;
    if (userInitiated) {
      await CallJoinGuard.clear(bookingId);
    } else if (await CallJoinGuard.isSuppressed(bookingId)) {
      return false;
    }

    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth == null || !auth.isAuthenticated) return false;

    final safeRole = _safeRole(ref, role);
    if (!_roleAllowsCall(safeRole)) return false;

    if (_shouldLockForReason(reason)) {
      ref.read(callSessionLockProvider.notifier).lock(
            bookingId: bookingId,
            role: safeRole,
            slot: slot,
            date: date,
          );
    }
    _goToCall(ref, bookingId, safeRole);
    return true;
  }

  static Future<void> _checkClientCallWindow(WidgetRef ref) async {
    try {
      ref.invalidate(myBookingsProvider);
      final bookings = await ref.read(myBookingsProvider.future);
      final active = _findActiveBooking(bookings);
      if (active == null) {
        final lock = ref.read(callSessionLockProvider);
        if (lock != null) {
          ref.read(callSessionLockProvider.notifier).unlock(lock.bookingId);
        }
        return;
      }
      await tryAutoJoin(
        ref,
        bookingId: active.id,
        role: 'client',
        reason: 'window',
        slot: active.slot,
        date: active.date,
      );
    } catch (_) {}
  }

  static Future<void> _checkMonkCallWindow(WidgetRef ref) async {
    try {
      ref.invalidate(monkBookingsProvider);
      final bookings = await ref.read(monkBookingsProvider.future);
      final active = _findActiveMonkBooking(bookings);
      if (active == null) {
        final lock = ref.read(callSessionLockProvider);
        if (lock != null) {
          ref.read(callSessionLockProvider.notifier).unlock(lock.bookingId);
        }
        return;
      }
      await tryAutoJoin(
        ref,
        bookingId: active.id,
        role: 'monk',
        reason: 'window',
        slot: active.slot,
        date: active.date,
      );
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

  /// Auto-join зөвхөн slot эхлэхээс 1 мин өмнөөс — цаг болоход шууд орно.
  static const int _autoJoinEarlyMinutes = 1;

  static T? _closestInWindow<T>(
    Iterable<T> candidates,
    String? Function(T) date,
    String Function(T) slot,
  ) {
    final now = AppTimezone.currentTimeMinutes;
    T? best;
    var bestDiff = 1 << 30;
    for (final b in candidates) {
      if (!AppTimezone.isInCallWindow(
        date(b),
        slot(b),
        earlyMinutes: _autoJoinEarlyMinutes,
      )) {
        continue;
      }
      final diff = (AppTimezone.slotToMinutes(slot(b)) - now).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        best = b;
      }
    }
    return best;
  }

  static ClientBooking? _findActiveBooking(List<ClientBooking> bookings) {
    return _closestInWindow<ClientBooking>(
      bookings.where((b) => b.canJoinCall || b.canRejoinCall),
      (b) => b.date,
      (b) => b.slot,
    );
  }

  static MonkBookingItem? _findActiveMonkBooking(List<MonkBookingItem> bookings) {
    return _closestInWindow<MonkBookingItem>(
      bookings.where(
        (b) =>
            (b.status == 'confirmed' || b.status == 'completed') &&
            b.paid == true,
      ),
      (b) => b.date,
      (b) => b.slot,
    );
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
    final role = _safeRole(ref, call.recipientRole);
    ref.read(callSessionLockProvider.notifier).lock(
          bookingId: call.bookingId,
          role: role,
        );
    ref.read(appRouterProvider).go(
          '/call/${call.bookingId}?role=$role',
        );
  }

  static Future<void> declineCall(WidgetRef ref, IncomingCallState call) async {
    await CallJoinGuard.suppress(call.bookingId);
    ref.read(callSessionLockProvider.notifier).unlock(call.bookingId);
    ref.read(incomingCallProvider.notifier).state = null;
    LocalNotificationService.cancelIncomingCall(call.bookingId);
  }

  /// User left the room on purpose — do not auto-reopen until they accept again.
  static Future<void> markLeftCall(String bookingId, [WidgetRef? ref]) async {
    await CallJoinGuard.suppress(bookingId);
    ref?.read(callSessionLockProvider.notifier).unlock(bookingId);
  }
}
