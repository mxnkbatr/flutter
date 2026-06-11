import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/features/home/providers/monks_provider.dart';

final searchInputProvider = StateProvider<String>((ref) => '');

final debouncedSearchProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<AsyncValue<List<Monk>>>((ref) {
  final query = ref.watch(debouncedSearchProvider).trim().toLowerCase();
  if (query.isEmpty) return const AsyncData([]);

  final monksAsync = ref.watch(monksNotifierProvider);
  return monksAsync.when(
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
    data: (monks) {
      final results = monks.where((m) {
        return m.displayName.toLowerCase().contains(query) ||
            (m.temple?.toLowerCase().contains(query) ?? false) ||
            m.categories.any((c) => c.toLowerCase().contains(query));
      }).toList();
      return AsyncData(results);
    },
  );
});

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super([]) {
    _load();
  }

  static const _key = 'recent_monk_searches';
  static const _max = 8;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_key) ?? [];
  }

  Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final updated = [
      trimmed,
      ...state.where((s) => s.toLowerCase() != trimmed.toLowerCase()),
    ].take(_max).toList();

    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated);
  }

  Future<void> remove(String query) async {
    state = state.where((s) => s != query).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state);
  }

  Future<void> clear() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>(
  (ref) => RecentSearchesNotifier(),
);
