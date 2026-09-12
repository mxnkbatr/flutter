import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:sacred_app/core/firebase/firebase_app_state.dart';
import 'package:sacred_app/core/notifications/push_notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Апп нэвтрэх үеийн мэдэгдэл/микрофон зааварчилгааны төлөв.
enum AppPermissionPrepKind { none, ask, deniedHint }

class AppPermissionGate {
  AppPermissionGate._();

  static Future<AppPermissionPrepKind> evaluate() async {
    if (!isFirebaseReady) return AppPermissionPrepKind.none;
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
        case AuthorizationStatus.provisional:
          return AppPermissionPrepKind.none;
        case AuthorizationStatus.denied:
          return AppPermissionPrepKind.deniedHint;
        case AuthorizationStatus.notDetermined:
          return AppPermissionPrepKind.ask;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('AppPermissionGate: $e');
      return AppPermissionPrepKind.none;
    }
  }

  /// Монгол зааврын дараа — мэдэгдэл + микрофоны системийн popup.
  static Future<void> requestAfterPrep(WidgetRef ref) async {
    await PushNotificationService.requestNotificationPermission(
      allowPrompt: true,
    );
    await _probeMicrophonePermission();
    // Token sync — permission аль хэдийн асуусан тул prompt дахин гаргахгүй.
    await PushNotificationService.syncFcmToken(ref, allowPrompt: false);
    PushNotificationService.scheduleFcmSync(ref);
  }

  /// LiveKit-ээр микрофон асуух (native permission_handler шаардлагагүй).
  static Future<void> _probeMicrophonePermission() async {
    if (kIsWeb) return;
    try {
      final track = await LocalAudioTrack.create(
        const AudioCaptureOptions(),
      );
      await track.stop();
      await track.dispose();
    } catch (e) {
      if (kDebugMode) debugPrint('Mic probe: $e');
    }
  }
}