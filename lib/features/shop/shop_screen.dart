import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/utils/app_feedback.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/shop/models/product.dart';
import 'package:sacred_app/features/home/widgets/category_chip.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/features/shop/providers/shop_providers.dart';
import 'package:sacred_app/shared/widgets/monk_card_shimmer.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

const _categories = ['Бүгд', 'Ном', 'Эрдэнэ', 'Тос', 'Бусад'];

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final category = ref.watch(shopCategoryProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 100;

    return PremiumLayeredScaffold(
      subtitle: 'Буддийн бараа, бэлэг',
      title: 'Дэлгүүр',
      sheetTopContent: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = _categories[i];
            return CategoryChip(
              label: cat,
              isSelected: cat == category,
              onTap: () =>
                  ref.read(shopCategoryProvider.notifier).state = cat,
            );
          },
        ),
      ),
      onRefresh: () async {
        ref.invalidate(productsProvider);
        await ref.read(productsProvider.future);
      },
      body: productsAsync.when(
        loading: () => Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPad),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.68,
            children: List.generate(6, (_) => const MonkCardShimmer()),
          ),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 32,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 12),
              Text(formatUserError(e), style: AppText.bodySmall),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(productsProvider),
                child: const Text('Дахин оролдох'),
              ),
            ],
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.orangeLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 36,
                      color: AppColors.orange.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Бараа байхгүй',
                    style: AppText.h3.copyWith(color: AppColors.textSec),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Өөр ангилал сонгоно уу',
                    style: AppText.bodySmall.copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${products.length} бараа',
                    style: AppText.caption.copyWith(
                      color: AppColors.textSec,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) => _ProductCard(product: products[i]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});
  final Product product;

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScaleTap(
      pressedScale: 0.97,
      onTap: () => context.push('/shop/product/${product.id}'),
      child: Container(
        decoration: MinimalStyle.card(radius: MinimalStyle.cardRadiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      product.image.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.image,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.orangeLight,
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.orangeLight,
                                child: Icon(
                                  Icons.storefront_outlined,
                                  color: AppColors.orange.withOpacity(0.35),
                                  size: 32,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.orangeLight,
                              child: Icon(
                                Icons.storefront_outlined,
                                color: AppColors.orange.withOpacity(0.35),
                                size: 32,
                              ),
                            ),
                      if (product.category.isNotEmpty)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              product.category,
                              style: AppText.caption.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.orangeDeep,
                              ),
                            ),
                          ),
                        ),
                      if (product.stock <= 0)
                        Container(
                          color: Colors.black45,
                          alignment: Alignment.center,
                          child: Text(
                            'Дууссан',
                            style: AppText.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppText.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '₮${_fmt(product.price)}',
                          style: AppText.price.copyWith(
                            fontSize: 14,
                            color: AppColors.orange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ScaleTap(
                        pressedScale: 0.88,
                        onTap: product.stock > 0
                            ? () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(cartProvider.notifier)
                                    .addItem(product);
                                showAppSnackBar(
                                  context,
                                  SnackBar(
                                    content:
                                        Text('${product.name} нэмэгдлээ'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: product.stock > 0
                                ? AppGradients.primary
                                : null,
                            color: product.stock <= 0
                                ? AppColors.border
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: product.stock > 0
                                ? [
                                    BoxShadow(
                                      color: AppColors.orangeDeep
                                          .withOpacity(0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
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
