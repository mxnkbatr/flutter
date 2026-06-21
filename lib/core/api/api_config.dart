import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Production/staging backend (Render deploy хийсний дараа).
  /// Codemagic: --dart-define=API_BASE_URL=https://geva-api.onrender.com/api
  static const String productionBaseUrl =
      'https://geva-api.onrender.com/api';

  /// Физик утас → PC backend: --dart-define=LOCAL_API_HOST=192.168.x.x
  static const String localApiHost = String.fromEnvironment(
    'LOCAL_API_HOST',
    defaultValue: '',
  );

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kDebugMode) {
      return 'http://${_debugHost()}:3000/api';
    }

    return productionBaseUrl;
  }

  static String _debugHost() {
    if (localApiHost.isNotEmpty) return localApiHost;
    if (kIsWeb) return 'localhost';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator → host PC. Физик утас дээр LOCAL_API_HOST заана.
        return '10.0.2.2';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return 'localhost';
      default:
        return 'localhost';
    }
  }

  /// Debug local fallback only. Release builds must pass PREFER_DEV_AUTH=false.
  static const bool preferDevAuth = bool.fromEnvironment(
    'PREFER_DEV_AUTH',
    defaultValue: true,
  );

  /// `npm run seed` — local backend туршилтын хэрэглэгч
  static const String seedClientEmail = 'client@test.com';
  static const String seedClientPassword = 'client123';

  // Auth
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Monks
  static const String monks = '/monks';

  // Bookings
  static const String bookings = '/bookings';

  // Payment
  static const String qpayCreate = '/payment/qpay/create';
  static String qpayCheck(String invoiceId) =>
      '/payment/qpay/check/$invoiceId';

  // LiveKit
  static const String livekit = '/livekit';

  // Monk dashboard
  static const String monkDashboard = '/monk/dashboard';
  static const String monkSalary = '/monk/salary';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminMonks = '/admin/monks';

  // Subscription
  static const String subscriptionPlans = '/subscription/plans';
  static const String subscriptionSubscribe = '/subscription/subscribe';
}
