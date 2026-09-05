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

class TodayBookingDetail {
  const TodayBookingDetail({
    required this.id,
    required this.clientName,
    required this.monkName,
    required this.serviceName,
    required this.amount,
    required this.monkEarns,
    required this.platformShare,
    this.date = '',
    this.slot = '',
    this.status = '',
  });

  final String id;
  final String clientName;
  final String monkName;
  final String serviceName;
  final int amount;
  final int monkEarns;
  final int platformShare;
  final String date;
  final String slot;
  final String status;

  factory TodayBookingDetail.fromJson(Map<String, dynamic> json) {
    return TodayBookingDetail(
      id: json['id'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      monkName: json['monkName'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      monkEarns: (json['monkEarns'] as num?)?.toInt() ?? 0,
      platformShare: (json['platformShare'] as num?)?.toInt() ?? 0,
      date: json['date'] as String? ?? '',
      slot: json['slot'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class MonkViewStat {
  const MonkViewStat({
    required this.monkId,
    required this.monkName,
    this.monkImage = '',
    required this.views,
  });

  final String monkId;
  final String monkName;
  final String monkImage;
  final int views;

  factory MonkViewStat.fromJson(Map<String, dynamic> json) {
    return MonkViewStat(
      monkId: json['monkId'] as String? ?? '',
      monkName: json['monkName'] as String? ?? '',
      monkImage: json['monkImage'] as String? ?? '',
      views: (json['views'] as num?)?.toInt() ?? 0,
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
    this.monthRevenue = 0,
    this.todayRevenue = 0,
    this.todayBookingsCount = 0,
    this.todayMonkPayout = 0,
    this.todayPlatformShare = 0,
    this.todayQpayFees = 0,
    this.todayPlatformNet = 0,
    this.todayProfileViews = 0,
    this.todayUniqueViewers = 0,
    this.monkSharePercent = 70,
    this.platformSharePercent = 30,
    this.todayBookingsDetail = const [],
    this.todayViewsByMonk = const [],
    this.qpayConfigured = false,
    this.appBaseUrl = '',
  });

  final int totalRevenue;
  final int monthRevenue;
  final int todayRevenue;
  final int todayBookingsCount;
  final int todayMonkPayout;
  final int todayPlatformShare;
  final int todayQpayFees;
  final int todayPlatformNet;
  final int todayProfileViews;
  final int todayUniqueViewers;
  final int monkSharePercent;
  final int platformSharePercent;
  final List<TodayBookingDetail> todayBookingsDetail;
  final List<MonkViewStat> todayViewsByMonk;
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
    final todayDetail = json['todayBookingsDetail'] as List<dynamic>? ?? [];
    final viewsByMonk = json['todayViewsByMonk'] as List<dynamic>? ?? [];

    return AdminDashboardData(
      totalRevenue: (json['totalRevenue'] as num?)?.toInt() ??
          (json['total_revenue'] as num?)?.toInt() ??
          0,
      monthRevenue: (json['monthRevenue'] as num?)?.toInt() ?? 0,
      todayRevenue: (json['todayRevenue'] as num?)?.toInt() ?? 0,
      todayBookingsCount: (json['todayBookingsCount'] as num?)?.toInt() ?? 0,
      todayMonkPayout: (json['todayMonkPayout'] as num?)?.toInt() ?? 0,
      todayPlatformShare: (json['todayPlatformShare'] as num?)?.toInt() ?? 0,
      todayQpayFees: (json['todayQpayFees'] as num?)?.toInt() ?? 0,
      todayPlatformNet: (json['todayPlatformNet'] as num?)?.toInt() ?? 0,
      todayProfileViews: (json['todayProfileViews'] as num?)?.toInt() ?? 0,
      todayUniqueViewers: (json['todayUniqueViewers'] as num?)?.toInt() ?? 0,
      monkSharePercent: (json['monkSharePercent'] as num?)?.toInt() ?? 70,
      platformSharePercent:
          (json['platformSharePercent'] as num?)?.toInt() ?? 30,
      todayBookingsDetail: todayDetail
          .map((e) => TodayBookingDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      todayViewsByMonk: viewsByMonk
          .map((e) => MonkViewStat.fromJson(e as Map<String, dynamic>))
          .toList(),
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
