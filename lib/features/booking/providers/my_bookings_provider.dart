import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/features/booking/models/client_booking.dart';

final myBookingsProvider = FutureProvider<List<ClientBooking>>((ref) async {
  final res = await ref.read(apiClientProvider).get('/bookings');
  final list = res.data is List
      ? res.data as List
      : (res.data as Map<String, dynamic>)['bookings'] as List? ?? [];
  return list
      .map((e) => ClientBooking.fromJson(e as Map<String, dynamic>))
      .toList();
});
