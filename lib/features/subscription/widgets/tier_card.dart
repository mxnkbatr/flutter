import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/subscription/models/subscription_feature.dart';
import 'package:sacred_app/features/subscription/widgets/subscription_payment_sheet.dart';
import 'package:sacred_app/shared/widgets/app_modal_sheet.dart';

class TierCard extends StatelessWidget {
  const TierCard({
    super.key,
    required this.tier,
    required this.title,
    required this.price,
    required this.features,
    required this.isCurrentTier,
    this.badge,
    this.highlighted = false,
  });

  final String tier;
  final String title;
  final int price;
  final String? badge;
  final List<SubscriptionFeature> features;
  final bool isCurrentTier;
  final bool highlighted;

  String _fmt(int n) => n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );

  void _subscribe(BuildContext context) {
    showAppModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.inkDeep,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SubscriptionPaymentSheet(
        tier: tier,
        monthlyPrice: price,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: highlighted ? AppColors.inkMid : AppColors.inkLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted ? AppColors.goldPrime : AppColors.inkLight,
          width: highlighted ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badge != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrime,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge!,
                          style: AppText.caption.copyWith(
                            color: AppColors.inkDeep,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Text(
                      title,
                      style: AppText.h2.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (price > 0) ...[
                      Text(
                        '₮${_fmt(price)}',
                        style: AppText.h2.copyWith(color: AppColors.goldPrime),
                      ),
                      Text(
                        '/сар',
                        style: AppText.caption.copyWith(color: AppColors.goldMuted),
                      ),
                    ] else
                      Text(
                        'Үнэгүй',
                        style: AppText.h2.copyWith(color: AppColors.goldMuted),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: features.map((f) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        f.included
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 18,
                        color: f.included
                            ? AppColors.goldPrime
                            : AppColors.goldMuted.withOpacity(0.4),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          f.label,
                          style: AppText.body.copyWith(
                            color: f.included
                                ? Colors.white
                                : AppColors.goldMuted.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: isCurrentTier
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.goldMuted, width: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Одоогийн тарифф',
                        style: AppText.body.copyWith(color: AppColors.goldMuted),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: price == 0 ? null : () => _subscribe(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          highlighted ? AppColors.goldPrime : AppColors.inkDeep,
                      foregroundColor:
                          highlighted ? AppColors.inkDeep : AppColors.goldPrime,
                      side: highlighted
                          ? null
                          : const BorderSide(color: AppColors.goldPrime, width: 0.5),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(price == 0 ? 'Үнэгүй эхлэх' : 'Сонгох'),
                  ),
          ),
        ],
      ),
    );
  }
}
