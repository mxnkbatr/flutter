import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/formatters.dart';
import 'package:sacred_app/features/monk_profile/models/monk_service.dart';
import 'package:sacred_app/features/monk_profile/widgets/service_card.dart';

class HorizontalServiceCard extends StatelessWidget {
  const HorizontalServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  final MonkService service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: MinimalStyle.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: MinimalStyle.avatarBox(),
              alignment: Alignment.center,
              child: Text(
                categoryEmoji(service.category),
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              service.displayName,
              style: AppText.body.copyWith(fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(service.durationLabel, style: AppText.caption),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    Formatters.currency(service.price),
                    style: AppText.price.copyWith(
                      fontSize: 15,
                      color: AppColors.orange,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
