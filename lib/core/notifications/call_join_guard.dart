import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _suppressKey = 'call_auto_join_suppress_v1';

/// Blocks forced auto-join after the user declines or leaves a call,
/// so resume / call_time push cannot yank them back mid-slot.
class CallJoinGuard {
  /// Suppress auto-join until [until] (default: 45 minutes).
  static Future<void> suppress(
    String bookingId, {
    Duration ttl = const Duration(minutes: 45),
  }) async {
    if (bookingId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final map = _readMap(prefs);
    map[bookingId] = DateTime.now().add(ttl).millisecondsSinceEpoch;
    await prefs.setString(_suppressKey, jsonEncode(map));
  }

  static Future<bool> isSuppressed(String bookingId) async {
    if (bookingId.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final map = _readMap(prefs);
    final untilMs = map[bookingId];
    if (untilMs == null) return false;
    if (DateTime.now().millisecondsSinceEpoch >= untilMs) {
      map.remove(bookingId);
      await prefs.setString(_suppressKey, jsonEncode(map));
      return false;
    }
    return true;
  }

  static Future<void> clear(String bookingId) async {
    if (bookingId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final map = _readMap(prefs);
    if (map.remove(bookingId) != null) {
      await prefs.setString(_suppressKey, jsonEncode(map));
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_suppressKey);
  }

  static Map<String, int> _readMap(SharedPreferences prefs) {
    final raw = prefs.getString(_suppressKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final out = <String, int>{};
      decoded.forEach((key, value) {
        final ms = value is int ? value : int.tryParse('$value');
        if (ms != null) out['$key'] = ms;
      });
      return out;
    } catch (_) {
      return {};
    }
  }
}
