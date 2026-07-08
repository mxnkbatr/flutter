import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pendingCallKey = 'pending_call_launch';

class PendingCallLaunch {
  const PendingCallLaunch({
    required this.bookingId,
    required this.role,
    required this.callerName,
    this.callerImage = '',
    this.directJoin = false,
  });

  final String bookingId;
  final String role;
  final String callerName;
  final String callerImage;
  final bool directJoin;

  Map<String, String> toJson() => {
        'type': directJoin ? 'call_time' : 'incoming_call',
        'bookingId': bookingId,
        'role': role,
        'callerName': callerName,
        'callerImage': callerImage,
        'directJoin': directJoin.toString(),
      };

  factory PendingCallLaunch.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final directJoin = json['directJoin'] == true ||
        json['directJoin'] == 'true' ||
        type == 'call_time';
    return PendingCallLaunch(
      bookingId: json['bookingId'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      callerName: json['callerName'] as String? ?? '',
      callerImage: json['callerImage'] as String? ?? '',
      directJoin: directJoin,
    );
  }
}

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static void Function(PendingCallLaunch)? onCallNotificationTap;
  static void Function(Map<String, dynamic> data)? onGeneralNotificationTap;

  static Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onTap,
    );

    const channel = AndroidNotificationChannel(
      'incoming_calls',
      'Дуудлага',
      description: 'Орж ирж буй видео дуудлага',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const generalChannel = AndroidNotificationChannel(
      'gevabal_general',
      'Мэдэгдэл',
      description: 'Захиалга, нөхцөл, мессежийн мэдэгдэл',
      importance: Importance.high,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);

    _initialized = true;
  }

  static void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final type = map['type'] as String?;
      if (type == 'incoming_call' || type == 'call_time') {
        final pending = PendingCallLaunch(
          bookingId: map['bookingId'] as String? ?? '',
          role: map['role'] as String? ?? 'client',
          callerName: map['callerName'] as String? ?? '',
          callerImage: map['callerImage'] as String? ?? '',
          directJoin: true,
        );
        _storePending(pending);
        onCallNotificationTap?.call(pending);
        return;
      }
      onGeneralNotificationTap?.call(map);
    } catch (e) {
      if (kDebugMode) debugPrint('Notification tap parse error: $e');
    }
  }

  static Future<void> storeIncomingCallOverlay(PendingCallLaunch pending) async {
    await _storePending(
      PendingCallLaunch(
        bookingId: pending.bookingId,
        role: pending.role,
        callerName: pending.callerName,
        callerImage: pending.callerImage,
      ),
    );
  }

  static Future<void> _storePending(PendingCallLaunch pending) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingCallKey, jsonEncode(pending.toJson()));
  }

  static Future<PendingCallLaunch?> consumePendingLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingCallKey);
    if (raw == null) return null;
    await prefs.remove(_pendingCallKey);
    try {
      return PendingCallLaunch.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> showIncomingCall({
    required String bookingId,
    required String callerName,
    String callerImage = '',
    String role = 'client',
    bool directJoin = false,
  }) async {
    await initialize();
    if (bookingId.isEmpty) return;

    final pending = PendingCallLaunch(
      bookingId: bookingId,
      role: role,
      callerName: callerName,
      callerImage: callerImage,
      directJoin: directJoin,
    );
    final payload = jsonEncode({
      'type': directJoin ? 'call_time' : 'incoming_call',
      ...pending.toJson(),
    });

    if (!directJoin) {
      await storeIncomingCallOverlay(pending);
    }

    const android = AndroidNotificationDetails(
      'incoming_calls',
      'Дуудлага',
      channelDescription: 'Орж ирж буй видео дуудлага',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      visibility: NotificationVisibility.public,
      ticker: 'Дуудлага ирж байна',
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    await _plugin.show(
      bookingId.hashCode,
      'Дуудлага ирж байна',
      callerName,
      const NotificationDetails(android: android, iOS: ios),
      payload: payload,
    );
  }

  static Future<void> cancelIncomingCall(String bookingId) async {
    await _plugin.cancel(bookingId.hashCode);
  }

  static Future<void> showFromRemoteData(Map<String, dynamic> data) async {
    final type = data['type'] as String?;
    if (type == 'incoming_call' || type == 'call_time') {
      await showIncomingCall(
        bookingId: data['bookingId'] as String? ?? '',
        callerName: data['callerName'] as String? ?? 'Хэрэглэгч',
        callerImage: data['callerImage'] as String? ?? '',
        role: data['recipientRole'] as String? ?? 'client',
        directJoin: type == 'call_time',
      );
      return;
    }

    await showGeneral(
      id: (data['notificationId'] as String? ?? type ?? '0').hashCode,
      title: _titleFromData(data),
      body: _bodyFromData(data),
      payload: jsonEncode(data),
    );
  }

  static String _titleFromData(Map<String, dynamic> data) {
    final fromPayload = data['title'] as String?;
    if (fromPayload != null && fromPayload.isNotEmpty) return fromPayload;
    final type = data['type'] as String?;
    return switch (type) {
      'legal_update' => 'Үйлчилгээний нөхцөл шинэчлэгдлээ',
      'booking_status' => 'Захиалгын мэдэгдэл',
      'new_message' => 'Шинэ мессеж',
      'promo' => 'Gevabal санал',
      _ => 'Gevabal',
    };
  }

  static String _bodyFromData(Map<String, dynamic> data) {
    final fromPayload = data['body'] as String?;
    if (fromPayload != null && fromPayload.isNotEmpty) return fromPayload;
    return 'Шинэ мэдэгдэл ирлээ';
  }

  static Future<void> showGeneral({
    required int id,
    required String title,
    required String body,
    String payload = '',
  }) async {
    await initialize();

    const android = AndroidNotificationDetails(
      'gevabal_general',
      'Мэдэгдэл',
      channelDescription: 'Захиалга, нөхцөл, мессежийн мэдэгдэл',
      importance: Importance.high,
      priority: Priority.high,
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
      payload: payload.isEmpty ? null : payload,
    );
  }
}
