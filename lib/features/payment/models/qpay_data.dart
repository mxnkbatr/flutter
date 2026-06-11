class QPayBankUrl {
  const QPayBankUrl({
    required this.name,
    required this.link,
    this.logo,
  });

  final String name;
  final String link;
  final String? logo;

  factory QPayBankUrl.fromJson(Map<String, dynamic> json) {
    return QPayBankUrl(
      name: json['name'] as String? ?? json['description'] as String? ?? '',
      link: json['link'] as String? ?? json['url'] as String? ?? '',
      logo: json['logo'] as String? ?? json['logoUrl'] as String?,
    );
  }
}

class QPayData {
  const QPayData({
    required this.invoiceId,
    required this.qrImageBase64,
    required this.totalAmount,
    required this.urls,
    this.monkName,
    this.monkImage,
    this.serviceName,
    this.timeSlot,
    this.dateStr,
  });

  final String invoiceId;
  final String qrImageBase64;
  final int totalAmount;
  final List<QPayBankUrl> urls;
  final String? monkName;
  final String? monkImage;
  final String? serviceName;
  final String? timeSlot;
  final String? dateStr;

  factory QPayData.fromJson(Map<String, dynamic> json) {
    final urlsRaw = json['urls'] as List<dynamic>? ?? [];
    return QPayData(
      invoiceId: json['invoiceId'] as String? ??
          json['invoice_id'] as String? ??
          '',
      qrImageBase64: json['qrImage'] as String? ??
          json['qrText'] as String? ??
          json['qr_image'] as String? ??
          '',
      totalAmount: (json['amount'] as num?)?.toInt() ?? 0,
      urls: urlsRaw
          .map((e) => QPayBankUrl.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  QPayData copyWithAmount(int amount) {
    if (totalAmount > 0) return this;
    return QPayData(
      invoiceId: invoiceId,
      qrImageBase64: qrImageBase64,
      totalAmount: amount,
      urls: urls,
      monkName: monkName,
      monkImage: monkImage,
      serviceName: serviceName,
      timeSlot: timeSlot,
      dateStr: dateStr,
    );
  }

  QPayData copyWithSummary({
    String? monkName,
    String? monkImage,
    String? serviceName,
    String? timeSlot,
    String? dateStr,
  }) {
    return QPayData(
      invoiceId: invoiceId,
      qrImageBase64: qrImageBase64,
      totalAmount: totalAmount,
      urls: urls,
      monkName: monkName ?? this.monkName,
      monkImage: monkImage ?? this.monkImage,
      serviceName: serviceName ?? this.serviceName,
      timeSlot: timeSlot ?? this.timeSlot,
      dateStr: dateStr ?? this.dateStr,
    );
  }
}

class PaymentSuccessArgs {
  const PaymentSuccessArgs({
    required this.monkName,
    required this.dateStr,
    required this.timeSlot,
    required this.amount,
  });

  final String monkName;
  final String dateStr;
  final String timeSlot;
  final int amount;
}
