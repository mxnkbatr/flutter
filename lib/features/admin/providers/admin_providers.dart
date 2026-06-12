import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/features/admin/models/admin_booking_item.dart';
import 'package:sacred_app/features/admin/models/admin_dashboard_data.dart';
import 'package:sacred_app/features/admin/models/admin_finance_data.dart';
import 'package:sacred_app/features/admin/models/admin_monk.dart';
import 'package:sacred_app/features/admin/models/admin_monk_detail.dart';
import 'package:sacred_app/features/admin/models/admin_user.dart';

final adminDashboardProvider = FutureProvider<AdminDashboardData>((ref) async {
  final res = await ref.read(apiClientProvider).get('/admin/dashboard');
  return AdminDashboardData.fromJson(res.data as Map<String, dynamic>);
});

final adminMonkFilterProvider = StateProvider<String>((ref) => 'all');

final adminMonksProvider =
    FutureProvider.family<List<AdminMonk>, String>((ref, status) async {
  final res = await ref.read(apiClientProvider).get(
        '/admin/monks',
        queryParameters: {'status': status},
      );
  final list = res.data is List
      ? res.data as List
      : (res.data as Map<String, dynamic>)['monks'] as List? ?? [];
  return list.map((e) => AdminMonk.fromJson(e as Map<String, dynamic>)).toList();
});

Future<void> approveMonk(WidgetRef ref, String monkId) async {
  await ref.read(apiClientProvider).post('/admin/monks/$monkId/approve');
  ref.invalidate(adminDashboardProvider);
  ref.invalidate(adminMonksProvider);
}

Future<void> rejectMonk(WidgetRef ref, String monkId) async {
  await ref.read(apiClientProvider).post('/admin/monks/$monkId/block');
  ref.invalidate(adminDashboardProvider);
  ref.invalidate(adminMonksProvider);
}

Future<void> createMonk(WidgetRef ref, Map<String, dynamic> data) async {
  await ref.read(apiClientProvider).post('/admin/monks', data: data);
  ref.invalidate(adminDashboardProvider);
  ref.invalidate(adminMonksProvider);
}

final adminMonkDetailProvider =
    FutureProvider.family<AdminMonkDetail, String>((ref, monkId) async {
  final res = await ref.read(apiClientProvider).get('/admin/monks/$monkId');
  return AdminMonkDetail.fromJson(res.data as Map<String, dynamic>);
});

Future<void> updateMonk(
  WidgetRef ref,
  String monkId,
  Map<String, dynamic> data,
) async {
  await ref.read(apiClientProvider).put('/admin/monks/$monkId', data: data);
  ref.invalidate(adminDashboardProvider);
  ref.invalidate(adminMonksProvider);
  ref.invalidate(adminMonkDetailProvider(monkId));
}

Future<void> deleteMonk(WidgetRef ref, String monkId) async {
  await ref.read(apiClientProvider).delete('/admin/monks/$monkId');
  ref.invalidate(adminDashboardProvider);
  ref.invalidate(adminMonksProvider);
  ref.invalidate(adminMonkDetailProvider(monkId));
}

final adminUsersProvider = FutureProvider<List<AdminUser>>((ref) async {
  final res = await ref.read(apiClientProvider).get('/admin/users');
  final list = res.data is List
      ? res.data as List
      : (res.data as Map<String, dynamic>)['users'] as List? ?? [];
  return list.map((e) => AdminUser.fromJson(e as Map<String, dynamic>)).toList();
});

final adminBookingFilterProvider = StateProvider<String>((ref) => 'all');

final adminBookingsProvider =
    FutureProvider.family<List<AdminBookingItem>, String>((ref, status) async {
  final res = await ref.read(apiClientProvider).get(
        '/admin/bookings',
        queryParameters:
            status != 'all' ? <String, dynamic>{'status': status} : null,
      );
  final list = res.data is List
      ? res.data as List
      : (res.data as Map<String, dynamic>)['bookings'] as List? ?? [];
  return list
      .map((e) => AdminBookingItem.fromJson(e as Map<String, dynamic>))
      .toList();
});

final selectedAdminFinanceMonthProvider = StateProvider<String>((ref) {
  return DateFormat('yyyy-MM').format(DateTime.now());
});

final adminFinanceProvider = FutureProvider<AdminFinanceData>((ref) async {
  final month = ref.watch(selectedAdminFinanceMonthProvider);
  final res = await ref.read(apiClientProvider).get(
        '/admin/finance',
        queryParameters: {'month': month},
      );
  return AdminFinanceData.fromJson(res.data as Map<String, dynamic>);
});
