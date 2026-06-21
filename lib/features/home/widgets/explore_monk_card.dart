import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

/// Compact white list card for "Бусад ламнар".
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
        padding: const EdgeInsets.all(16),
        decoration: MinimalStyle.card(),
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
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (monk.displayTitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      monk.displayTitle!,
                      style: AppText.caption.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < monk.rating.floor();
                      return Icon(
                        filled ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 14,
                        color: AppColors.orange,
                      );
                    }),
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
                padding: const EdgeInsets.only(right: 4),
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSub),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.textSec,
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
    if (monk.image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Hero(
          tag: Monk.heroTag(monk.id),
          child: CachedNetworkImage(
            imageUrl: monk.image!,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _Placeholder(
              initial: monk.displayName.isNotEmpty
                  ? monk.displayName[0].toUpperCase()
                  : '?',
            ),
          ),
        ),
      );
    }
    return _Placeholder(
      initial: monk.displayName.isNotEmpty
          ? monk.displayName[0].toUpperCase()
          : '?',
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: MinimalStyle.avatarBox(radius: 28),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppText.h3.copyWith(
          color: AppColors.inkDeep,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
    );
  }
}
