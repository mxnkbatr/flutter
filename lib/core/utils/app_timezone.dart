import 'package:intl/intl.dart';

/// App clock — always Ulaanbaatar (UTC+8, no DST).
///
/// Important: never run [DateFormat] on a UTC [DateTime] for calendar dates —
/// Flutter web converts to the device timezone and can shift the day.
class AppTimezone {
  AppTimezone._();

  static const _offset = Duration(hours: 8);
  static const int slotIntervalMinutes = 30;

  /// Current UB wall-clock time as a naive local [DateTime].
  static DateTime now() {
    final ub = DateTime.now().toUtc().add(_offset);
    return DateTime(
      ub.year,
      ub.month,
      ub.day,
      ub.hour,
      ub.minute,
      ub.second,
      ub.millisecond,
    );
  }

  /// Convert an absolute instant to a naive Ulaanbaatar wall-clock [DateTime].
  static DateTime toUb(DateTime instant) {
    final ub = instant.toUtc().add(_offset);
    return DateTime(
      ub.year,
      ub.month,
      ub.day,
      ub.hour,
      ub.minute,
      ub.second,
      ub.millisecond,
    );
  }

  /// `yyyy-MM` for the current Ulaanbaatar calendar month.
  static String currentMonthKey() {
    final ub = now();
    return '${ub.year.toString().padLeft(4, '0')}-${ub.month.toString().padLeft(2, '0')}';
  }

  static String todayDateStr() {
    final n = now();
    final y = n.year.toString().padLeft(4, '0');
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime parseDateOnly(String ymd) {
    final parts = ymd.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  static int slotToMinutes(String slot) {
    final parts = slot.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  static int get currentTimeMinutes {
    final n = now();
    return n.hour * 60 + n.minute;
  }

  static String _dateKey(String dateStr) =>
      dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr;

  /// True when [slot] on [dateStr] (YYYY-MM-DD) has already started in UB.
  static bool isPastSlot(String dateStr, String slot) {
    if (_dateKey(dateStr) != todayDateStr()) return false;
    return slotToMinutes(slot) < currentTimeMinutes;
  }

  static List<String> pastSlotsForDate(String dateStr, List<String> slots) {
    if (_dateKey(dateStr) != todayDateStr()) return const [];
    final nowMin = currentTimeMinutes;
    return slots.where((s) => slotToMinutes(s) < nowMin).toList();
  }

  static DateTime startOfToday() {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }

  /// True when current UB time is within [durationMinutes] of [slot] on [dateStr].
  static bool isInCallWindow(
    String? dateStr,
    String slot, {
    int durationMinutes = slotIntervalMinutes,
  }) {
    if (dateStr == null || dateStr.isEmpty || slot.isEmpty) return false;
    if (_dateKey(dateStr) != todayDateStr()) return false;
    final start = slotToMinutes(slot);
    final nowMin = currentTimeMinutes;
    return nowMin >= start && nowMin < start + durationMinutes;
  }

  /// Display helper — formats a naive UB date without shifting timezone.
  static String formatDate(DateTime date, String pattern) {
    return DateFormat(pattern).format(
      DateTime(date.year, date.month, date.day, date.hour, date.minute),
    );
  }

  /// Format an absolute instant (ISO/UTC from API) in Ulaanbaatar wall time.
  static String formatInstant(DateTime instant, String pattern) {
    return formatDate(toUb(instant), pattern);
  }
}
