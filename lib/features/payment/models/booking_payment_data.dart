import 'package:sacred_app/features/payment/models/qpay_data.dart';

class BankAccountInfo {
  const BankAccountInfo({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    this.iban = '',
  });

  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String iban;

  factory BankAccountInfo.fromJson(Map<String, dynamic> json) {
    return BankAccountInfo(
      bankName: json['bankName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      accountHolder: json['accountHolder'] as String? ?? '',
      iban: json['iban'] as String? ?? '',
    );
  }
}

class BookingPaymentData {
  const BookingPaymentData({
    required this.bookingId,
    required this.amount,
    required this.status,
    required this.paid,
    required this.monkName,
    required this.serviceName,
    required this.slot,
    required this.date,
    required this.bank,
    required this.reference,
    required this.canPay,
    required this.paymentPending,
    this.monkImage,
    this.clientName,
    this.qpay,
  });

  final String bookingId;
  final int amount;
  final String status;
  final bool paid;
  final String monkName;
  final String serviceName;
  final String slot;
  final String date;
  final String? monkImage;
  final String? clientName;
  final BankAccountInfo bank;
  final String reference;
  final bool canPay;
  final bool paymentPending;
  final QPayData? qpay;

  bool get canOpenPayment => canPay && !paid;

  factory BookingPaymentData.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'] as Map<String, dynamic>;
    final qpayRaw = json['qpay'] as Map<String, dynamic>?;
    QPayData? qpay;
    if (qpayRaw != null) {
      qpay = QPayData.fromJson(qpayRaw).copyWithSummary(
        monkName: booking['monkName'] as String?,
        monkImage: booking['monkImage'] as String?,
        serviceName: booking['serviceName'] as String?,
        timeSlot: booking['slot'] as String?,
        dateStr: booking['date'] as String?,
      );
    }

    final bankRaw = json['bank'];
    return BookingPaymentData(
      bookingId: booking['id'] as String? ?? '',
      amount: (booking['amount'] as num?)?.toInt() ?? 0,
      status: booking['status'] as String? ?? 'pending',
      paid: booking['paid'] as bool? ?? false,
      monkName: booking['monkName'] as String? ?? '',
      serviceName: booking['serviceName'] as String? ?? '',
      slot: booking['slot'] as String? ?? '',
      date: booking['date'] as String? ?? '',
      monkImage: booking['monkImage'] as String?,
      clientName: booking['clientName'] as String?,
      bank: bankRaw is Map<String, dynamic>
          ? BankAccountInfo.fromJson(bankRaw)
          : const BankAccountInfo(
              bankName: '',
              accountNumber: '',
              accountHolder: '',
            ),
      reference: json['reference'] as String? ?? '',
      canPay: json['canPay'] as bool? ?? false,
      paymentPending: json['paymentPending'] as bool? ?? false,
      qpay: qpay,
    );
  }
}
