import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/router/app_router.dart';
import 'package:sacred_app/features/video_call/providers/incoming_call_provider.dart';

class PushNotificationService {
  static Future<void> initialize(WidgetRef ref) async {
    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(
        alert: true,
        sound: true,
        badge: true,
      );

      final token = await messaging.getToken();
      if (token != null) {
        try {
          await ref.read(apiClientProvider).post(
                '/users/profile',
                data: {'fcmToken': token},
              );
        } catch (e) {
          if (kDebugMode) debugPrint('FCM token upload failed: $e');
        }
      }

      messaging.onTokenRefresh.listen((newToken) {
        ref.read(apiClientProvider).post(
          '/users/profile',
          data: {'fcmToken': newToken},
        );
      });

      FirebaseMessaging.onMessage.listen((message) {
        final data = message.data;
        if (data['type'] == 'incoming_call') {
          _showIncomingCallOverlay(data, ref);
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final bookingId = message.data['bookingId'];
        if (bookingId != null) {
          ref.read(appRouterProvider).go('/call/$bookingId');
        }
      });

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        final bookingId = initial.data['bookingId'];
        if (bookingId != null) {
          ref.read(appRouterProvider).go('/call/$bookingId');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('PushNotificationService init skipped: $e');
    }
  }

  static void _showIncomingCallOverlay(
    Map<String, dynamic> data,
    WidgetRef ref,
  ) {
    ref.read(incomingCallProvider.notifier).state = IncomingCallState(
      callerName: data['callerName'] as String? ?? 'Хэрэглэгч',
      callerImage: data['callerImage'] as String? ?? '',
      bookingId: data['bookingId'] as String? ?? '',
    );
  }
}
