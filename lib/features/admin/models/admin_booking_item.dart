class AdminBookingItem {
  const AdminBookingItem({
    required this.id,
    required this.clientName,
    required this.monkName,
    required this.serviceName,
    required this.amount,
    required this.status,
    this.date = '',
    this.slot = '',
    this.paid = false,
  });

  final String id;
  final String clientName;
  final String monkName;
  final String serviceName;
  final int amount;
  final String status;
  final String date;
  final String slot;
  final bool paid;

  factory AdminBookingItem.fromJson(Map<String, dynamic> json) {
    return AdminBookingItem(
      id: json['id'] as String? ?? json['_id'] as String,
      clientName: json['clientName'] as String? ??
          json['client']?['name'] as String? ??
          '',
      monkName: json['monkName'] as String? ??
          json['monk']?['name'] as String? ??
          '',
      serviceName: json['serviceName'] as String? ??
          json['service']?['name'] as String? ??
          '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      date: json['date'] as String? ?? '',
      slot: json['slot'] as String? ?? '',
      paid: json['paid'] as bool? ?? false,
    );
  }
}
