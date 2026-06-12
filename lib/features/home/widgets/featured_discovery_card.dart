import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';

/// Travel-app style tall featured card.
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 340,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.sunOrange.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _HeroImage(monk: monk),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.inkOverlay,
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: _CircleBtn(
                icon: isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                iconColor: isFavorite ? AppColors.danger : AppColors.onDark,
                onTap: onFavorite,
              ),
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
                    style: AppText.h1.copyWith(
                      color: AppColors.onDark,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (monk.temple != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.onDarkMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            monk.temple!,
                            style: AppText.bodySmall.copyWith(
                              color: AppColors.onDarkMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        return Icon(
                          i < monk.rating.floor()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 16,
                          color: AppColors.sunYellow,
                        );
                      }),
                      const SizedBox(width: 6),
                      Text(
                        '${monk.rating.toStringAsFixed(1)} (${monk.reviewCount})',
                        style: AppText.caption.copyWith(
                          color: AppColors.onDarkMuted,
                        ),
                      ),
                      const Spacer(),
                      _SeeMoreButton(onTap: onTap),
                    ],
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

class _SeeMoreButton extends StatelessWidget {
  const _SeeMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Дэлгэрэнгүй',
            style: AppText.bodySmall.copyWith(
              color: AppColors.onDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: AppGradients.sun,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
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
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.monk});

  final Monk monk;

  @override
  Widget build(BuildContext context) {
    if (monk.image != null) {
      return Hero(
        tag: Monk.heroTag(monk.id),
        child: CachedNetworkImage(
          imageUrl: monk.image!,
          fit: BoxFit.cover,
          placeholder: (_, __) => const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.monkCardBg),
          ),
          errorWidget: (_, __, ___) => const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.monkCardBg),
          ),
        ),
      );
    }
    return const DecoratedBox(
      decoration: BoxDecoration(gradient: AppGradients.monkCardBg),
      child: Center(
        child: Icon(
          Icons.self_improvement_rounded,
          size: 64,
          color: AppColors.sunMuted,
        ),
      ),
    );
  }
}
