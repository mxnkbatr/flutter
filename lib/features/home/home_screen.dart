import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/features/home/providers/monks_provider.dart';
import 'package:sacred_app/features/home/widgets/category_chip.dart';
import 'package:sacred_app/features/home/widgets/explore_monk_card.dart';
import 'package:sacred_app/features/home/widgets/explore_search_bar.dart';
import 'package:sacred_app/features/home/widgets/featured_discovery_card.dart';
import 'package:sacred_app/features/home/widgets/home_error_view.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';
import 'package:sacred_app/shared/widgets/app_modal_sheet.dart';
import 'package:sacred_app/shared/widgets/monk_card_shimmer.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';

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
    showAppModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceEl,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final monksAsync = ref.watch(monksNotifierProvider);
    final selectedCategory = ref.watch(monkCategoryFilterProvider);
    final favorites = ref.watch(favoriteMonksProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 88;

    return PremiumLayeredScaffold(
      subtitle: 'Сайн байна уу,',
      title: auth?.userName ?? 'Зочин',
      headerHeight: 196,
      onRefresh: () async {
        ref.invalidate(monksNotifierProvider);
        ref.invalidate(recommendedMonksProvider);
        await ref.read(monksNotifierProvider.future);
      },
      trailing: GestureDetector(
        onTap: () => context.go('/profile'),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: Center(
            child: Text(
              (auth?.userName?.isNotEmpty ?? false)
                  ? auth!.userName![0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
      headerBottom: ExploreSearchBar(
        hint: 'Лам, хийд хайх...',
        onTap: () => context.push('/search'),
        onFilterTap: () => _showCategorySheet(selectedCategory),
        lightOnBlue: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
            loading: () => Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad),
              child: const Column(
                children: [
                  MonkCardShimmer(),
                  SizedBox(height: 16),
                  MonkCardShimmer(),
                ],
              ),
            ),
            error: (_, __) => HomeErrorView(
              onRetry: () => ref.invalidate(monksNotifierProvider),
            ),
            data: (monks) {
              if (monks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text('Лам олдсонгүй', style: AppText.bodySmall),
                  ),
                );
              }

              final featured = monks.firstWhere(
                (m) => m.isSpecial,
                orElse: () => monks.first,
              );
              final rest = monks.where((m) => m.id != featured.id).toList();

              return Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FeaturedDiscoveryCard(
                      monk: featured,
                      isFavorite: favorites.contains(featured.id),
                      onFavorite: () => _toggleFavorite(featured.id),
                      onTap: () => _openMonk(context, featured),
                    ),
                    if (rest.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Бусад ламнар', style: AppText.h3),
                          Text('${monks.length} илэрц', style: AppText.caption),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...rest.map(
                        (monk) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ExploreMonkCard(
                            monk: monk,
                            isFavorite: favorites.contains(monk.id),
                            onFavorite: () => _toggleFavorite(monk.id),
                            onTap: () => _openMonk(context, monk),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
