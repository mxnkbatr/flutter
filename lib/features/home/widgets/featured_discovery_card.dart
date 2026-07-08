import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/shared/widgets/gevabal_logo.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

/// Featured monk — editorial hero card with overlay typography.
class FeaturedDiscoveryCard extends StatelessWidget {
  const FeaturedDiscoveryCard({
    super.key,
    required this.monk,
    required this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  final Monk monk;
  final VoidCallback onTap;
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
          boxShadow: [
            BoxShadow(
              color: AppColors.orange.withOpacity(0.12),
              blurRadius: 32,
              spreadRadius: -4,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
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
                  _DetailCta(),
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
      height: 248,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: Monk.heroTag(monk.id),
            child: const _BrandLogoHero(),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          if (monk.isSpecial)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.orange),
                    const SizedBox(width: 5),
                    Text(
                      'Онцлох',
                      style: AppText.caption.copyWith(
                        color: AppColors.orangeDeep,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
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
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monk.displayName,
                  style: AppText.displaySerif(
                    size: 26,
                    color: AppColors.inkDeep,
                  ),
                ),
                if (monk.displayTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    monk.displayTitle!,
                    style: AppText.bodySmall.copyWith(
                      color: AppColors.textSec,
                      fontSize: 13,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.orangeSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (i) {
            return Icon(
              i < rating.floor()
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              size: 15,
              color: AppColors.orange,
            );
          }),
          const SizedBox(width: 6),
          Text(
            '${rating.toStringAsFixed(1)} ($count)',
            style: AppText.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.inkDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Дэлгэрэнгүй',
          style: AppText.caption.copyWith(
            color: AppColors.orangeDeep,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ],
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
              ? Colors.black.withOpacity(0.25)
              : AppColors.orangeSoft,
          shape: BoxShape.circle,
          border: light
              ? Border.all(color: Colors.white.withOpacity(0.3))
              : null,
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 20,
          color: isFavorite
              ? AppColors.danger
              : light
                  ? Colors.white
                  : AppColors.textHint,
        ),
      ),
    );
  }
}
