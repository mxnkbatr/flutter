import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/features/monk_dash/models/monk_earnings_data.dart';

final selectedEarningsMonthProvider = StateProvider<String>((ref) {
  return DateFormat('yyyy-MM').format(DateTime.now());
});

final monkEarningsProvider = FutureProvider<MonkEarningsData>((ref) async {
  final month = ref.watch(selectedEarningsMonthProvider);
  final res = await ref.read(apiClientProvider).get(
        '/monk/salary',
        queryParameters: {'month': month},
      );
  return MonkEarningsData.fromJson(res.data as Map<String, dynamic>);
});
