import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/firebase/firebase_app_state.dart';
import 'package:sacred_app/core/notifications/call_launch_service.dart';
import 'package:sacred_app/core/notifications/firebase_background_handler.dart';
import 'package:sacred_app/core/notifications/local_notification_service.dart';
import 'package:sacred_app/core/router/app_router.dart';
import 'package:sacred_app/features/notifications/providers/notifications_provider.dart';
import 'package:sacred_app/features/video_call/providers/incoming_call_provider.dart';

class PushNotificationService {
  static Timer? _devPollTimer;

  /// Upload FCM token after login (backend uses PUT /users/profile).
  static Future<bool> syncFcmToken(WidgetRef ref) async {
    try {
      if (!isFirebaseReady) return false;
      final auth = ref.read(authStateProvider).valueOrNull;
      if (auth == null || !auth.isAuthenticated) return false;

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        if (kDebugMode) debugPrint('FCM: no token (Firebase not ready on this device)');
        return false;
      }

      await ref.read(apiClientProvider).put(
            '/users/profile',
            data: {'fcmToken': token},
          );
      if (kDebugMode) debugPrint('FCM token saved: ${token.substring(0, 12)}...');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('FCM token upload failed: $e');
      return false;
    }
  }

  static Future<void> initialize(WidgetRef ref) async {
    return _initialize(ref);
  }

  static Future<void> _initialize(WidgetRef ref) async {
    try {
      await LocalNotificationService.initialize();

      LocalNotificationService.onCallNotificationTap = (pending) {
        if (pending.directJoin) {
          CallLaunchService.handlePendingLaunch(ref);
          return;
        }
        ref.read(incomingCallProvider.notifier).state = IncomingCallState(
          callerName: pending.callerName,
          callerImage: pending.callerImage,
          bookingId: pending.bookingId,
          recipientRole: pending.role,
        );
      };

      if (!isFirebaseReady) return;

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(
        alert: true,
        sound: true,
        badge: true,
      );

      messaging.onTokenRefresh.listen((newToken) async {
        try {
          final auth = ref.read(authStateProvider).valueOrNull;
          if (auth?.isAuthenticated != true) return;
          await ref.read(apiClientProvider).put(
                '/users/profile',
                data: {'fcmToken': newToken},
              );
        } catch (_) {}
      });

      FirebaseMessaging.onMessage.listen((message) {
        _handleMessage(
          message.data,
          ref,
          foreground: true,
          title: message.notification?.title,
          body: message.notification?.body,
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleMessage(
          message.data,
          ref,
          foreground: false,
          title: message.notification?.title,
          body: message.notification?.body,
        );
      });

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _handleMessage(
          initial.data,
          ref,
          foreground: false,
          title: initial.notification?.title,
          body: initial.notification?.body,
        );
      }

      await CallLaunchService.handlePendingLaunch(ref);
      await CallLaunchService.checkActiveCallWindow(ref);

      if (authReady(ref)) {
        await syncFcmToken(ref);
      }

      if (kDebugMode) {
        _devPollTimer?.cancel();
        _devPollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
          _pollDevIncomingCall(ref);
        });
      }
    } catch (_) {
      // Push init алдаа — апп ажилласаар байна
    }
  }

  static bool authReady(WidgetRef ref) =>
      ref.read(authStateProvider).valueOrNull?.isAuthenticated == true;

  static Future<void> _pollDevIncomingCall(WidgetRef ref) async {
    try {
      if (!authReady(ref)) return;

      final res = await ref.read(apiClientProvider).get('/dev/incoming-call-pending');
      final data = res.data;
      if (data is! Map<String, dynamic> || data['bookingId'] == null) return;

      if (kDebugMode) {
        debugPrint('Dev incoming call: ${data['callerName']} → ${data['bookingId']}');
      }

      _showIncomingCall({
        'type': 'incoming_call',
        'callerName': data['callerName'],
        'callerImage': data['callerImage'],
        'bookingId': data['bookingId'],
        'recipientRole': data['recipientRole'] ?? 'client',
      }, ref);
    } catch (e) {
      if (kDebugMode) debugPrint('Dev call poll: $e');
    }
  }

  static Future<void> onAppResumed(WidgetRef ref) async {
    await _onAppResumed(ref);
  }

  static Future<void> _onAppResumed(WidgetRef ref) async {
    await syncFcmToken(ref);
    await CallLaunchService.handlePendingLaunch(ref);
    await CallLaunchService.checkActiveCallWindow(ref);
  }

  static void _handleMessage(
    Map<String, dynamic> data,
    WidgetRef ref, {
    required bool foreground,
    String? title,
    String? body,
  }) {
    final type = data['type'] as String?;
    final bookingId = data['bookingId'] as String?;

    ref.read(notificationsProvider.notifier).refresh().catchError((_) {});

    if ((type == 'incoming_call' || type == 'call_time') && bookingId != null) {
      _showIncomingCall(data, ref);
      if (!foreground) {
        LocalNotificationService.showFromRemoteData(data);
      }
      return;
    }

    if (type == 'booking_status' && bookingId != null) {
      if (foreground) {
        LocalNotificationService.showGeneral(
          id: bookingId.hashCode,
          title: title ?? 'Захиалгын мэдэгдэл',
          body: body ?? '',
          payload: jsonEncode(data),
        );
      }
      if (!foreground) {
        _navigateFromData(data, ref);
      }
      return;
    }

    if (type == 'new_message') {
      if (foreground) {
        LocalNotificationService.showGeneral(
          id: (data['conversationId'] as String? ?? 'msg').hashCode,
          title: title ?? 'Шинэ мессеж',
          body: body ?? '',
          payload: jsonEncode(data),
        );
      }
      if (!foreground) {
        _navigateFromData(data, ref);
      }
      return;
    }

    if (type == 'legal_update' ||
        type == 'promo' ||
        type == 'app_notification') {
      if (foreground) {
        LocalNotificationService.showGeneral(
          id: (data['notificationId'] as String? ?? type ?? '0').hashCode,
          title: title ?? 'Gevabal',
          body: body ?? '',
          payload: jsonEncode(data),
        );
      }
      if (!foreground) {
        _navigateFromData(data, ref);
      }
      return;
    }
  }

  static void _navigateFromData(Map<String, dynamic> data, WidgetRef ref) {
    final type = data['type'] as String?;
    final actionPath = data['actionPath'] as String?;
    final bookingId = data['bookingId'] as String?;
    final router = ref.read(appRouterProvider);

    if (actionPath != null && actionPath.isNotEmpty) {
      router.push(actionPath);
      return;
    }

    if (type == 'booking_status' && bookingId != null) {
      final status = data['status'] as String?;
      if (status == 'approved' || status == 'confirmed') {
        router.go('/payment/$bookingId');
      } else {
        router.go('/bookings');
      }
      return;
    }

    if (type == 'new_message') {
      final conversationId = data['conversationId'] as String?;
      if (conversationId != null) {
        router.go('/messenger/$conversationId');
      }
      return;
    }

    if (type == 'legal_update') {
      router.push('/profile/terms');
      return;
    }

    if (type == 'promo') {
      router.go('/home');
    }
  }

  static void _showIncomingCall(
    Map<String, dynamic> data,
    WidgetRef ref,
  ) {
    final type = data['type'] as String?;
    final auth = ref.read(authStateProvider).valueOrNull;
    final recipientRole = data['recipientRole'] as String? ??
        auth?.role ??
        'client';

    if (type == 'call_time') {
      ref.read(appRouterProvider).go(
            '/call/${data['bookingId']}?role=$recipientRole',
          );
      return;
    }

    ref.read(incomingCallProvider.notifier).state = IncomingCallState(
      callerName: data['callerName'] as String? ?? 'Хэрэглэгч',
      callerImage: data['callerImage'] as String? ?? '',
      bookingId: data['bookingId'] as String? ?? '',
      recipientRole: recipientRole,
    );

    LocalNotificationService.showIncomingCall(
      bookingId: data['bookingId'] as String? ?? '',
      callerName: data['callerName'] as String? ?? 'Хэрэглэгч',
      callerImage: data['callerImage'] as String? ?? '',
      role: recipientRole,
    );
  }
}
