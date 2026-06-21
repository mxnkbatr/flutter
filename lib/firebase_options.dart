// Firebase config — project: gevabal-da4f2, bundle: mn.gevabal.app
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
    apiKey: 'AIzaSyBH4abEG_1pANerKtWd_pduwUyvdaILYnI',
    appId: '1:616157786188:web:0000000000000000000000',
    messagingSenderId: '616157786188',
    projectId: 'gevabal-da4f2',
    authDomain: 'gevabal-da4f2.firebaseapp.com',
    storageBucket: 'gevabal-da4f2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDY7KCNMXlWE209EV7Kfxx6gC1XQxO6FD4',
    appId: '1:616157786188:android:ea5658b6c0a4dfc0d684e9',
    messagingSenderId: '616157786188',
    projectId: 'gevabal-da4f2',
    storageBucket: 'gevabal-da4f2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBH4abEG_1pANerKtWd_pduwUyvdaILYnI',
    appId: '1:616157786188:ios:a2c6825fb999e248d684e9',
    messagingSenderId: '616157786188',
    projectId: 'gevabal-da4f2',
    storageBucket: 'gevabal-da4f2.firebasestorage.app',
    iosBundleId: 'mn.gevabal.app',
  );
}
