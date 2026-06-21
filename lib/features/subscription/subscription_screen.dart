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
    final isPremium = currentTier == 'premium' || currentTier == 'vip';

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
                    'Premium эрх\nавч давуу тал эдэл',
                    style: AppText.h1.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ламын үйлчилгээнд 20% хөнгөлөлт,\nонцгой лам нарт холбогдох боломж',
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
                      SubscriptionFeature('Онцгой лам нар', included: false),
                      SubscriptionFeature('20% хөнгөлөлт', included: false),
                    ],
                    isCurrentTier: !isPremium,
                  ),
                  const SizedBox(height: 12),
                  TierCard(
                    tier: 'premium',
                    title: 'Premium',
                    price: 300000,
                    badge: 'САРЫН БАГЦ',
                    features: const [
                      SubscriptionFeature('Хязгааргүй захиалга', included: true),
                      SubscriptionFeature('Видео дуудлага', included: true),
                      SubscriptionFeature('Онцгой лам нар', included: true),
                      SubscriptionFeature('20% хөнгөлөлт', included: true),
                      SubscriptionFeature('Тэргүүлэх цаг захиалга', included: true),
                      SubscriptionFeature('Бусад premium давуу тал', included: true),
                    ],
                    isCurrentTier: isPremium,
                    highlighted: true,
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
