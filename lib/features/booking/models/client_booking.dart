class ClientBooking {
  const ClientBooking({
    required this.id,
    required this.monkId,
    required this.monkName,
    required this.serviceName,
    required this.slot,
    required this.status,
    this.date,
    this.amount,
    this.monkImage,
    this.paid = false,
    this.reviewed = false,
    this.bankTransferPending = false,
  });

  final String id;
  final String monkId;
  final String monkName;
  final String serviceName;
  final String slot;
  final String status;
  final String? date;
  final int? amount;
  final String? monkImage;
  final bool paid;
  final bool reviewed;
  final bool bankTransferPending;

  bool get canJoinCall => paid && status == 'confirmed';

  factory ClientBooking.fromJson(Map<String, dynamic> json) {
    return ClientBooking(
      id: json['id'] as String? ?? json['_id'] as String,
      monkId: json['monkId'] as String? ?? '',
      monkName: json['monkName'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      slot: json['slot'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      date: json['date'] as String?,
      amount: (json['amount'] as num?)?.toInt(),
      monkImage: json['monkImage'] as String?,
      paid: json['paid'] as bool? ?? false,
      reviewed: json['reviewed'] as bool? ?? false,
      bankTransferPending: json['bankTransferPending'] as bool? ?? false,
    );
  }
}
