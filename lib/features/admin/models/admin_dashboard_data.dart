import 'package:sacred_app/features/admin/models/admin_booking_item.dart';
import 'package:sacred_app/features/admin/models/admin_monk.dart';

class MonthlyRevenue {
  const MonthlyRevenue({required this.label, required this.amount});

  final String label;
  final int amount;

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenue(
      label: json['label'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminDashboardData {
  const AdminDashboardData({
    required this.totalRevenue,
    required this.totalBookings,
    required this.bookingsGrowth,
    required this.activeMonks,
    required this.pendingMonks,
    required this.totalUsers,
    required this.newUsersThisWeek,
    required this.monthlyRevenue,
    required this.pendingMonksList,
    required this.recentBookings,
    this.qpayConfigured = false,
    this.appBaseUrl = '',
  });

  final int totalRevenue;
  final int totalBookings;
  final double bookingsGrowth;
  final int activeMonks;
  final int pendingMonks;
  final int totalUsers;
  final int newUsersThisWeek;
  final List<MonthlyRevenue> monthlyRevenue;
  final List<AdminMonk> pendingMonksList;
  final List<AdminBookingItem> recentBookings;
  final bool qpayConfigured;
  final String appBaseUrl;

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    final monthly = json['monthlyRevenue'] as List<dynamic>? ??
        json['monthly_revenue'] as List<dynamic>? ??
        [];
    final pending = json['pendingMonksList'] as List<dynamic>? ??
        json['pending_monks_list'] as List<dynamic>? ??
        [];
    final recent = json['recentBookings'] as List<dynamic>? ??
        json['recent_bookings'] as List<dynamic>? ??
        [];

    return AdminDashboardData(
      totalRevenue: (json['totalRevenue'] as num?)?.toInt() ??
          (json['total_revenue'] as num?)?.toInt() ??
          0,
      totalBookings: json['totalBookings'] as int? ??
          json['total_bookings'] as int? ??
          0,
      bookingsGrowth: (json['bookingsGrowth'] as num?)?.toDouble() ??
          (json['bookings_growth'] as num?)?.toDouble() ??
          0,
      activeMonks:
          json['activeMonks'] as int? ?? json['active_monks'] as int? ?? 0,
      pendingMonks:
          json['pendingMonks'] as int? ?? json['pending_monks'] as int? ?? 0,
      totalUsers:
          json['totalUsers'] as int? ?? json['total_users'] as int? ?? 0,
      newUsersThisWeek: json['newUsersThisWeek'] as int? ??
          json['new_users_this_week'] as int? ??
          0,
      qpayConfigured: json['qpayConfigured'] as bool? ??
          json['qpay_configured'] as bool? ??
          false,
      appBaseUrl: json['appBaseUrl'] as String? ??
          json['app_base_url'] as String? ??
          '',
      monthlyRevenue: monthly
          .map((e) => MonthlyRevenue.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingMonksList: pending
          .map((e) => AdminMonk.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentBookings: recent
          .map((e) => AdminBookingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
