import 'package:sacred_app/features/monk_dash/models/monk_booking_item.dart';

class MonkDashboardData {
  const MonkDashboardData({
    required this.monthlyEarnings,
    required this.earningsChangePercent,
    required this.totalBookings,
    required this.weeklyBookings,
    required this.rating,
    required this.reviewCount,
    required this.pendingCount,
    required this.todayBookings,
    this.isAvailable = true,
    this.monkName,
  });

  final int monthlyEarnings;
  final double earningsChangePercent;
  final int totalBookings;
  final int weeklyBookings;
  final double rating;
  final int reviewCount;
  final int pendingCount;
  final List<MonkBookingItem> todayBookings;
  final bool isAvailable;
  final String? monkName;

  factory MonkDashboardData.fromJson(Map<String, dynamic> json) {
    final today = json['todayBookings'] as List<dynamic>? ??
        json['today_bookings'] as List<dynamic>? ??
        [];
    return MonkDashboardData(
      monthlyEarnings:
          (json['monthlyEarnings'] as num?)?.toInt() ??
              (json['monthly_earnings'] as num?)?.toInt() ??
              0,
      earningsChangePercent:
          (json['earningsChangePercent'] as num?)?.toDouble() ??
              (json['earnings_change_percent'] as num?)?.toDouble() ??
              0,
      totalBookings: json['totalBookings'] as int? ??
          json['total_bookings'] as int? ??
          0,
      weeklyBookings: json['weeklyBookings'] as int? ??
          json['weekly_bookings'] as int? ??
          0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ??
          json['review_count'] as int? ??
          0,
      pendingCount: json['pendingCount'] as int? ??
          json['pending_count'] as int? ??
          0,
      todayBookings: today
          .map((e) => MonkBookingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      isAvailable: json['isAvailable'] as bool? ??
          json['is_available'] as bool? ??
          true,
      monkName: json['monkName'] as String? ?? json['name'] as String?,
    );
  }
}
