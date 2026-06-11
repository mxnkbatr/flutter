import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/features/booking/models/client_booking.dart';

final myBookingsProvider = FutureProvider<List<ClientBooking>>((ref) async {
  final month = DateFormat('yyyy-MM').format(DateTime.now());
  final res = await ref.read(apiClientProvider).get(
        '/bookings',
        queryParameters: {'month': month},
      );
  final list = res.data is List
      ? res.data as List
      : (res.data as Map<String, dynamic>)['bookings'] as List? ?? [];
  return list
      .map((e) => ClientBooking.fromJson(e as Map<String, dynamic>))
      .toList();
});
