import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sacred_app/core/notifications/push_notification_service.dart';
import 'package:sacred_app/core/router/app_router.dart';
import 'package:sacred_app/core/theme/app_theme.dart';
import 'package:sacred_app/core/theme/ios_scroll_behavior.dart';
import 'package:sacred_app/features/video_call/incoming_call_overlay.dart';
import 'package:sacred_app/features/video_call/providers/incoming_call_provider.dart';
import 'package:sacred_app/firebase_options.dart';

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) debugPrint('Firebase initialized');
  } catch (e) {
    if (kDebugMode) {
      debugPrint(
        'Firebase алгасав — flutterfire configure ажиллуулна уу: $e',
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleFonts.pendingFonts([
    GoogleFonts.dmSans(),
    GoogleFonts.playfairDisplay(),
  ]);
  await _initFirebase();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: SacredApp()));
}

class SacredApp extends ConsumerStatefulWidget {
  const SacredApp({super.key});

  @override
  ConsumerState<SacredApp> createState() => _SacredAppState();
}

class _SacredAppState extends ConsumerState<SacredApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PushNotificationService.initialize(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final incoming = ref.watch(incomingCallProvider);

    return MaterialApp.router(
      title: 'Gevabal',
      theme: AppTheme.light,
      scrollBehavior: const IosScrollBehavior(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (incoming != null)
              IncomingCallOverlay(
                callerName: incoming.callerName,
                callerImage: incoming.callerImage,
                onAccept: () {
                  final bookingId = incoming.bookingId;
                  ref.read(incomingCallProvider.notifier).state = null;
                  ref.read(appRouterProvider).go('/call/$bookingId');
                },
                onDecline: () {
                  ref.read(incomingCallProvider.notifier).state = null;
                },
              ),
          ],
        );
      },
    );
  }
}
