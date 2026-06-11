import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';

class RecommendedMonkCard extends StatelessWidget {
  const RecommendedMonkCard({
    super.key,
    required this.monk,
  });

  final Monk monk;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.only(left: 20, right: 4),
      decoration: BoxDecoration(
        color: AppColors.inkMid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.goldPrime.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
            child: SizedBox(
              width: 100,
              height: 160,
              child: monk.image != null
                  ? CachedNetworkImage(
                      imageUrl: monk.image!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(
                        color: AppColors.inkLight,
                      ),
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: AppColors.inkLight,
                        child: Icon(
                          Icons.temple_buddhist_outlined,
                          color: AppColors.goldMuted,
                        ),
                      ),
                    )
                  : const ColoredBox(
                      color: AppColors.inkLight,
                      child: Icon(
                        Icons.temple_buddhist_outlined,
                        color: AppColors.goldMuted,
                        size: 40,
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (monk.categories.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            monk.categories.first,
                            style: AppText.caption.copyWith(
                              color: AppColors.inkDeep,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        monk.displayName,
                        style: AppText.h3.copyWith(
                          color: AppColors.onDark,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        monk.temple ?? '',
                        style: AppText.caption.copyWith(
                          color: AppColors.goldMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.goldPrime,
                      ),
                      Text(
                        ' ${monk.rating.toStringAsFixed(1)}',
                        style: AppText.caption.copyWith(
                          color: AppColors.goldPrime,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.go('/monks/${monk.id}');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldPrime,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Харах',
                            style: AppText.caption.copyWith(
                              color: AppColors.inkDeep,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
