class ApiConfig {
  /// Override in CI/release: --dart-define=API_BASE_URL=https://api.gevabal.mn/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

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
