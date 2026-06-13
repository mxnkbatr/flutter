import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/features/payment/models/booking_payment_data.dart';
import 'package:sacred_app/features/payment/models/qpay_data.dart';

final bookingPaymentProvider =
    FutureProvider.family<BookingPaymentData, String>((ref, bookingId) async {
  final res = await ref.read(apiClientProvider).get('/payment/booking/$bookingId');
  return BookingPaymentData.fromJson(res.data as Map<String, dynamic>);
});

Future<QPayData> createBookingQPayInvoice(
  WidgetRef ref, {
  required String bookingId,
  required int amount,
  required BookingPaymentData payment,
}) async {
  final res = await ref.read(apiClientProvider).post(
        '/payment/qpay/create',
        data: {'bookingId': bookingId, 'amount': amount},
      );
  return QPayData.fromJson(res.data as Map<String, dynamic>).copyWithSummary(
    monkName: payment.monkName,
    monkImage: payment.monkImage,
    serviceName: payment.serviceName,
    timeSlot: payment.slot,
    dateStr: payment.date,
  );
}
