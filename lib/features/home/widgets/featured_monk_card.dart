import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:shimmer/shimmer.dart';

class FeaturedMonkCard extends StatelessWidget {
  const FeaturedMonkCard({
    super.key,
    required this.monk,
    required this.onTap,
  });

  final Monk monk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (monk.image != null)
              CachedNetworkImage(
                imageUrl: monk.image!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.border,
                  highlightColor: AppColors.goldLight,
                  child: const ColoredBox(color: AppColors.borderSub),
                ),
                errorWidget: (_, __, ___) => const ColoredBox(
                  color: AppColors.inkMid,
                  child: Icon(
                    Icons.temple_buddhist_outlined,
                    color: AppColors.goldPrime,
                    size: 48,
                  ),
                ),
              )
            else
              const ColoredBox(
                color: AppColors.inkMid,
                child: Icon(
                  Icons.temple_buddhist_outlined,
                  color: AppColors.goldPrime,
                  size: 48,
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.inkDeep.withOpacity(0.85),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    monk.displayName,
                    style: AppText.h3.copyWith(
                      color: AppColors.goldLight,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: AppColors.goldPrime,
                      ),
                      Text(
                        ' ${monk.rating.toStringAsFixed(1)}',
                        style: AppText.caption.copyWith(
                          color: AppColors.goldLight,
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
    );
  }
}
