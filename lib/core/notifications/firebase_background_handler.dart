import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:sacred_app/core/notifications/local_notification_service.dart';
import 'package:sacred_app/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    debugPrint('FCM background: ${message.data}');
  }
  // FCM already shows a system notification when `notification` payload is set.
  if (message.notification != null) return;
  await LocalNotificationService.showFromRemoteData(message.data);
}
