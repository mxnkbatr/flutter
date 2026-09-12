import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sacred_app/core/notifications/app_permission_gate.dart';
import 'package:sacred_app/core/notifications/app_permission_prep_overlay.dart';
import 'package:sacred_app/core/notifications/call_launch_service.dart';
import 'package:sacred_app/core/notifications/push_notification_service.dart';
import 'package:sacred_app/core/router/app_router.dart';
import 'package:sacred_app/core/theme/app_theme.dart';
import 'package:sacred_app/core/theme/ios_scroll_behavior.dart';
import 'package:sacred_app/features/video_call/incoming_call_overlay.dart';
import 'package:sacred_app/features/video_call/providers/incoming_call_provider.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/firebase/firebase_app_state.dart';
import 'package:sacred_app/core/notifications/firebase_background_handler.dart';
import 'package:sacred_app/firebase_options.dart';

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 3));
    isFirebaseReady = true;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    if (kDebugMode) debugPrint('Firebase initialized');
  } catch (e) {
    isFirebaseReady = false;
    if (kDebugMode) {
      debugPrint(
        'Firebase алгасав — flutterfire configure ажиллуулна уу: $e',
      );
    }
  }
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        if (kDebugMode) {
          debugPrint('FlutterError: ${details.exceptionAsString()}');
        }
      };
      try {
        // Prefetch in background — never block first frame.
        unawaited(
          GoogleFonts.pendingFonts([
            GoogleFonts.manrope(),
            GoogleFonts.playfairDisplay(),
          ]),
        );
      } catch (_) {}
      unawaited(_initFirebase());
      unawaited(
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
      );
      runApp(const ProviderScope(child: SacredApp()));
    },
    (error, stack) {
      if (kDebugMode) {
        debugPrint('Uncaught error: $error\n$stack');
      }
    },
  );
}

class SacredApp extends ConsumerStatefulWidget {
  const SacredApp({super.key});

  @override
  ConsumerState<SacredApp> createState() => _SacredAppState();
}

class _SacredAppState extends ConsumerState<SacredApp>
    with WidgetsBindingObserver {
  static bool _pushInitStarted = false;
  AppPermissionPrepKind _prepKind = AppPermissionPrepKind.none;
  bool _prepLoading = false;
  bool _deniedHintShownThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_pushInitStarted) {
        _pushInitStarted = true;
        PushNotificationService.initialize(ref);
      }
      _maybeShowPermissionPrep();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PushNotificationService.onAppResumed(ref);
      _maybeShowPermissionPrep();
    }
  }

  Future<void> _maybeShowPermissionPrep() async {
    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth?.isAuthenticated != true) {
      if (mounted) setState(() => _prepKind = AppPermissionPrepKind.none);
      return;
    }
    final kind = await AppPermissionGate.evaluate();
    if (!mounted) return;
    if (kind == AppPermissionPrepKind.none) {
      setState(() => _prepKind = AppPermissionPrepKind.none);
      PushNotificationService.scheduleFcmSync(ref);
      return;
    }
    if (kind == AppPermissionPrepKind.deniedHint &&
        _deniedHintShownThisSession) {
      return;
    }
    setState(() => _prepKind = kind);
  }

  Future<void> _onPrepContinue() async {
    if (_prepKind == AppPermissionPrepKind.deniedHint) {
      _deniedHintShownThisSession = true;
      if (mounted) setState(() => _prepKind = AppPermissionPrepKind.none);
      return;
    }
    setState(() => _prepLoading = true);
    await AppPermissionGate.requestAfterPrep(ref);
    if (!mounted) return;
    setState(() {
      _prepLoading = false;
      _prepKind = AppPermissionPrepKind.none;
    });
  }

  void _onPrepSkip() {
    if (_prepKind == AppPermissionPrepKind.deniedHint) {
      _deniedHintShownThisSession = true;
    }
    setState(() => _prepKind = AppPermissionPrepKind.none);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (AsyncValue<AuthState>? previous, AsyncValue<AuthState> next) {
      final wasAuthed = previous?.valueOrNull?.isAuthenticated == true;
      final isAuthed = next.valueOrNull?.isAuthenticated == true;
      if (!wasAuthed && isAuthed) {
        // Системийн Allow-оос өмнө монгол зааварчилгаа харуулна.
        _maybeShowPermissionPrep();
      }
      if (wasAuthed && !isAuthed) {
        _deniedHintShownThisSession = false;
        setState(() => _prepKind = AppPermissionPrepKind.none);
      }
    });

    final router = ref.watch(appRouterProvider);
    final incoming = ref.watch(incomingCallProvider);

    return MaterialApp.router(
      title: 'Gevabal',
      theme: AppTheme.light,
      scrollBehavior: const IosScrollBehavior(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        Widget content = Stack(
          children: [
            if (child != null) child,
            if (_prepKind != AppPermissionPrepKind.none && incoming == null)
              Positioned.fill(
                child: AppPermissionPrepOverlay(
                  alreadyDenied: _prepKind == AppPermissionPrepKind.deniedHint,
                  isLoading: _prepLoading,
                  onContinue: _onPrepContinue,
                  onSkip: _onPrepSkip,
                ),
              ),
            if (incoming != null)
              Positioned.fill(
                child: PopScope(
                  canPop: false,
                  child: IncomingCallOverlay(
                    callerName: incoming.callerName,
                    callerImage: incoming.callerImage,
                    isScheduledStart: incoming.isScheduledStart,
                    onAccept: () => CallLaunchService.acceptCall(ref, incoming),
                    onDecline: () => CallLaunchService.declineCall(ref, incoming),
                  ),
                ),
              ),
          ],
        );
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.2,
            ),
          ),
          child: DefaultTextHeightBehavior(
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
            ),
            child: content,
          ),
        );
      },
    );
  }
}
