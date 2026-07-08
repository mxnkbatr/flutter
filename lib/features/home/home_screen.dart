import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: ExploreSearchBar(
                      hint: 'Лам хайх...',
                      minimal: true,
                      onTap: () => context.push('/search'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
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
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Text('Лам олдсонгүй', style: AppText.bodySmall),
                          ),
                        ),
                      );
                    }

                    final specialMonks = monks.where((m) => m.isSpecial).toList();
                    final featured =
                        specialMonks.isNotEmpty ? specialMonks.first : monks.first;
                    final rest = monks.where((m) => m.id != featured.id).toList();

                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPad),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          FeaturedDiscoveryCard(
                            monk: featured,
                            isFavorite: favorites.contains(featured.id),
                            onFavorite: () => _toggleFavorite(featured.id),
                            onTap: () => _openMonk(context, featured),
                          ),
                          if (rest.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            _SectionHeader(count: monks.length),
                            const SizedBox(height: 16),
                            ...rest.map(
                              (monk) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ExploreMonkCard(
                                  monk: monk,
                                  isFavorite: favorites.contains(monk.id),
                                  onFavorite: () => _toggleFavorite(monk.id),
                                  onTap: () => _openMonk(context, monk),
                                ),
                              ),
                            ),
                          ],
                        ]),
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
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.orange.withOpacity(0.14),
                    AppColors.orange.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: -80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.orangePeach.withOpacity(0.5),
                    AppColors.orangePeach.withOpacity(0),
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
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.orange, AppColors.orangeDeep],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Бусад ламнар',
          style: AppText.displaySerif(size: 20),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.orangeSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count лам',
            style: AppText.caption.copyWith(
              color: AppColors.orangeDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
