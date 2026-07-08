import 'package:intl/intl.dart';

/// App clock — always Ulaanbaatar (UTC+8, no DST).
class AppTimezone {
  AppTimezone._();

  static const _offset = Duration(hours: 8);
  static const int slotIntervalMinutes = 30;

  static DateTime now() => DateTime.now().toUtc().add(_offset);

  static String todayDateStr() => DateFormat('yyyy-MM-dd').format(now());

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

  /// True when [slot] on [dateStr] (YYYY-MM-DD) has already started in UB.
  static bool isPastSlot(String dateStr, String slot) {
    if (dateStr.length >= 10 && dateStr.substring(0, 10) != todayDateStr()) {
      return false;
    }
    return slotToMinutes(slot) < currentTimeMinutes;
  }

  static List<String> pastSlotsForDate(String dateStr, List<String> slots) {
    if (dateStr.length >= 10 && dateStr.substring(0, 10) != todayDateStr()) {
      return const [];
    }
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
    final today = todayDateStr();
    if (dateStr.length >= 10 && dateStr.substring(0, 10) != today) {
      return false;
    }
    final start = slotToMinutes(slot);
    final nowMin = currentTimeMinutes;
    return nowMin >= start && nowMin < start + durationMinutes;
  }
}
