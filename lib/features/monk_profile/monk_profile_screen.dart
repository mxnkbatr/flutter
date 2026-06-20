import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:sacred_app/core/theme/app_colors.dart';

import 'package:sacred_app/core/theme/app_gradients.dart';

import 'package:sacred_app/core/theme/app_text.dart';

import 'package:sacred_app/core/utils/error_messages.dart';

import 'package:sacred_app/core/utils/formatters.dart';

import 'package:sacred_app/features/home/models/monk.dart';

import 'package:sacred_app/features/messenger/providers/messenger_provider.dart';

import 'package:sacred_app/features/monk_profile/providers/monk_profile_provider.dart';

import 'package:sacred_app/features/monk_profile/widgets/expandable_text.dart';

import 'package:sacred_app/features/monk_profile/widgets/horizontal_service_card.dart';

import 'package:sacred_app/features/monk_profile/widgets/profile_back_button.dart';

import 'package:sacred_app/features/monk_profile/widgets/profile_icon_button.dart';

import 'package:sacred_app/features/monk_profile/widgets/profile_stat_item.dart';

import 'package:sacred_app/features/monk_profile/widgets/review_tile.dart';

import 'package:sacred_app/features/monk_profile/widgets/schedule_accordion.dart';

import 'package:sacred_app/features/subscription/utils/tier_gating.dart';

import 'package:sacred_app/shared/widgets/error_state.dart';

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

  int _sectionTab = 0;



  Future<void> _shareProfile(String name) async {

    final url = Uri.parse('https://sacred.mn/monks/${widget.monkId}');

    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {

      await Clipboard.setData(ClipboardData(text: url.toString()));

      if (!mounted) return;

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



  Future<void> _messageMonk(Monk monk) async {
    try {
      final convoId = await startConversation(ref, widget.monkId);
      if (!mounted) return;
      final title = Uri.encodeComponent(monk.displayName);
      context.push('/messenger/$convoId?title=$title');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatUserError(e, fallback: 'Чат эхлүүлэхэд алдаа гарлаа.')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }



  @override

  Widget build(BuildContext context) {

    final monkAsync = ref.watch(monkDetailProvider(widget.monkId));

    final servicesAsync = ref.watch(monkServicesProvider(widget.monkId));

    final reviewsAsync = ref.watch(monkReviewsProvider(widget.monkId));

    final bottomPad = MediaQuery.of(context).padding.bottom;



    return monkAsync.when(

      loading: () => const Scaffold(

        body: Center(

          child: CircularProgressIndicator(color: AppColors.sunGold),

        ),

      ),

      error: (e, _) => Scaffold(

        appBar: AppBar(title: const Text('Ламын профайл')),

        body: ErrorState(
          error: e,
          fallback: 'Ламын мэдээлэл ачаалахад алдаа гарлаа.',
          onRetry: () => ref.invalidate(monkDetailProvider(widget.monkId)),
        ),

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

                  SliverToBoxAdapter(

                    child: SizedBox(

                      height: 300,

                      child: Stack(

                        fit: StackFit.expand,

                        children: [

                          _HeroImage(monk: monk, monkId: widget.monkId),

                          const DecoratedBox(

                            decoration: BoxDecoration(

                              gradient: LinearGradient(

                                begin: Alignment.topCenter,

                                end: Alignment.bottomCenter,

                                colors: [

                                  Color(0x33000000),

                                  Colors.transparent,

                                  Color(0x66000000),

                                ],

                                stops: [0, 0.4, 1],

                              ),

                            ),

                          ),

                        ],

                      ),

                    ),

                  ),

                  SliverToBoxAdapter(

                    child: Transform.translate(

                      offset: const Offset(0, -32),

                      child: Container(

                        decoration: const BoxDecoration(

                          color: AppColors.surfaceEl,

                          borderRadius: BorderRadius.vertical(

                            top: Radius.circular(32),

                          ),

                        ),

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Padding(

                              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),

                              child: Column(

                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [

                                  if (monk.isAvailable)

                                    Container(

                                      padding: const EdgeInsets.symmetric(

                                        horizontal: 10,

                                        vertical: 4,

                                      ),

                                      margin: const EdgeInsets.only(bottom: 10),

                                      decoration: BoxDecoration(

                                        color: AppColors.success.withOpacity(0.12),

                                        borderRadius: BorderRadius.circular(999),

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

                                          const SizedBox(width: 6),

                                          Text(

                                            'Боломжтой',

                                            style: AppText.caption.copyWith(

                                              color: AppColors.success,

                                              fontWeight: FontWeight.w600,

                                            ),

                                          ),

                                        ],

                                      ),

                                    ),

                                  Text(

                                    monk.displayName,

                                    style: AppText.h1.copyWith(fontSize: 26),

                                    maxLines: 2,

                                    overflow: TextOverflow.ellipsis,

                                  ),

                                  const SizedBox(height: 6),

                                  if (monk.temple != null)

                                    Row(

                                      children: [

                                        const Icon(

                                          Icons.location_on_outlined,

                                          size: 16,

                                          color: AppColors.textSec,

                                        ),

                                        const SizedBox(width: 4),

                                        Expanded(

                                          child: Text(

                                            monk.temple!,

                                            style: AppText.bodySmall,

                                          ),

                                        ),

                                      ],

                                    ),

                                  const SizedBox(height: 10),

                                  Row(

                                    children: [

                                      ...List.generate(5, (i) {

                                        return Icon(

                                          Icons.star_rounded,

                                          size: 18,

                                          color: i < monk.rating.floor()

                                              ? AppColors.sunGold

                                              : AppColors.border,

                                        );

                                      }),

                                      const SizedBox(width: 8),

                                      Text(

                                        '${monk.rating.toStringAsFixed(1)} (${monk.reviewCount} сэтгэгдэл)',

                                        style: AppText.bodySmall.copyWith(

                                          fontWeight: FontWeight.w600,

                                        ),

                                      ),

                                    ],

                                  ),

                                ],

                              ),

                            ),

                            const SizedBox(height: 20),

                            Padding(

                              padding: const EdgeInsets.symmetric(horizontal: 24),

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

                                    label: 'Хариу',

                                  ),

                                ],

                              ),

                            ),

                            const SizedBox(height: 24),

                            Padding(

                              padding: const EdgeInsets.symmetric(horizontal: 24),

                              child: ExpandableText(

                                text: monk.bioText ?? '',

                                maxLines: 3,

                              ),

                            ),

                            const SizedBox(height: 28),

                            if (services.isNotEmpty) ...[

                              Padding(

                                padding: const EdgeInsets.symmetric(horizontal: 24),

                                child: Text('Үйлчилгээнүүд', style: AppText.h3),

                              ),

                              const SizedBox(height: 14),

                              SizedBox(

                                height: 190,

                                child: servicesAsync.when(

                                  loading: () => const Center(

                                    child: CircularProgressIndicator(

                                      color: AppColors.sunGold,

                                    ),

                                  ),

                                  error: (e, _) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      formatUserError(
                                        e,
                                        fallback: 'Үйлчилгээ ачаалахад алдаа гарлаа.',
                                      ),
                                      style: AppText.bodySmall.copyWith(
                                        color: AppColors.textSec,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  data: (serviceList) => ListView.separated(

                                    scrollDirection: Axis.horizontal,

                                    padding: const EdgeInsets.symmetric(

                                      horizontal: 24,

                                    ),

                                    itemCount: serviceList.length,

                                    separatorBuilder: (_, __) =>

                                        const SizedBox(width: 12),

                                    itemBuilder: (_, i) => HorizontalServiceCard(

                                      service: serviceList[i],

                                      onTap: () => _bookService(

                                        monk,

                                        serviceList[i].id,

                                      ),

                                    ),

                                  ),

                                ),

                              ),

                              const SizedBox(height: 28),

                            ],

                            Padding(

                              padding: const EdgeInsets.symmetric(horizontal: 24),

                              child: _SectionTabs(

                                selected: _sectionTab,

                                onChanged: (i) {

                                  HapticFeedback.lightImpact();

                                  setState(() => _sectionTab = i);

                                },

                              ),

                            ),

                            const SizedBox(height: 20),

                            if (_sectionTab == 0) ...[

                              ScheduleAccordion(monkId: widget.monkId),

                            ] else if (_sectionTab == 1) ...[

                              if (reviews.isEmpty)

                                const Padding(

                                  padding: EdgeInsets.symmetric(horizontal: 24),

                                  child: Text(

                                    'Сэтгэгдэл байхгүй',

                                    style: AppText.bodySmall,

                                  ),

                                )

                              else

                                Padding(

                                  padding: const EdgeInsets.symmetric(

                                    horizontal: 24,

                                  ),

                                  child: Column(

                                    children: reviews

                                        .take(5)

                                        .map(

                                          (r) => Padding(

                                            padding: const EdgeInsets.only(

                                              bottom: 12,

                                            ),

                                            child: ReviewTile(review: r),

                                          ),

                                        )

                                        .toList(),

                                  ),

                                ),

                            ] else ...[

                              Padding(

                                padding: const EdgeInsets.symmetric(

                                  horizontal: 24,

                                ),

                                child: Column(

                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [

                                    _InfoRow(

                                      icon: Icons.temple_buddhist_outlined,

                                      label: 'Хийд',

                                      value: monk.temple ?? '—',

                                    ),

                                    const SacredDivider(),

                                    _InfoRow(

                                      icon: Icons.category_outlined,

                                      label: 'Ангилал',

                                      value: monk.categories.isNotEmpty
                                          ? monk.categories.join(', ')
                                          : '—',

                                    ),

                                    if (startingPrice != null) ...[

                                      const SacredDivider(),

                                      _InfoRow(

                                        icon: Icons.payments_outlined,

                                        label: 'Эхлэх үнэ',

                                        value: Formatters.currency(

                                          startingPrice,

                                        ),

                                      ),

                                    ],

                                  ],

                                ),

                              ),

                            ],

                            SizedBox(height: bottomPad + 100),

                          ],

                        ),

                      ),

                    ),

                  ),

                ],

              ),

              SafeArea(

                child: Row(

                  children: [

                    const ProfileBackButton(),

                    const Spacer(),

                    ProfileIconButton(

                      icon: Icons.ios_share_rounded,

                      onPressed: () => _shareProfile(monk.displayName),

                    ),

                    ProfileIconButton(

                      icon: _bookmarked

                          ? Icons.favorite_rounded

                          : Icons.favorite_border_rounded,

                      filled: _bookmarked,

                      onPressed: () {

                        setState(() => _bookmarked = !_bookmarked);

                      },

                    ),

                  ],

                ),

              ),

              Positioned(

                bottom: 0,

                left: 0,

                right: 0,

                child: Container(

                  padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),

                  decoration: BoxDecoration(

                    color: AppColors.surfaceEl.withOpacity(0.97),

                    borderRadius: const BorderRadius.vertical(

                      top: Radius.circular(24),

                    ),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black.withOpacity(0.06),

                        blurRadius: 20,

                        offset: const Offset(0, -4),

                      ),

                    ],

                  ),

                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SacredButton(
                          label: startingPrice != null
                              ? 'Цаг захиалах · ${Formatters.currency(startingPrice)}-с'
                              : 'Цаг захиалах',
                          onTap: () => _bookMonk(monk),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _messageMonk(monk),
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                          label: const Text('Чат'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.saffronDeep,
                            side: const BorderSide(color: AppColors.saffronDeep, width: 0.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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



class _HeroImage extends StatelessWidget {

  const _HeroImage({required this.monk, required this.monkId});



  final Monk monk;

  final String monkId;



  @override

  Widget build(BuildContext context) {

    if (monk.image != null) {

      return Hero(

        tag: Monk.heroTag(monkId),

        child: CachedNetworkImage(

          imageUrl: monk.image!,

          fit: BoxFit.cover,

          placeholder: (_, __) => Shimmer.fromColors(

            baseColor: AppColors.border,

            highlightColor: AppColors.sunLight,

            child: const ColoredBox(color: AppColors.borderSub),

          ),

          errorWidget: (_, __, ___) => const DecoratedBox(

            decoration: BoxDecoration(gradient: AppGradients.monkCardBg),

            child: Icon(

              Icons.temple_buddhist_outlined,

              size: 64,

              color: AppColors.sunMuted,

            ),

          ),

        ),

      );

    }

    return const DecoratedBox(

      decoration: BoxDecoration(gradient: AppGradients.monkCardBg),

      child: Icon(

        Icons.temple_buddhist_outlined,

        size: 64,

        color: AppColors.sunMuted,

      ),

    );

  }

}



class _SectionTabs extends StatelessWidget {

  const _SectionTabs({

    required this.selected,

    required this.onChanged,

  });



  final int selected;

  final ValueChanged<int> onChanged;



  static const _labels = ['Хуваарь', 'Сэтгэгдэл', 'Мэдээлэл'];



  @override

  Widget build(BuildContext context) {

    return Container(

      height: 44,

      padding: const EdgeInsets.all(4),

      decoration: BoxDecoration(

        color: AppColors.surface,

        borderRadius: BorderRadius.circular(999),

        border: Border.all(color: AppColors.border),

      ),

      child: Row(

        children: List.generate(_labels.length, (i) {

          final active = i == selected;

          return Expanded(

            child: GestureDetector(

              onTap: () => onChanged(i),

              child: AnimatedContainer(

                duration: const Duration(milliseconds: 200),

                alignment: Alignment.center,

                decoration: BoxDecoration(

                  gradient: active ? AppGradients.sun : null,

                  borderRadius: BorderRadius.circular(999),

                ),

                child: Text(

                  _labels[i],

                  style: AppText.caption.copyWith(

                    color: active ? Colors.white : AppColors.textSec,

                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,

                  ),

                ),

              ),

            ),

          );

        }),

      ),

    );

  }

}



class _InfoRow extends StatelessWidget {

  const _InfoRow({

    required this.icon,

    required this.label,

    required this.value,

  });



  final IconData icon;

  final String label;

  final String value;



  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 12),

      child: Row(

        children: [

          Icon(icon, size: 20, color: AppColors.textSec),

          const SizedBox(width: 12),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(label, style: AppText.caption),

                Text(value, style: AppText.body),

              ],

            ),

          ),

        ],

      ),

    );

  }

}


