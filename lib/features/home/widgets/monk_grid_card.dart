import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:shimmer/shimmer.dart';

class MonkGridCard extends StatelessWidget {
  const MonkGridCard({
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
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (monk.image != null)
                    Hero(
                      tag: Monk.heroTag(monk.id),
                      child: CachedNetworkImage(
                        imageUrl: monk.image!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          decoration: const BoxDecoration(
                            gradient: AppGradients.monkCardBg,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.self_improvement_rounded,
                              color: AppColors.sunYellow.withOpacity(0.4),
                              size: 32,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: AppGradients.monkCardBg,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.self_improvement_rounded,
                              color: AppColors.sunYellow.withOpacity(0.4),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppGradients.monkCardBg,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.self_improvement_rounded,
                          color: AppColors.sunYellow.withOpacity(0.4),
                          size: 40,
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _AvailableBadge(isAvailable: monk.isAvailable),
                  ),
                  if (monk.isSpecial)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: _SpecialBadge(),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monk.displayName,
                    style: AppText.h3.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (monk.displayTitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      monk.displayTitle!,
                      style: AppText.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: AppColors.goldPrime,
                      ),
                      Text(
                        ' ${monk.rating.toStringAsFixed(1)}',
                        style: AppText.caption,
                      ),
                      const Spacer(),
                      if (monk.startingPrice != null)
                        Text(
                          '₮${_fmt(monk.startingPrice!)}',
                          style: AppText.price.copyWith(fontSize: 12),
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

  String _fmt(int n) => n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
}

class _AvailableBadge extends StatelessWidget {
  const _AvailableBadge({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inkDeep.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isAvailable ? AppColors.success : AppColors.danger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isAvailable ? 'Боломжтой' : 'Захиалгатай',
            style: AppText.caption.copyWith(
              color: AppColors.goldLight,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialBadge extends StatelessWidget {
  const _SpecialBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.goldPrime,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Онцлох',
        style: AppText.caption.copyWith(
          color: AppColors.inkDeep,
          fontWeight: FontWeight.w700,
          fontSize: 9,
        ),
      ),
    );
  }
}
