import 'package:dio/dio.dart';
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

Future<void> reorderMonks(WidgetRef ref, List<String> monkIds) async {
  await ref.read(apiClientProvider).put(
        '/admin/monks/reorder',
        data: {'ids': monkIds},
      );
  ref.invalidate(adminMonksProvider);
  ref.invalidate(adminDashboardProvider);
}

Future<void> deleteMonk(
  WidgetRef ref,
  String monkId, {
  bool force = false,
}) async {
  await ref.read(apiClientProvider).delete(
        '/admin/monks/$monkId',
        queryParameters: force ? {'force': '1'} : null,
      );
  ref.invalidate(adminDashboardProvider);
  ref.invalidate(adminMonksProvider);
  ref.invalidate(adminMonkDetailProvider(monkId));
}

Future<void> deleteMonkWithForceIfNeeded(
  WidgetRef ref,
  String monkId, {
  required Future<bool?> Function(String message) confirmForce,
}) async {
  try {
    await deleteMonk(ref, monkId);
  } on DioException catch (e) {
    final data = e.response?.data;
    final code = data is Map ? data['code'] as String? : null;
    if (code == 'ACTIVE_BOOKINGS') {
      final msg = data is Map
          ? (data['error'] as String? ?? 'Идэвхтэй захиалга байна')
          : 'Идэвхтэй захиалга байна';
      final force = await confirmForce(msg);
      if (force == true) {
        await deleteMonk(ref, monkId, force: true);
        return;
      }
      rethrow;
    }
    rethrow;
  }
}

Future<void> deleteUser(
  WidgetRef ref,
  String userId, {
  bool force = false,
}) async {
  await ref.read(apiClientProvider).delete(
        '/admin/users/$userId',
        queryParameters: force ? {'force': '1'} : null,
      );
  ref.invalidate(adminUsersProvider);
  ref.invalidate(adminDashboardProvider);
}

Future<void> deleteUserWithForceIfNeeded(
  WidgetRef ref,
  String userId, {
  required Future<bool?> Function(String message) confirmForce,
}) async {
  try {
    await deleteUser(ref, userId);
  } on DioException catch (e) {
    final data = e.response?.data;
    final code = data is Map ? data['code'] as String? : null;
    if (code == 'ACTIVE_BOOKINGS') {
      final msg = data is Map
          ? (data['error'] as String? ?? 'Идэвхтэй захиалга байна')
          : 'Идэвхтэй захиалга байна';
      final force = await confirmForce(msg);
      if (force == true) {
        await deleteUser(ref, userId, force: true);
        return;
      }
      rethrow;
    }
    rethrow;
  }
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

Future<void> approveBooking(WidgetRef ref, String bookingId) async {
  await ref.read(apiClientProvider).put('/admin/bookings/$bookingId/approve');
  ref.invalidate(adminBookingsProvider);
}

Future<void> rejectBooking(WidgetRef ref, String bookingId) async {
  await ref.read(apiClientProvider).put('/admin/bookings/$bookingId/reject');
  ref.invalidate(adminBookingsProvider);
}

Future<void> confirmBookingPayment(WidgetRef ref, String bookingId) async {
  await ref.read(apiClientProvider).put('/admin/bookings/$bookingId/confirm-payment');
  ref.invalidate(adminBookingsProvider);
}

final adminFinanceProvider = FutureProvider<AdminFinanceData>((ref) async {
  final month = ref.watch(selectedAdminFinanceMonthProvider);
  final res = await ref.read(apiClientProvider).get(
        '/admin/finance',
        queryParameters: {'month': month},
      );
  return AdminFinanceData.fromJson(res.data as Map<String, dynamic>);
});
