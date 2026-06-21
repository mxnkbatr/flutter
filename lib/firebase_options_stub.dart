/// Placeholder until `flutterfire configure` generates firebase_options.dart.
/// Do not edit — run: flutterfire configure
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Firebase not configured for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'FIREBASE_NOT_CONFIGURED',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'gevabal-not-configured',
    authDomain: 'gevabal-not-configured.firebaseapp.com',
    storageBucket: 'gevabal-not-configured.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'FIREBASE_NOT_CONFIGURED',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'gevabal-not-configured',
    storageBucket: 'gevabal-not-configured.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'FIREBASE_NOT_CONFIGURED',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'gevabal-not-configured',
    storageBucket: 'gevabal-not-configured.appspot.com',
    iosBundleId: 'mn.gevabal.app',
  );
}
