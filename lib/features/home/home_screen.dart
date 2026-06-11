import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/features/home/providers/monks_provider.dart';
import 'package:sacred_app/features/home/widgets/category_chip.dart';
import 'package:sacred_app/features/home/widgets/explore_filter_row.dart';
import 'package:sacred_app/features/home/widgets/explore_monk_card.dart';
import 'package:sacred_app/features/home/widgets/explore_search_bar.dart';
import 'package:sacred_app/features/home/widgets/home_error_view.dart';
import 'package:sacred_app/features/home/widgets/sort_button.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';
import 'package:sacred_app/shared/widgets/monk_card_shimmer.dart';

const _categories = ['Бүгд', 'Ерөөл', 'Зурхай', 'Тахилга', 'Номын тайлбар'];

final unreadNotificationsProvider = StateProvider<int>((ref) => 0);
final favoriteMonksProvider = StateProvider<Set<String>>((ref) => {});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _openMonk(BuildContext context, Monk monk) async {
    final ok = await TierGating.checkMonkAccess(context, ref, monk);
    if (ok && context.mounted) {
      context.go('/monks/${monk.id}');
    }
  }

  void _toggleFavorite(String monkId) {
    final current = {...ref.read(favoriteMonksProvider)};
    if (current.contains(monkId)) {
      current.remove(monkId);
    } else {
      current.add(monkId);
    }
    ref.read(favoriteMonksProvider.notifier).state = current;
  }

  void _showCategorySheet(String selected) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceEl,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Ангилал сонгох', style: AppText.h2),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  return CategoryChip(
                    label: cat,
                    isSelected: selected == cat,
                    onTap: () {
                      ref.read(monkCategoryFilterProvider.notifier).state = cat;
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortSheet(String current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceEl,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Эрэмбэлэх', style: AppText.h2),
              const SizedBox(height: 8),
              ...monkSortOptions.map((opt) {
                final isSelected = opt == current;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    opt,
                    style: AppText.body.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? AppColors.sunGold : AppColors.textPri,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: AppColors.sunGold)
                      : null,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(monkSortFilterProvider.notifier).state = opt;
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final monksAsync = ref.watch(monksNotifierProvider);
    final selectedCategory = ref.watch(monkCategoryFilterProvider);
    final sort = ref.watch(monkSortFilterProvider);
    final favorites = ref.watch(favoriteMonksProvider);
    final unreadCount = ref.watch(unreadNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        color: AppColors.sunGold,
        onRefresh: () async {
          ref.invalidate(monksNotifierProvider);
          ref.invalidate(recommendedMonksProvider);
          await ref.read(monksNotifierProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              elevation: 0,
              title: Text(
                'Хайх',
                style: AppText.h2.copyWith(fontWeight: FontWeight.w700),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.favorite_border_rounded,
                    color: favorites.isEmpty
                        ? AppColors.textPri
                        : AppColors.sunOrange,
                  ),
                  onPressed: () => HapticFeedback.lightImpact(),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textPri,
                      ),
                      onPressed: () => HapticFeedback.lightImpact(),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            gradient: AppGradients.sun,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (auth?.userName != null) ...[
                      Text(
                        'Сайн байна уу, ${auth!.userName}',
                        style: AppText.caption,
                      ),
                      const SizedBox(height: 12),
                    ],
                    ExploreSearchBar(
                      hint: 'Лам, хийд, үйлчилгээ...',
                      onTap: () => context.push('/search'),
                    ),
                    const SizedBox(height: 16),
                    ExploreFilterRow(
                      categoryLabel: selectedCategory,
                      sortLabel: sort,
                      onCategoryTap: () => _showCategorySheet(selectedCategory),
                      onSortTap: () => _showSortSheet(sort),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => CategoryChip(
                          label: _categories[i],
                          isSelected: selectedCategory == _categories[i],
                          onTap: () {
                            ref.read(monkCategoryFilterProvider.notifier).state =
                                _categories[i];
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    monksAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (monks) => Row(
                        children: [
                          Text(
                            '${monks.length} лам олдлоо',
                            style: AppText.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          _FiltersButton(
                            onTap: () => _showCategorySheet(selectedCategory),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            monksAsync.when(
              loading: () => SliverPadding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).padding.bottom + 100,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: MonkCardShimmer(),
                    ),
                    childCount: 3,
                  ),
                ),
              ),
              error: (_, __) => SliverToBoxAdapter(
                child: HomeErrorView(
                  onRetry: () => ref.invalidate(monksNotifierProvider),
                ),
              ),
              data: (monks) {
                if (monks.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text('Лам олдсонгүй', style: AppText.bodySmall),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).padding.bottom + 100,
                  ),
                  sliver: SliverList.separated(
                    itemCount: monks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) {
                      final monk = monks[i];
                      return ExploreMonkCard(
                        monk: monk,
                        isFavorite: favorites.contains(monk.id),
                        onFavorite: () => _toggleFavorite(monk.id),
                        onTap: () => _openMonk(context, monk),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersButton extends StatelessWidget {
  const _FiltersButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune_rounded, size: 16, color: AppColors.textPri),
              const SizedBox(width: 6),
              Text(
                'Шүүлтүүр',
                style: AppText.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
