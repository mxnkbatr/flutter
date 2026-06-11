import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/auth/tier_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/subscription/models/subscription_feature.dart';
import 'package:sacred_app/features/subscription/widgets/tier_card.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTier = ref.watch(userTierProvider);

    return Scaffold(
      backgroundColor: AppColors.inkDeep,
      appBar: AppBar(
        title: const Text('Premium гишүүнчлэл'),
        backgroundColor: AppColors.inkDeep,
        foregroundColor: AppColors.goldPrime,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.goldPrime, width: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Одоогийн: ${tierLabel(currentTier)}',
                      style: AppText.goldLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Илүү олон ламтай\nхолбогд',
                    style: AppText.h1.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Premium эрхтэй илүү олон лам нартай\nхолбогдож, онцгой хөнгөлөлт эдэл',
                    style: AppText.bodySmall.copyWith(color: AppColors.goldMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TierCard(
                    tier: 'free',
                    title: 'Үнэгүй',
                    price: 0,
                    features: const [
                      SubscriptionFeature('3 захиалга/сар', included: true),
                      SubscriptionFeature('Текст мессэж', included: true),
                      SubscriptionFeature('Үндсэн лам нар', included: true),
                      SubscriptionFeature('Видео дуудлага', included: false),
                      SubscriptionFeature('Онцлох лам нар', included: false),
                      SubscriptionFeature('Хөнгөлөлт', included: false),
                    ],
                    isCurrentTier: currentTier == 'free',
                  ),
                  const SizedBox(height: 12),
                  TierCard(
                    tier: 'premium',
                    title: 'Premium',
                    price: 9900,
                    badge: 'АЛДАРТАЙ',
                    features: const [
                      SubscriptionFeature('Хязгааргүй захиалга', included: true),
                      SubscriptionFeature('Видео дуудлага', included: true),
                      SubscriptionFeature('Онцлох лам нар', included: true),
                      SubscriptionFeature('10% хөнгөлөлт', included: true),
                      SubscriptionFeature('Group дуудлага', included: false),
                      SubscriptionFeature('VIP лам нар', included: false),
                    ],
                    isCurrentTier: currentTier == 'premium',
                    highlighted: true,
                  ),
                  const SizedBox(height: 12),
                  TierCard(
                    tier: 'vip',
                    title: 'VIP',
                    price: 29900,
                    features: const [
                      SubscriptionFeature('Хязгааргүй захиалга', included: true),
                      SubscriptionFeature('Group видео дуудлага', included: true),
                      SubscriptionFeature('VIP лам нар', included: true),
                      SubscriptionFeature('20% хөнгөлөлт', included: true),
                      SubscriptionFeature('Тэргүүлэх цаг захиалга', included: true),
                      SubscriptionFeature('Хувийн менежер', included: true),
                    ],
                    isCurrentTier: currentTier == 'vip',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
