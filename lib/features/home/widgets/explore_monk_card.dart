import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

/// Compact list card for "Бусад ламнар" — soft surface + accent avatar ring.
class ExploreMonkCard extends StatelessWidget {
  const ExploreMonkCard({
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSub.withOpacity(0.9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
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
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (monk.displayTitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      monk.displayTitle!,
                      style: AppText.caption.copyWith(
                        color: AppColors.textSec,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: AppColors.orange),
                      const SizedBox(width: 4),
                      Text(
                        monk.rating.toStringAsFixed(1),
                        style: AppText.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkDeep,
                        ),
                      ),
                      Text(
                        ' · ${monk.reviewCount} үнэлгээ',
                        style: AppText.caption.copyWith(color: AppColors.textHint),
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
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 20,
                  color: isFavorite ? AppColors.danger : AppColors.textHint,
                ),
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(0.28),
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
    final initial = monk.displayName.isNotEmpty
        ? monk.displayName[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.primary,
      ),
      child: ClipOval(
        child: monk.image != null
            ? Hero(
                tag: Monk.heroTag(monk.id),
                child: CachedNetworkImage(
                  imageUrl: monk.image!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _Placeholder(initial: initial),
                ),
              )
            : _Placeholder(initial: initial),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      color: AppColors.orangeLight,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppText.h3.copyWith(
          color: AppColors.orangeDeep,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }
}
