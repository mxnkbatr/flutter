import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/features/home/utils/monk_rating_label.dart';
import 'package:sacred_app/shared/widgets/gevabal_logo.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

/// Featured monk — editorial hero card with overlay typography.
class FeaturedDiscoveryCard extends StatelessWidget {
  const FeaturedDiscoveryCard({
    super.key,
    required this.monk,
    required this.onTap,
    this.onBook,
    this.onFavorite,
    this.isFavorite = false,
  });

  final Monk monk;
  final VoidCallback onTap;
  final VoidCallback? onBook;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      pressedScale: 0.985,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderSub.withValues(alpha: 0.85)),
          boxShadow: AppGradients.luxuryShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FeaturedHero(monk: monk, isFavorite: isFavorite, onFavorite: onFavorite),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  _RatingPill(rating: monk.rating, count: monk.reviewCount),
                  const Spacer(),
                  _BookCta(onTap: onBook ?? onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedHero extends StatelessWidget {
  const _FeaturedHero({
    required this.monk,
    required this.isFavorite,
    this.onFavorite,
  });

  final Monk monk;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: Monk.heroTag(monk.id),
            child: monk.image != null && monk.image!.isNotEmpty
                ? _MonkPhotoHero(url: monk.image!)
                : const _BrandLogoHero(),
          ),
          if (monk.isSpecial)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGlass,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.orangeDeep),
                    const SizedBox(width: 5),
                    Text(
                      'Онцлох',
                      style: AppText.caption.copyWith(
                        color: AppColors.orangeDeep,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 12,
            right: 12,
            child: _FavoriteBtn(isFavorite: isFavorite, onTap: onFavorite),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.surfaceEl.withValues(alpha: 0.35),
                    AppColors.surfaceEl.withValues(alpha: 0.92),
                    AppColors.surfaceEl,
                  ],
                  stops: const [0.0, 0.35, 0.72, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monk.displayName,
                  style: AppText.displaySerif(
                    size: 27,
                    color: AppColors.inkDeep,
                  ).copyWith(
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.9),
                        blurRadius: 12,
                        offset: const Offset(0, 1),
                      ),
                      Shadow(
                        color: AppColors.surfaceEl.withValues(alpha: 0.85),
                        blurRadius: 18,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (monk.displayTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    monk.displayTitle!,
                    style: AppText.bodySmall.copyWith(
                      color: AppColors.inkMid,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.85),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating, required this.count});

  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    final hasReviews = monkHasReviews(count);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.orangeSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSub),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasReviews ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 15,
            color: hasReviews ? AppColors.orange : AppColors.textHint,
          ),
          const SizedBox(width: 5),
          Text(
            monkRatingLabel(rating, count),
            style: AppText.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: hasReviews ? AppColors.inkDeep : AppColors.textSec,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCta extends StatelessWidget {
  const _BookCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.orange.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Захиалах',
              style: AppText.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _MonkPhotoHero extends StatelessWidget {
  const _MonkPhotoHero({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      memCacheWidth: (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round(),
      memCacheHeight: (260 * MediaQuery.devicePixelRatioOf(context)).round(),
      fadeInDuration: const Duration(milliseconds: 280),
      placeholder: (_, __) => const ColoredBox(color: Color(0xFFFFE8D6)),
      errorWidget: (_, __, ___) => const _BrandLogoHero(),
    );
  }
}

class _BrandLogoHero extends StatelessWidget {
  const _BrandLogoHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF0E5),
            Color(0xFFFFE0C8),
            Color(0xFFFFC999),
          ],
        ),
      ),
      child: const Center(
        child: GevabalLogo(height: 150, glow: true),
      ),
    );
  }
}

class _FavoriteBtn extends StatelessWidget {
  const _FavoriteBtn({
    required this.isFavorite,
    this.onTap,
    this.light = false,
  });

  final bool isFavorite;
  final VoidCallback? onTap;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: light
              ? Colors.black.withValues(alpha: 0.22)
              : AppColors.surfaceGlass,
          shape: BoxShape.circle,
          border: Border.all(
            color: light
                ? Colors.white.withValues(alpha: 0.28)
                : AppColors.borderSub,
          ),
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 20,
          color: isFavorite
              ? AppColors.danger
              : light
                  ? Colors.white
                  : AppColors.textSec,
        ),
      ),
    );
  }
}
