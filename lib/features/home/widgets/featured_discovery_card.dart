import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

/// Featured monk card — full-bleed hero image with warm glow.
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSub, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.orange.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monk.displayName,
                          style: AppText.h2.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
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
                  _FavoriteBtn(
                    isFavorite: isFavorite,
                    onTap: onFavorite,
                  ),
                ],
              ),
            ),
            _FeaturedHeroImage(monk: monk),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Row(
                children: [
                  ...List.generate(5, (i) {
                    return Icon(
                      i < monk.rating.floor()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: AppColors.orange,
                    );
                  }),
                  const SizedBox(width: 6),
                  Text(
                    '${monk.rating.toStringAsFixed(1)} (${monk.reviewCount})',
                    style: AppText.bodySmall.copyWith(
                      color: AppColors.textSec,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Дэлгэрэнгүй',
                    style: AppText.caption.copyWith(
                      color: AppColors.orangeDeep,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedHeroImage extends StatelessWidget {
  const _FeaturedHeroImage({required this.monk});

  final Monk monk;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 232,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.orange.withOpacity(0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (monk.image != null)
                Hero(
                  tag: Monk.heroTag(monk.id),
                  child: CachedNetworkImage(
                    imageUrl: monk.image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (_, __) => const _HeroPlaceholder(),
                    errorWidget: (_, __, ___) => const _HeroPlaceholder(),
                  ),
                )
              else
                const _HeroPlaceholder(),
              // Warm shine — top-left highlight
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.18),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.15),
                    ],
                    stops: const [0, 0.35, 0.65, 1],
                  ),
                ),
              ),
              // Orange rim glow
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      vertical: BorderSide(
                        color: AppColors.orange.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              if (monk.isSpecial)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Онцлох',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF0E5),
            Color(0xFFFFE8D6),
            Color(0xFFFFD4B8),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.self_improvement_rounded,
          size: 72,
          color: AppColors.orange,
        ),
      ),
    );
  }
}

class _FavoriteBtn extends StatelessWidget {
  const _FavoriteBtn({required this.isFavorite, this.onTap});

  final bool isFavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: 22,
        color: isFavorite ? AppColors.danger : AppColors.textHint,
      ),
    );
  }
}
