import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:shimmer/shimmer.dart';

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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: AppGradients.cardShadow(radius: 20),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Image(monk: monk),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _FavoriteButton(
                      isFavorite: isFavorite,
                      onTap: onFavorite,
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
                          gradient: AppGradients.sun,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Онцлох',
                          style: AppText.caption.copyWith(
                            color: AppColors.surfaceEl,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monk.displayName,
                          style: AppText.h3.copyWith(fontSize: 17),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        if (monk.temple != null)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textSec.withOpacity(0.8),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  monk.temple!,
                                  style: AppText.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              final filled = i < monk.rating.floor();
                              final half = !filled &&
                                  i < monk.rating &&
                                  monk.rating - i >= 0.5;
                              return Icon(
                                filled
                                    ? Icons.star_rounded
                                    : half
                                        ? Icons.star_half_rounded
                                        : Icons.star_outline_rounded,
                                size: 16,
                                color: AppColors.sunGold,
                              );
                            }),
                            const SizedBox(width: 4),
                            Text(
                              '${monk.reviewCount} сэтгэгдэл',
                              style: AppText.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (monk.startingPrice != null) ...[
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppGradients.sun.createShader(bounds),
                          child: Text(
                            '₮${_fmt(monk.startingPrice!)}',
                            style: AppText.price.copyWith(
                              fontSize: 18,
                              color: AppColors.surfaceEl,
                            ),
                          ),
                        ),
                        Text(
                          '/ үйлчилгээ',
                          style: AppText.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
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

class _Image extends StatelessWidget {
  const _Image({required this.monk});

  final Monk monk;

  @override
  Widget build(BuildContext context) {
    if (monk.image != null) {
      return Hero(
        tag: Monk.heroTag(monk.id),
        child: CachedNetworkImage(
          imageUrl: monk.image!,
          fit: BoxFit.cover,
          placeholder: (_, __) => Shimmer.fromColors(
            baseColor: AppColors.border,
            highlightColor: AppColors.sunLight,
            child: const ColoredBox(color: AppColors.borderSub),
          ),
          errorWidget: (_, __, ___) => const _Placeholder(),
        ),
      );
    }
    return const _Placeholder();
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.sunSoft),
      child: const Center(
        child: Icon(
          Icons.temple_buddhist_outlined,
          color: AppColors.sunMuted,
          size: 48,
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, this.onTap});

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
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceEl.withOpacity(0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 18,
          color: isFavorite ? AppColors.sunOrange : AppColors.textSec,
        ),
      ),
    );
  }
}
