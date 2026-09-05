import 'package:intl/intl.dart';

class Formatters {
  static final _currency = NumberFormat.currency(
    locale: 'mn_MN',
    symbol: '₮',
    decimalDigits: 0,
  );

  static String currency(num amount) => _currency.format(amount);

  /// Monk salary: 70% of booking amount (platform keeps 30%; QPay is platform cost).
  static double monkNetEarning(double bookingAmount) {
    return bookingAmount * 0.70;
  }
}
