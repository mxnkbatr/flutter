import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/shared/widgets/sacred_divider.dart';

class MonkListTile extends StatelessWidget {
  const MonkListTile({
    super.key,
    required this.monk,
    required this.onTap,
    this.showDivider = true,
  });

  final Monk monk;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppColors.surface,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: SizedBox(
              height: 72,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _Avatar(monk: monk),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            monk.displayName,
                            style: AppText.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (monk.temple != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              monk.temple!,
                              style: AppText.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 2),
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
                                  color: AppColors.goldPrime,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (monk.startingPrice != null)
                      Text(
                        '₮${_fmt(monk.startingPrice!)}',
                        style: AppText.price.copyWith(fontSize: 14),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 88),
            child: SacredDivider(),
          ),
      ],
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.monk});

  final Monk monk;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: 56,
        height: 56,
        child: monk.image != null
            ? CachedNetworkImage(
                imageUrl: monk.image!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(
                  color: AppColors.borderSub,
                ),
                errorWidget: (_, __, ___) => const ColoredBox(
                  color: AppColors.borderSub,
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.goldMuted,
                  ),
                ),
              )
            : const ColoredBox(
                color: AppColors.borderSub,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.goldMuted,
                ),
              ),
      ),
    );
  }
}
