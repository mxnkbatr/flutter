import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/features/home/providers/monks_provider.dart';
import 'package:sacred_app/features/home/widgets/category_chip.dart';
import 'package:sacred_app/features/home/widgets/explore_monk_card.dart';
import 'package:sacred_app/features/home/widgets/explore_search_bar.dart';
import 'package:sacred_app/features/home/widgets/featured_discovery_card.dart';
import 'package:sacred_app/features/home/widgets/home_error_view.dart';
import 'package:sacred_app/core/providers/monk_categories_provider.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';
import 'package:sacred_app/shared/widgets/empty_state.dart';
import 'package:sacred_app/shared/widgets/monk_card_shimmer.dart';

const _defaultCategories = ['Ерөөл', 'Зурхай', 'Тахилга', 'Номын тайлбар'];

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
      context.push('/monks/${monk.id}');
    }
  }

  Future<void> _bookMonk(BuildContext context, Monk monk) async {
    final ok = await TierGating.checkMonkAccess(context, ref, monk);
    if (ok && context.mounted) {
      context.push('/booking/${monk.id}');
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

  @override
  Widget build(BuildContext context) {
    final monksAsync = ref.watch(monksNotifierProvider);
    final selectedCategory = ref.watch(monkCategoryFilterProvider);
    final favorites = ref.watch(favoriteMonksProvider);
    final categoryList = ref.watch(monkCategoriesProvider).valueOrNull ?? _defaultCategories;
    final categories = ['Бүгд', ...categoryList];
    final bottomPad = MediaQuery.of(context).padding.bottom + 100;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: Stack(
        children: [
          const _AmbientBackground(),
          RefreshIndicator(
            color: AppColors.orange,
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: ExploreSearchBar(
                      hint: 'Лам хайх...',
                      onTap: () => context.push('/search'),
                      onFilterTap: () => context.push('/search'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => CategoryChip(
                        label: categories[i],
                        isSelected: selectedCategory == categories[i],
                        onTap: () {
                          ref.read(monkCategoryFilterProvider.notifier).state =
                              categories[i];
                        },
                      ),
                    ),
                  ),
                ),
                monksAsync.when(
                  loading: () => SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPad),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const MonkCardShimmer(),
                        const SizedBox(height: 16),
                        const MonkCardShimmer(),
                      ]),
                    ),
                  ),
                  error: (_, __) => SliverToBoxAdapter(
                    child: HomeErrorView(
                      onRetry: () => ref.invalidate(monksNotifierProvider),
                    ),
                  ),
                  data: (monks) {
                    if (monks.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.self_improvement_outlined,
                          title: 'Лам олдсонгүй',
                          message: 'Шүүлтийг цэвэрлээд дахин хайна уу.',
                          actionLabel: selectedCategory == 'Бүгд'
                              ? null
                              : 'Бүгдийг харах',
                          onAction: selectedCategory == 'Бүгд'
                              ? null
                              : () {
                                  ref
                                      .read(monkCategoryFilterProvider.notifier)
                                      .state = 'Бүгд';
                                },
                        ),
                      );
                    }

                    final specialMonks = monks.where((m) => m.isSpecial).toList();
                    final featured =
                        specialMonks.isNotEmpty ? specialMonks.first : monks.first;
                    final rest = monks.where((m) => m.id != featured.id).toList();

                    // Lazy build: featured + header + rest (only visible cards).
                    final childCount = rest.isEmpty ? 1 : 2 + rest.length;
                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPad),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == 0) {
                              return FeaturedDiscoveryCard(
                                monk: featured,
                                isFavorite: favorites.contains(featured.id),
                                onFavorite: () => _toggleFavorite(featured.id),
                                onTap: () => _openMonk(context, featured),
                                onBook: () => _bookMonk(context, featured),
                              );
                            }
                            if (index == 1) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 32, bottom: 16),
                                child: _SectionHeader(count: monks.length),
                              );
                            }
                            final monk = rest[index - 2];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ExploreMonkCard(
                                monk: monk,
                                isFavorite: favorites.contains(monk.id),
                                onFavorite: () => _toggleFavorite(monk.id),
                                onTap: () => _openMonk(context, monk),
                                onBook: () => _bookMonk(context, monk),
                              ),
                            );
                          },
                          childCount: childCount,
                          addAutomaticKeepAlives: false,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.ambientCream),
            ),
          ),
          Positioned(
            top: -80,
            right: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.orange.withValues(alpha: 0.12),
                    AppColors.orange.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 220,
            left: -90,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.orangePeach.withValues(alpha: 0.45),
                    AppColors.orangePeach.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Бусад ламнар',
          style: AppText.displaySerif(size: 22),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.orangeSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSub),
          ),
          child: Text(
            '$count',
            style: AppText.caption.copyWith(
              color: AppColors.orangeDeep,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
