import 'package:intl/intl.dart';
import 'package:sacred_app/core/utils/app_timezone.dart';
import 'package:sacred_app/features/monk_dash/models/monk_booking_item.dart';

class MonkBookingFilters {
  MonkBookingFilters._();

  static List<MonkBookingItem> sortBookings(List<MonkBookingItem> bookings) {
    int statusRank(String s) {
      const order = [
        'pending',
        'approved',
        'confirmed',
        'completed',
        'cancelled',
      ];
      final i = order.indexOf(s);
      return i == -1 ? 99 : i;
    }

    int startMinutes(MonkBookingItem b) {
      if (b.date == null || b.date!.isEmpty || b.slot.isEmpty) return 1 << 30;
      final today = AppTimezone.todayDateStr();
      final ymd = b.date!.length >= 10 ? b.date!.substring(0, 10) : b.date!;
      if (ymd != today) return 1 << 29;
      return AppTimezone.slotToMinutes(b.slot);
    }

    final sorted = [...bookings]
      ..sort((a, b) {
        final s = statusRank(a.status).compareTo(statusRank(b.status));
        if (s != 0) return s;
        return startMinutes(a).compareTo(startMinutes(b));
      });
    return sorted;
  }

  /// Баталгаажсан + төлбөр төлсөн — өнөөдрийн дуудлага.
  static List<MonkBookingItem> todayConfirmedPaid(
    List<MonkBookingItem> bookings,
  ) {
    final today = AppTimezone.todayDateStr();
    return bookings.where((b) {
      if (b.status != 'confirmed' || b.paid != true) return false;
      final d = b.date;
      if (d == null || d.isEmpty) return false;
      final ymd = d.length >= 10 ? d.substring(0, 10) : d;
      return ymd == today;
    }).toList();
  }

  /// Ирэх баталгаажсан видео дуудлагууд.
  static List<MonkBookingItem> upcomingConfirmedCalls(
    List<MonkBookingItem> bookings,
  ) {
    final today = AppTimezone.todayDateStr();
    final list = bookings.where((b) {
      if (b.status != 'confirmed' || b.paid != true) return false;
      final d = b.date;
      if (d == null || d.isEmpty || b.slot.isEmpty) return false;
      final ymd = d.length >= 10 ? d.substring(0, 10) : d;
      if (ymd.compareTo(today) < 0) return false;
      if (ymd == today) {
        if (AppTimezone.isInCallWindow(ymd, b.slot)) return false;
        if (AppTimezone.isPastSlot(ymd, b.slot)) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final da = a.date!.substring(0, 10);
        final db = b.date!.substring(0, 10);
        final c = da.compareTo(db);
        if (c != 0) return c;
        return AppTimezone.slotToMinutes(a.slot)
            .compareTo(AppTimezone.slotToMinutes(b.slot));
      });
    return list;
  }

  /// Лам баталсан, төлбөр хүлээгдэж буй.
  static List<MonkBookingItem> approvedAwaitingPayment(
    List<MonkBookingItem> bookings,
  ) {
    final today = AppTimezone.todayDateStr();
    return bookings.where((b) {
      if (b.status != 'approved') return false;
      final d = b.date;
      if (d == null || d.isEmpty || b.slot.isEmpty) return false;
      final ymd = d.length >= 10 ? d.substring(0, 10) : d;
      if (ymd.compareTo(today) < 0) return false;
      if (ymd == today && AppTimezone.isPastSlot(ymd, b.slot)) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        final da = a.date!.substring(0, 10);
        final db = b.date!.substring(0, 10);
        final c = da.compareTo(db);
        if (c != 0) return c;
        return AppTimezone.slotToMinutes(a.slot)
            .compareTo(AppTimezone.slotToMinutes(b.slot));
      });
  }

  static String formatBookingDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final ymd = date.length >= 10 ? date.substring(0, 10) : date;
      final dt = AppTimezone.parseDateOnly(ymd);
      final today = AppTimezone.startOfToday();
      if (dt.year == today.year &&
          dt.month == today.month &&
          dt.day == today.day) {
        return 'Өнөөдөр';
      }
      return DateFormat('yyyy.MM.dd').format(dt);
    } catch (_) {
      return date;
    }
  }

  static String minutesUntil(MonkBookingItem b) {
    final d = b.date;
    if (d == null || d.isEmpty || b.slot.isEmpty) return '';
    final ymd = d.length >= 10 ? d.substring(0, 10) : d;
    if (ymd != AppTimezone.todayDateStr()) {
      return formatBookingDate(d);
    }
    final start = AppTimezone.slotToMinutes(b.slot);
    final diff = start - AppTimezone.currentTimeMinutes;
    if (diff <= 0) return 'Одоо';
    if (diff < 60) return '$diff минутын дараа';
    final h = diff ~/ 60;
    final m = diff % 60;
    return m == 0 ? '$h цагийн дараа' : '$h ц $m мин дараа';
  }
}
