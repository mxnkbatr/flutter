class MonkBookingItem {
  const MonkBookingItem({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.slot,
    required this.status,
    this.date,
    this.amount,
    this.paid = false,
    this.bankTransferPending = false,
  });

  final String id;
  final String clientName;
  final String serviceName;
  final String slot;
  final String status;
  final String? date;
  final int? amount;
  final bool paid;
  final bool bankTransferPending;

  factory MonkBookingItem.fromJson(Map<String, dynamic> json) {
    return MonkBookingItem(
      id: json['id'] as String? ?? json['_id'] as String,
      clientName: json['clientName'] as String? ??
          json['client']?['name'] as String? ??
          '',
      serviceName: json['serviceName'] as String? ??
          json['service']?['name'] as String? ??
          '',
      slot: json['slot'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      date: json['date'] as String?,
      amount: (json['amount'] as num?)?.toInt(),
      paid: json['paid'] as bool? ?? false,
      bankTransferPending: json['bankTransferPending'] as bool? ?? false,
    );
  }
}
