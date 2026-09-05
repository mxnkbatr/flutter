import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/features/home/utils/monk_rating_label.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

/// Compact list card — clean white surface, clear hierarchy.
class ExploreMonkCard extends StatelessWidget {
  const ExploreMonkCard({
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
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSub),
          boxShadow: AppGradients.softCardShadow,
        ),
        child: Row(
          children: [
            _Avatar(monk: monk),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monk.displayName,
                    style: AppText.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: -0.25,
                      color: AppColors.inkDeep,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (monk.displayTitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      monk.displayTitle!,
                      style: AppText.caption.copyWith(
                        color: AppColors.textSec,
                        fontSize: 12.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        monkHasReviews(monk.reviewCount)
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 14,
                        color: monkHasReviews(monk.reviewCount)
                            ? AppColors.orange
                            : AppColors.textHint,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        monkRatingLabel(monk.rating, monk.reviewCount),
                        style: AppText.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: monkHasReviews(monk.reviewCount)
                              ? AppColors.inkDeep
                              : AppColors.textSec,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onFavorite == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      onFavorite!();
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 20,
                  color: isFavorite ? AppColors.danger : AppColors.textHint,
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (onBook != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onBook!();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange.withValues(alpha: 0.22),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'Захиалах',
                    style: AppText.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.24),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.monk});

  final Monk monk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.primary,
      ),
      child: ClipOval(
        child: monk.image != null && monk.image!.isNotEmpty
            ? Hero(
                tag: Monk.heroTag(monk.id),
                child: CachedNetworkImage(
                  imageUrl: monk.image!,
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                  memCacheWidth:
                      (54 * MediaQuery.devicePixelRatioOf(context)).round(),
                  memCacheHeight:
                      (54 * MediaQuery.devicePixelRatioOf(context)).round(),
                  fadeInDuration: const Duration(milliseconds: 240),
                  placeholder: (_, __) => const _MonkPlaceholder(),
                  errorWidget: (_, __, ___) => const _MonkPlaceholder(),
                ),
              )
            : const _MonkPlaceholder(),
      ),
    );
  }
}

class _MonkPlaceholder extends StatelessWidget {
  const _MonkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF1E6),
            Color(0xFFFFE0C8),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.self_improvement_rounded,
        size: 28,
        color: AppColors.orange.withValues(alpha: 0.72),
      ),
    );
  }
}
