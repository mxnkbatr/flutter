import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';

/// Inset rounded cover card — replaces full-bleed empty hero banner.
class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({
    super.key,
    required this.monk,
    required this.monkId,
    this.height = 220,
  });

  final Monk monk;
  final String monkId;
  final double height;

  String get _initial =>
      monk.displayName.isNotEmpty ? monk.displayName[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (monk.image != null)
            Hero(
              tag: Monk.heroTag(monkId),
              child: CachedNetworkImage(
                imageUrl: monk.image!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.orangeLight,
                  highlightColor: AppColors.creamBg,
                  child: const ColoredBox(color: AppColors.orangeLight),
                ),
                errorWidget: (_, __, ___) => _Placeholder(initial: _initial),
              ),
            )
          else
            _Placeholder(initial: _initial),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.08),
                  Colors.transparent,
                  Colors.black.withOpacity(0.18),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          if (monk.isSpecial)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(999),
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
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF6EE),
            Color(0xFFFFE8D6),
            Color(0xFFFFF0E5),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.temple_buddhist_outlined,
            size: 120,
            color: AppColors.orange.withOpacity(0.07),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.surfaceEl,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.orange.withOpacity(0.25), width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppText.largeTitle.copyWith(fontSize: 36),
            ),
          ),
        ],
      ),
    );
  }
}
