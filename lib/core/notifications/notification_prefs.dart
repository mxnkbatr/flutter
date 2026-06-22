import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sacred_app/core/api/api_client.dart';

const kNotifBooking = 'notif_booking_updates';
const kNotifBookingReminder = 'notif_booking_reminders';
const kNotifMessage = 'notif_messages';
const kNotifPromo = 'notif_promotions';
const kNotifCall = 'notif_incoming_calls';
const kNotifLegal = 'notif_legal_updates';

class NotificationPrefs {
  const NotificationPrefs({
    this.booking = true,
    this.bookingReminder = true,
    this.message = true,
    this.promo = true,
    this.call = true,
    this.legal = true,
  });

  final bool booking;
  final bool bookingReminder;
  final bool message;
  final bool promo;
  final bool call;
  final bool legal;

  Map<String, bool> toApiJson() => {
        'booking': booking,
        'bookingReminder': bookingReminder,
        'message': message,
        'promo': promo,
        'call': call,
        'legal': legal,
      };

  factory NotificationPrefs.fromApi(Map<String, dynamic> json) {
    return NotificationPrefs(
      booking: json['booking'] as bool? ?? true,
      bookingReminder: json['bookingReminder'] as bool? ?? true,
      message: json['message'] as bool? ?? true,
      promo: json['promo'] as bool? ?? true,
      call: json['call'] as bool? ?? true,
      legal: json['legal'] as bool? ?? true,
    );
  }

  Future<void> saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kNotifBooking, booking);
    await prefs.setBool(kNotifBookingReminder, bookingReminder);
    await prefs.setBool(kNotifMessage, message);
    await prefs.setBool(kNotifPromo, promo);
    await prefs.setBool(kNotifCall, call);
    await prefs.setBool(kNotifLegal, legal);
  }

  static Future<NotificationPrefs> loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPrefs(
      booking: prefs.getBool(kNotifBooking) ?? true,
      bookingReminder: prefs.getBool(kNotifBookingReminder) ?? true,
      message: prefs.getBool(kNotifMessage) ?? true,
      promo: prefs.getBool(kNotifPromo) ?? true,
      call: prefs.getBool(kNotifCall) ?? true,
      legal: prefs.getBool(kNotifLegal) ?? true,
    );
  }

  NotificationPrefs copyWith({
    bool? booking,
    bool? bookingReminder,
    bool? message,
    bool? promo,
    bool? call,
    bool? legal,
  }) {
    return NotificationPrefs(
      booking: booking ?? this.booking,
      bookingReminder: bookingReminder ?? this.bookingReminder,
      message: message ?? this.message,
      promo: promo ?? this.promo,
      call: call ?? this.call,
      legal: legal ?? this.legal,
    );
  }
}

final notificationPrefsProvider =
    AsyncNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  NotificationPrefsNotifier.new,
);

class NotificationPrefsNotifier extends AsyncNotifier<NotificationPrefs> {
  @override
  Future<NotificationPrefs> build() async {
    try {
      final res = await ref.read(apiClientProvider).get('/users/notification-settings');
      final prefs = NotificationPrefs.fromApi(res.data as Map<String, dynamic>);
      await prefs.saveLocal();
      return prefs;
    } catch (_) {
      return NotificationPrefs.loadLocal();
    }
  }

  Future<void> savePrefs(NotificationPrefs prefs) async {
    state = AsyncData(prefs);
    await prefs.saveLocal();
    try {
      await ref
          .read(apiClientProvider)
          .put('/users/notification-settings', data: prefs.toApiJson());
    } catch (_) {}
  }
}
