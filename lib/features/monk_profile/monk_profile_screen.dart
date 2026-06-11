import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/formatters.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/features/monk_profile/providers/monk_profile_provider.dart';
import 'package:sacred_app/features/monk_profile/widgets/expandable_text.dart';
import 'package:sacred_app/features/monk_profile/widgets/profile_back_button.dart';
import 'package:sacred_app/features/monk_profile/widgets/profile_icon_button.dart';
import 'package:sacred_app/features/monk_profile/widgets/profile_stat_item.dart';
import 'package:sacred_app/features/monk_profile/widgets/review_tile.dart';
import 'package:sacred_app/features/monk_profile/widgets/service_card.dart';
import 'package:sacred_app/features/monk_profile/widgets/weekly_availability.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_divider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class MonkProfileScreen extends ConsumerStatefulWidget {
  const MonkProfileScreen({super.key, required this.monkId});

  final String monkId;

  @override
  ConsumerState<MonkProfileScreen> createState() => _MonkProfileScreenState();
}

class _MonkProfileScreenState extends ConsumerState<MonkProfileScreen> {
  bool _bookmarked = false;

  Future<void> _shareProfile(String name) async {
    final url = Uri.parse('https://sacred.mn/monks/${widget.monkId}');
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Холбоос хуулагдлаа')),
      );
    }
  }

  Future<void> _bookMonk(Monk monk) async {
    final ok = await TierGating.checkMonkAccess(context, ref, monk);
    if (ok && mounted) {
      context.go('/booking/${widget.monkId}');
    }
  }

  Future<void> _bookService(Monk monk, String serviceId) async {
    final ok = await TierGating.checkMonkAccess(context, ref, monk);
    if (ok && mounted) {
      context.go('/booking/${widget.monkId}?serviceId=$serviceId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final monkAsync = ref.watch(monkDetailProvider(widget.monkId));
    final servicesAsync = ref.watch(monkServicesProvider(widget.monkId));
    final reviewsAsync = ref.watch(monkReviewsProvider(widget.monkId));

    return monkAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.goldPrime),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Ламын профайл')),
        body: Center(child: Text('Алдаа: $e', style: AppText.bodySmall)),
      ),
      data: (monk) {
        final services = servicesAsync.valueOrNull ?? [];
        final reviews = reviewsAsync.valueOrNull ?? [];
        final startingPrice = services.isNotEmpty
            ? services.first.price
            : monk.startingPrice;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    stretch: true,
                    backgroundColor: AppColors.inkDeep,
                    automaticallyImplyLeading: false,
                    leading: const ProfileBackButton(),
                    actions: [
                      ProfileIconButton(
                        icon: Icons.ios_share_rounded,
                        onPressed: () => _shareProfile(monk.displayName),
                      ),
                      ProfileIconButton(
                        icon: _bookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        onPressed: () {
                          setState(() => _bookmarked = !_bookmarked);
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [StretchMode.zoomBackground],
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (monk.image != null)
                            Hero(
                              tag: Monk.heroTag(widget.monkId),
                              child: CachedNetworkImage(
                                imageUrl: monk.image!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Shimmer.fromColors(
                                  baseColor: AppColors.inkMid,
                                  highlightColor: AppColors.inkLight,
                                  child: const ColoredBox(
                                    color: AppColors.inkMid,
                                  ),
                                ),
                                errorWidget: (_, __, ___) => const ColoredBox(
                                  color: AppColors.inkMid,
                                  child: Icon(
                                    Icons.temple_buddhist_outlined,
                                    size: 64,
                                    color: AppColors.goldPrime,
                                  ),
                                ),
                              ),
                            )
                          else
                            const ColoredBox(
                              color: AppColors.inkMid,
                              child: Icon(
                                Icons.temple_buddhist_outlined,
                                size: 64,
                                color: AppColors.goldPrime,
                              ),
                            ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.4, 1.0],
                                colors: [
                                  AppColors.transparent,
                                  AppColors.inkDeep,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (monk.isAvailable)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.success,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: AppColors.success,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Боломжтой',
                                          style: AppText.caption.copyWith(
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Text(
                                  monk.displayName,
                                  style: AppText.h1.copyWith(
                                    color: AppColors.onDark,
                                    fontSize: 26,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  monk.temple ?? '',
                                  style: AppText.bodySmall.copyWith(
                                    color: AppColors.goldMuted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ...List.generate(5, (i) {
                                      return Icon(
                                        Icons.star_rounded,
                                        size: 16,
                                        color: i < monk.rating.floor()
                                            ? AppColors.goldPrime
                                            : AppColors.goldMuted
                                                .withOpacity(0.4),
                                      );
                                    }),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${monk.rating.toStringAsFixed(1)} (${monk.reviewCount})',
                                      style: AppText.bodySmall.copyWith(
                                        color: AppColors.onDarkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      color: AppColors.surfaceEl,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            ProfileStatItem(
                              value: '${monk.completedBookings > 0 ? monk.completedBookings : monk.reviewCount}+',
                              label: 'Захиалга',
                            ),
                            const ProfileVerticalDivider(),
                            ProfileStatItem(
                              value: monk.rating.toStringAsFixed(1),
                              label: 'Үнэлгээ',
                              accent: true,
                            ),
                            const ProfileVerticalDivider(),
                            const ProfileStatItem(
                              value: '< 1 цаг',
                              label: 'Хариу хугацаа',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Танилцуулга', style: AppText.h3),
                          const SizedBox(height: 8),
                          ExpandableText(
                            text: monk.bioText ?? '',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Үйлчилгээнүүд', style: AppText.h3),
                    ),
                  ),
                  servicesAsync.when(
                    loading: () => const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.goldPrime,
                          ),
                        ),
                      ),
                    ),
                    error: (_, __) => const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Үйлчилгээ ачаалахад алдаа гарлаа',
                          style: AppText.bodySmall,
                        ),
                      ),
                    ),
                    data: (serviceList) {
                      if (serviceList.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Үйлчилгээ байхгүй',
                              style: AppText.bodySmall,
                            ),
                          ),
                        );
                      }
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        sliver: SliverList.separated(
                          itemCount: serviceList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => ServiceCard(
                            service: serviceList[i],
                            onTap: () => _bookService(
                              monk,
                              serviceList[i].id,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Text('Хуваарь', style: AppText.h3),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: WeeklyAvailability(monkId: widget.monkId),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Сэтгэгдлүүд', style: AppText.h3),
                          TextButton(
                            onPressed: () => HapticFeedback.lightImpact(),
                            child: Text(
                              'Бүгд',
                              style: AppText.bodySmall.copyWith(
                                color: AppColors.goldPrime,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (reviews.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Сэтгэгдэл байхгүй',
                          style: AppText.bodySmall,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: MediaQuery.of(context).padding.bottom + 100,
                      ),
                      sliver: SliverList.separated(
                        itemCount: reviews.take(3).length,
                        separatorBuilder: (_, __) => const SacredDivider(),
                        itemBuilder: (_, i) => ReviewTile(review: reviews[i]),
                      ),
                    ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    MediaQuery.of(context).padding.bottom + 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (startingPrice != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Formatters.currency(startingPrice),
                              style: AppText.price,
                            ),
                            Text('эхлэх үнэ', style: AppText.caption),
                          ],
                        ),
                      if (startingPrice != null) const SizedBox(width: 16),
                      Expanded(
                        child: SacredButton(
                          label: 'Цаг захиалах',
                          onTap: () => _bookMonk(monk),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
