import 'package:sacred_app/features/booking/models/client_booking.dart';

enum BookingListFilter { pending, active, history, all }

extension BookingListFilterX on BookingListFilter {
  String get label => switch (this) {
        BookingListFilter.pending => 'Хүлээгдэж буй',
        BookingListFilter.active => 'Идэвхтэй',
        BookingListFilter.history => 'Түүх',
        BookingListFilter.all => 'Бүгд',
      };

  static BookingListFilter? fromQuery(String? value) {
    switch (value) {
      case 'pending':
        return BookingListFilter.pending;
      case 'active':
        return BookingListFilter.active;
      case 'history':
        return BookingListFilter.history;
      default:
        return null;
    }
  }
}

bool bookingIsPending(ClientBooking booking) {
  return booking.status == 'pending' || booking.status == 'approved';
}

bool bookingIsActive(ClientBooking booking) {
  return booking.status == 'confirmed';
}

bool bookingIsHistory(ClientBooking booking) {
  return booking.status == 'completed' || booking.status == 'cancelled';
}

class BookingSummaryCounts {
  const BookingSummaryCounts({
    required this.pending,
    required this.active,
    required this.history,
  });

  final int pending;
  final int active;
  final int history;

  factory BookingSummaryCounts.fromBookings(List<ClientBooking> bookings) {
    var pending = 0;
    var active = 0;
    var history = 0;
    for (final b in bookings) {
      if (bookingIsPending(b)) {
        pending++;
      } else if (bookingIsActive(b)) {
        active++;
      } else if (bookingIsHistory(b)) {
        history++;
      }
    }
    return BookingSummaryCounts(
      pending: pending,
      active: active,
      history: history,
    );
  }
}

List<ClientBooking> filterBookings(
  List<ClientBooking> bookings,
  BookingListFilter? filter,
) {
  if (filter == null || filter == BookingListFilter.all) return bookings;
  return bookings.where((b) {
    return switch (filter) {
      BookingListFilter.pending => bookingIsPending(b),
      BookingListFilter.active => bookingIsActive(b),
      BookingListFilter.history => bookingIsHistory(b),
      BookingListFilter.all => true,
    };
  }).toList();
}
