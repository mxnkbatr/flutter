import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/providers/monk_categories_provider.dart';
import 'package:sacred_app/features/home/home_screen.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/features/home/providers/monks_provider.dart';
import 'package:sacred_app/features/home/providers/search_provider.dart';
import 'package:sacred_app/features/home/widgets/category_chip.dart';
import 'package:sacred_app/features/home/widgets/explore_monk_card.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';
import 'package:sacred_app/shared/widgets/native_app_header.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';

const _defaultSearchCategories = ['Ерөөл', 'Зурхай', 'Тахилга', 'Номын тайлбар'];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String q) {
    ref.read(searchInputProvider.notifier).state = q;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(debouncedSearchProvider.notifier).state = q;
    });
  }

  void _clear() {
    HapticFeedback.lightImpact();
    _searchCtrl.clear();
    ref.read(searchInputProvider.notifier).state = '';
    ref.read(debouncedSearchProvider.notifier).state = '';
    _focusNode.requestFocus();
  }

  Future<void> _openMonk(Monk monk, String query) async {
    final ok = await TierGating.checkMonkAccess(context, ref, monk);
    if (!ok) return;
    if (query.trim().isNotEmpty) {
      await ref.read(recentSearchesProvider.notifier).add(query);
    }
    if (!mounted) return;
    context.push('/monks/${monk.id}');
  }

  void _showSortSheet() {
    HapticFeedback.lightImpact();
    final sorts = ['Үнэлгээ', 'Үнэ (доош)', 'Үнэ (дээш)', 'Шинэ'];
    final current = ref.read(monkSortFilterProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceEl,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Эрэмбэлэх', style: AppText.h3),
            ),
            ...sorts.map(
              (s) => ListTile(
                title: Text(s),
                trailing: s == current
                    ? const Icon(Icons.check_rounded, color: AppColors.orange)
                    : null,
                onTap: () {
                  ref.read(monkSortFilterProvider.notifier).state = s;
                  ref.invalidate(monksNotifierProvider);
                  Navigator.pop(ctx);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(debouncedSearchProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final categoryList = ref.watch(monkCategoriesProvider).valueOrNull ?? _defaultSearchCategories;
    final categories = ['Бүгд', ...categoryList];
    final monksAsync = ref.watch(monksNotifierProvider);
    final selectedCategory = ref.watch(monkCategoryFilterProvider);
    final favorites = ref.watch(favoriteMonksProvider);
    final hasQuery = query.trim().isNotEmpty;

    return PremiumLayeredScaffold(
      title: 'Лам нар',
      showBackButton: true,
      useNativeNavBar: true,
      trailing: NativeHeaderIconButton(
        icon: Icons.tune_rounded,
        onTap: _showSortSheet,
      ),
      sheetTopContent: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = categories[i];
            return CategoryChip(
              label: cat,
              isSelected: cat == selectedCategory,
              onTap: () {
                ref.read(monkCategoryFilterProvider.notifier).state = cat;
                ref.invalidate(monksNotifierProvider);
              },
            );
          },
        ),
      ),
      headerBottom: Container(
        height: 52,
        padding: const EdgeInsets.only(left: 16, right: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderSub, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.search_rounded, color: AppColors.textSec, size: 22),
            ),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                focusNode: _focusNode,
                autofocus: true,
                style: AppText.body.copyWith(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Лам, хийд хайх...',
                  hintStyle: AppText.body.copyWith(
                    color: AppColors.textSec,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onChanged: _onQueryChanged,
                onSubmitted: (q) async {
                  if (q.trim().isNotEmpty) {
                    await ref.read(recentSearchesProvider.notifier).add(q);
                  }
                },
              ),
            ),
            if (_searchCtrl.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textSec,
                onPressed: _clear,
              ),
          ],
        ),
      ),
      expandBody: true,
      body: hasQuery
          ? _SearchResults(
              query: query,
              resultsAsync: resultsAsync,
              favorites: favorites,
              onMonkTap: (monk) => _openMonk(monk, query),
              onFavorite: (id) => _toggleFavorite(id),
            )
          : _MonkBrowseList(
              monksAsync: monksAsync,
              favorites: favorites,
              onMonkTap: (monk) => _openMonk(monk, ''),
              onFavorite: (id) => _toggleFavorite(id),
              onRetry: () => ref.invalidate(monksNotifierProvider),
            ),
    );
  }

  void _toggleFavorite(String id) {
    final current = {...ref.read(favoriteMonksProvider)};
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    ref.read(favoriteMonksProvider.notifier).state = current;
  }
}

class _MonkBrowseList extends StatelessWidget {
  const _MonkBrowseList({
    required this.monksAsync,
    required this.favorites,
    required this.onMonkTap,
    required this.onFavorite,
    required this.onRetry,
  });

  final AsyncValue<List<Monk>> monksAsync;
  final Set<String> favorites;
  final ValueChanged<Monk> onMonkTap;
  final ValueChanged<String> onFavorite;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return monksAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      ),
      error: (_, __) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Алдаа гарлаа', style: AppText.bodySmall),
            TextButton(onPressed: onRetry, child: const Text('Дахин оролдох')),
          ],
        ),
      ),
      data: (monks) {
        if (monks.isEmpty) {
          return Center(
            child: Text('Лам олдсонгүй', style: AppText.bodySmall),
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: monks.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${monks.length} лам олдлоо',
                  style: AppText.caption.copyWith(
                    color: AppColors.textSec,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            final monk = monks[index - 1];
            return ExploreMonkCard(
              monk: monk,
              isFavorite: favorites.contains(monk.id),
              onFavorite: () => onFavorite(monk.id),
              onTap: () => onMonkTap(monk),
            );
          },
        );
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.query,
    required this.resultsAsync,
    required this.favorites,
    required this.onMonkTap,
    required this.onFavorite,
  });

  final String query;
  final AsyncValue<List<Monk>> resultsAsync;
  final Set<String> favorites;
  final ValueChanged<Monk> onMonkTap;
  final ValueChanged<String> onFavorite;

  @override
  Widget build(BuildContext context) {
    return resultsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      ),
      error: (e, _) => Center(
        child: Text('Алдаа гарлаа', style: AppText.bodySmall),
      ),
      data: (monks) {
        if (monks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: AppColors.orange.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text('Олдсонгүй', style: AppText.h3),
                const SizedBox(height: 4),
                Text(
                  '"$query" — илэрц олдсонгүй',
                  style: AppText.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: monks.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${monks.length} лам олдлоо',
                  style: AppText.caption.copyWith(
                    color: AppColors.textSec,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            final monk = monks[index - 1];
            return ExploreMonkCard(
              monk: monk,
              isFavorite: favorites.contains(monk.id),
              onFavorite: () => onFavorite(monk.id),
              onTap: () => onMonkTap(monk),
            );
          },
        );
      },
    );
  }
}
