class EarningTransaction {
  const EarningTransaction({
    required this.bookingId,
    required this.clientName,
    required this.serviceName,
    required this.date,
    required this.amount,
    required this.monkEarns,
  });

  final String bookingId;
  final String clientName;
  final String serviceName;
  final String date;
  final int amount;
  final int monkEarns;

  factory EarningTransaction.fromJson(Map<String, dynamic> json) {
    return EarningTransaction(
      bookingId: json['bookingId'] as String? ?? json['id'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      date: json['date'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      monkEarns: (json['monkEarns'] as num?)?.toInt() ??
          (json['monk_earns'] as num?)?.toInt() ??
          0,
    );
  }
}

class MonkEarningsData {
  const MonkEarningsData({
    required this.month,
    required this.completedCount,
    required this.grossAmount,
    required this.platformFee,
    required this.qpayFee,
    required this.netEarnings,
    required this.transactions,
  });

  final String month;
  final int completedCount;
  final int grossAmount;
  final int platformFee;
  final int qpayFee;
  final int netEarnings;
  final List<EarningTransaction> transactions;

  factory MonkEarningsData.fromJson(Map<String, dynamic> json) {
    final txs = json['transactions'] as List<dynamic>? ?? [];
    return MonkEarningsData(
      month: json['month'] as String? ?? '',
      completedCount: json['completedCount'] as int? ??
          json['completed_count'] as int? ??
          0,
      grossAmount: (json['grossAmount'] as num?)?.toInt() ??
          (json['gross_amount'] as num?)?.toInt() ??
          0,
      platformFee: (json['platformFee'] as num?)?.toInt() ??
          (json['platform_fee'] as num?)?.toInt() ??
          0,
      qpayFee:
          (json['qpayFee'] as num?)?.toInt() ?? (json['qpay_fee'] as num?)?.toInt() ?? 0,
      netEarnings: (json['netEarnings'] as num?)?.toInt() ??
          (json['net_earnings'] as num?)?.toInt() ??
          0,
      transactions: txs
          .map((e) => EarningTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
