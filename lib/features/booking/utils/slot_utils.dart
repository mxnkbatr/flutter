import 'package:sacred_app/core/utils/app_timezone.dart';

class SlotUtils {
  SlotUtils._();

  static bool isUnavailable({
    required String slot,
    required String dateStr,
    required bool isBooked,
    List<String> pastSlots = const [],
  }) {
    return isBooked ||
        pastSlots.contains(slot) ||
        AppTimezone.isPastSlot(dateStr, slot);
  }
}
