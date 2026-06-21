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
        _handleMessage(message.data, ref);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleMessage(message.data, ref);
      });

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _handleMessage(initial.data, ref);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('PushNotificationService init skipped: $e');
    }
  }

  static void _handleMessage(Map<String, dynamic> data, WidgetRef ref) {
    final type = data['type'] as String?;
    final bookingId = data['bookingId'] as String?;

    if (type == 'incoming_call' && bookingId != null) {
      _showIncomingCallOverlay(data, ref);
      return;
    }

    if (type == 'booking_status' && bookingId != null) {
      final status = data['status'] as String?;
      final router = ref.read(appRouterProvider);
      if (status == 'approved') {
        router.go('/payment/$bookingId');
      } else if (status == 'confirmed') {
        router.go('/payment/$bookingId');
      } else {
        router.go('/bookings');
      }
      return;
    }

    if (type == 'new_message') {
      final conversationId = data['conversationId'] as String?;
      if (conversationId != null) {
        ref.read(appRouterProvider).go('/messenger/$conversationId');
      }
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
