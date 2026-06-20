import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/shop/models/product.dart';
import 'package:sacred_app/features/home/widgets/category_chip.dart';
import 'package:sacred_app/features/shop/providers/shop_providers.dart';
import 'package:sacred_app/shared/widgets/monk_card_shimmer.dart';

const _categories = ['Бүгд', 'Ном', 'Эрдэнэ', 'Тос', 'Бусад'];

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final category = ref.watch(shopCategoryProvider);
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.heroInk,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Дэлгүүр',
                                style: AppText.h2.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Буддийн бараа, бэлэг',
                                style: AppText.caption.copyWith(
                                  color: Colors.white.withOpacity(0.82),
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _ShopHeaderIcon(
                          icon: Icons.receipt_long_outlined,
                          onTap: () => context.push('/shop/orders'),
                        ),
                        const SizedBox(width: 8),
                        _ShopHeaderIcon(
                          icon: Icons.shopping_bag_outlined,
                          badgeCount: cartCount,
                          onTap: () => context.push('/shop/cart'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
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
          ),
          productsAsync.when(
            loading: () => SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
                children: List.generate(6, (_) => const MonkCardShimmer()),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: AppColors.danger,
                      ),
                      const SizedBox(height: 8),
                      Text(formatUserError(e), style: AppText.bodySmall),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ref.invalidate(productsProvider),
                        child: const Text('Дахин оролдох'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (products) => products.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 48,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Бараа байхгүй',
                            style: AppText.h3.copyWith(color: AppColors.textSec),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      MediaQuery.of(context).padding.bottom + 100,
                    ),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, i) => _ProductCard(product: products[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ShopHeaderIcon extends StatelessWidget {
  const _ShopHeaderIcon({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.28),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  gradient: AppGradients.sun,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});
  final Product product;

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/shop/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.image,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            decoration: const BoxDecoration(
                              gradient: AppGradients.monkCardBg,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.goldLight,
                            child: const Icon(
                              Icons.storefront_outlined,
                              color: AppColors.goldMuted,
                              size: 32,
                            ),
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: AppGradients.monkCardBg,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.storefront_outlined,
                              color: AppColors.goldMuted,
                              size: 32,
                            ),
                          ),
                        ),
                  if (product.stock <= 0)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Text(
                          'Дууссан',
                          style: AppText.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: AppText.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₮${_fmt(product.price)}',
                          style: AppText.price.copyWith(
                            fontSize: 13,
                            color: AppColors.saffronDeep,
                          ),
                        ),
                        GestureDetector(
                          onTap: product.stock > 0
                              ? () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(cartProvider.notifier)
                                      .addItem(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} нэмэгдлээ'),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              gradient:
                                  product.stock > 0 ? AppGradients.sun : null,
                              color: product.stock <= 0
                                  ? AppColors.border
                                  : null,
                              borderRadius: BorderRadius.circular(9),
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
            ),
          ],
        ),
      ),
    );
  }
}
