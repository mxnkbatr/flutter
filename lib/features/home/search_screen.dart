import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/features/home/home_screen.dart';
import 'package:sacred_app/features/home/providers/search_provider.dart';
import 'package:sacred_app/features/home/widgets/explore_monk_card.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';

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

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(debouncedSearchProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final favorites = ref.watch(favoriteMonksProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.textPri,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.pop();
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Хайх',
                      style: AppText.h2.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Container(
                height: 56,
                padding: const EdgeInsets.only(left: 20, right: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceEl,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        focusNode: _focusNode,
                        autofocus: true,
                        style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Лам, хийд, үйлчилгээ...',
                          hintStyle: AppText.body.copyWith(
                            color: AppColors.textSec,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: _onQueryChanged,
                        onSubmitted: (q) async {
                          if (q.trim().isNotEmpty) {
                            await ref
                                .read(recentSearchesProvider.notifier)
                                .add(q);
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
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        final q = _searchCtrl.text.trim();
                        if (q.isNotEmpty) {
                          ref.read(recentSearchesProvider.notifier).add(q);
                        }
                        _focusNode.unfocus();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppGradients.sun,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: query.isEmpty
                  ? _RecentSearches(
                      onSelect: (q) {
                        _searchCtrl.text = q;
                        _onQueryChanged(q);
                      },
                    )
                  : _SearchResults(
                      query: query,
                      resultsAsync: resultsAsync,
                      favorites: favorites,
                      onMonkTap: (monk) => _openMonk(monk, query),
                      onFavorite: (id) {
                        final current = {...ref.read(favoriteMonksProvider)};
                        if (current.contains(id)) {
                          current.remove(id);
                        } else {
                          current.add(id);
                        }
                        ref.read(favoriteMonksProvider.notifier).state =
                            current;
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSearches extends ConsumerWidget {
  const _RecentSearches({required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentSearchesProvider);

    if (recent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppGradients.sunSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 32,
                color: AppColors.sunGold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Лам хайх', style: AppText.h3),
            const SizedBox(height: 4),
            Text(
              'Нэр, хийд эсвэл үйлчилгээгээр хайна',
              style: AppText.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Сүүлийн хайлт', style: AppText.h3),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(recentSearchesProvider.notifier).clear();
              },
              child: Text(
                'Цэвэрлэх',
                style: AppText.bodySmall.copyWith(color: AppColors.sunGold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recent.map(
          (q) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceEl,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading: const Icon(
                Icons.history_rounded,
                color: AppColors.sunGold,
                size: 22,
              ),
              title: Text(q, style: AppText.body),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.textSec),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(recentSearchesProvider.notifier).remove(q);
                },
              ),
              onTap: () {
                HapticFeedback.lightImpact();
                onSelect(q);
              },
            ),
          ),
        ),
      ],
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
        child: CircularProgressIndicator(color: AppColors.sunGold),
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
                const Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: AppColors.sunGold,
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
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: monks.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${monks.length} лам олдлоо',
                  style: AppText.body.copyWith(fontWeight: FontWeight.w600),
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
