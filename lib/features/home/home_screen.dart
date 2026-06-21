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
import 'package:sacred_app/features/notifications/providers/notifications_provider.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';
import 'package:sacred_app/shared/widgets/monk_card_shimmer.dart';
import 'package:sacred_app/shared/widgets/native_app_header.dart';

const _categories = ['Бүгд', 'Ерөөл', 'Зурхай', 'Тахилга', 'Номын тайлбар'];

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
    final auth = ref.watch(authStateProvider).valueOrNull;
    final monksAsync = ref.watch(monksNotifierProvider);
    final selectedCategory = ref.watch(monkCategoryFilterProvider);
    final favorites = ref.watch(favoriteMonksProvider);
    final unread = ref.watch(unreadNotificationsCountProvider);
    final top = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom + 88;
    final initial = (auth?.userName?.isNotEmpty ?? false)
        ? auth!.userName![0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: RefreshIndicator(
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
                padding: EdgeInsets.fromLTRB(20, top + 12, 20, 0),
                child: NativeLargeTitleHeader(
                  eyebrow: 'Сайн байна уу,',
                  title: auth?.userName ?? 'Зочин',
                  serifTitle: false,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NativeHeaderIconButton(
                        icon: Icons.notifications_outlined,
                        badgeCount: unread,
                        onTap: () => context.push('/notifications'),
                      ),
                      const SizedBox(width: 8),
                      NativeAvatarButton(
                        initial: initial,
                        onTap: () => context.go('/profile'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
            ),
            monksAsync.when(
              loading: () => SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
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
                  padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
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
                            Text(
                              'Бусад ламнар',
                              style: AppText.h3.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '${monks.length} лам олдлоо',
                              style: AppText.caption.copyWith(
                                color: AppColors.textSec,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
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
    );
  }
}
