import 'package:intl/intl.dart';

class Formatters {
  static final _currency = NumberFormat.currency(
    locale: 'mn_MN',
    symbol: '₮',
    decimalDigits: 0,
  );

  static String currency(num amount) => _currency.format(amount);

  /// Monk net earnings: (booking × 0.80) − QPay fee (1.5% of total)
  static double monkNetEarning(double bookingAmount) {
    final monkShare = bookingAmount * 0.80;
    final qpayFee = bookingAmount * 0.015;
    return monkShare - qpayFee;
  }
}
