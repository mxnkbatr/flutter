class ApiConfig {
  /// Local backend — Android emulator: http://10.0.2.2:3000/api
  static const String baseUrl = 'http://localhost:3000/api';

  /// Backend холбогдохгүй үед debug-д локал dev нэвтрэлт рүү fallback.
  static const bool preferDevAuth = true;

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
