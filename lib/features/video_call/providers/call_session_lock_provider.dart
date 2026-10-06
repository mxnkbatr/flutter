import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Захиалсан цаг эхэлсэн үед хэрэглэгчийг /call дэлгэцэд түгжинэ.
/// Зөвхөн «Дуусгах» (эсвэл цонх дууссан) үед суллана.
class CallSessionLock {
  const CallSessionLock({
    required this.bookingId,
    required this.role,
    this.slot,
    this.date,
  });

  final String bookingId;
  final String role;
  final String? slot;
  final String? date;
}

class CallSessionLockNotifier extends StateNotifier<CallSessionLock?> {
  CallSessionLockNotifier() : super(null);

  void lock({
    required String bookingId,
    required String role,
    String? slot,
    String? date,
  }) {
    if (bookingId.isEmpty) return;
    state = CallSessionLock(
      bookingId: bookingId,
      role: role,
      slot: slot,
      date: date,
    );
  }

  void unlock([String? bookingId]) {
    if (bookingId != null &&
        bookingId.isNotEmpty &&
        state?.bookingId != bookingId) {
      return;
    }
    state = null;
  }
}

final callSessionLockProvider =
    StateNotifierProvider<CallSessionLockNotifier, CallSessionLock?>((ref) {
  return CallSessionLockNotifier();
});
