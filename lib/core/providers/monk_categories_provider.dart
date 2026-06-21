import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';

/// Public monk category names for home/search filters.
final monkCategoriesProvider = FutureProvider<List<String>>((ref) async {
  try {
    final res = await ref.read(apiClientProvider).get('/categories');
    final list = res.data as List<dynamic>? ?? [];
    return list.map((e) => e.toString()).toList();
  } catch (_) {
    return const ['Ерөөл', 'Зурхай', 'Тахилга', 'Номын тайлбар'];
  }
});

class AdminCategory {
  const AdminCategory({
    required this.id,
    required this.name,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final int sortOrder;

  factory AdminCategory.fromJson(Map<String, dynamic> json) {
    return AdminCategory(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}

final adminCategoriesProvider =
    FutureProvider<List<AdminCategory>>((ref) async {
  final res = await ref.read(apiClientProvider).get('/admin/categories');
  final list = res.data as List<dynamic>? ?? [];
  return list
      .map((e) => AdminCategory.fromJson(e as Map<String, dynamic>))
      .toList();
});

Future<void> addMonkCategory(WidgetRef ref, String name) async {
  await ref.read(apiClientProvider).post('/admin/categories', data: {'name': name});
  ref.invalidate(adminCategoriesProvider);
  ref.invalidate(monkCategoriesProvider);
}

Future<void> deleteMonkCategory(WidgetRef ref, String id) async {
  await ref.read(apiClientProvider).delete('/admin/categories/$id');
  ref.invalidate(adminCategoriesProvider);
  ref.invalidate(monkCategoriesProvider);
}
