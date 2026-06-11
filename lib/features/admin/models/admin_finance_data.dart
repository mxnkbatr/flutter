class MonkSalarySummary {
  const MonkSalarySummary({
    required this.monkId,
    required this.monkName,
    this.monkImage,
    required this.bookingCount,
    required this.netEarnings,
  });

  final String monkId;
  final String monkName;
  final String? monkImage;
  final int bookingCount;
  final int netEarnings;

  factory MonkSalarySummary.fromJson(Map<String, dynamic> json) {
    return MonkSalarySummary(
      monkId: json['monkId'] as String? ?? json['monk_id'] as String? ?? '',
      monkName: json['monkName'] as String? ?? json['monk_name'] as String? ?? '',
      monkImage: json['monkImage'] as String? ?? json['monk_image'] as String?,
      bookingCount: json['bookingCount'] as int? ??
          json['booking_count'] as int? ??
          0,
      netEarnings: (json['netEarnings'] as num?)?.toInt() ??
          (json['net_earnings'] as num?)?.toInt() ??
          0,
    );
  }
}

class AdminFinanceData {
  const AdminFinanceData({
    required this.month,
    required this.totalRevenue,
    required this.platformFees,
    required this.qpayFees,
    required this.netProfit,
    required this.monkSalaries,
  });

  final String month;
  final int totalRevenue;
  final int platformFees;
  final int qpayFees;
  final int netProfit;
  final List<MonkSalarySummary> monkSalaries;

  factory AdminFinanceData.fromJson(Map<String, dynamic> json) {
    final salaries = json['monkSalaries'] as List<dynamic>? ??
        json['monk_salaries'] as List<dynamic>? ??
        [];
    return AdminFinanceData(
      month: json['month'] as String? ?? '',
      totalRevenue: (json['totalRevenue'] as num?)?.toInt() ??
          (json['total_revenue'] as num?)?.toInt() ??
          0,
      platformFees: (json['platformFees'] as num?)?.toInt() ??
          (json['platform_fees'] as num?)?.toInt() ??
          0,
      qpayFees:
          (json['qpayFees'] as num?)?.toInt() ?? (json['qpay_fees'] as num?)?.toInt() ?? 0,
      netProfit: (json['netProfit'] as num?)?.toInt() ??
          (json['net_profit'] as num?)?.toInt() ??
          0,
      monkSalaries: salaries
          .map((e) => MonkSalarySummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
