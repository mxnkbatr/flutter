import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/features/home/models/monk.dart';

part 'monks_provider.g.dart';

final monkCategoryFilterProvider = StateProvider<String>((ref) => 'Бүгд');
final monkSortFilterProvider = StateProvider<String>((ref) => 'Үнэлгээ');
final monkSearchQueryProvider = StateProvider<String>((ref) => '');

String _sortParam(String sort) {
  switch (sort) {
    case 'Үнэ (доош)':
      return 'price_desc';
    case 'Үнэ (дээш)':
      return 'price_asc';
    case 'Шинэ':
      return 'newest';
    default:
      return 'rating';
  }
}

@riverpod
class MonksNotifier extends _$MonksNotifier {
  @override
  Future<List<Monk>> build() {
    final category = ref.watch(monkCategoryFilterProvider);
    final sort = ref.watch(monkSortFilterProvider);
    return _fetchMonks(category: category, sort: sort);
  }

  Future<List<Monk>> _fetchMonks({String? category, String? sort}) async {
    final res = await ref.read(apiClientProvider).get(
      '/monks',
      queryParameters: {
        if (category != null && category != 'Бүгд') 'category': category,
        if (sort != null) 'sort': _sortParam(sort),
      },
    );
    final list = res.data is List
        ? res.data as List
        : (res.data as Map<String, dynamic>)['monks'] as List? ?? [];
    return list
        .map((e) => Monk.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> filter(String category, String sort) async {
    ref.read(monkCategoryFilterProvider.notifier).state = category;
    ref.read(monkSortFilterProvider.notifier).state = sort;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchMonks(category: category, sort: sort),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

@riverpod
Future<List<Monk>> recommendedMonks(RecommendedMonksRef ref) async {
  final auth = ref.watch(authStateProvider).valueOrNull;
  final res = await ref.read(apiClientProvider).get(
        '/monks',
        queryParameters: {
          'recommended': true,
          if (auth?.userId != null) 'userId': auth!.userId,
          'limit': 3,
        },
      );
  final list = res.data is List
      ? res.data as List
      : (res.data as Map<String, dynamic>)['monks'] as List? ?? [];
  return list.map((e) => Monk.fromJson(e as Map<String, dynamic>)).toList();
}
