import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/utils/app_feedback.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/shop/models/product.dart';
import 'package:sacred_app/features/home/widgets/category_chip.dart';
import 'package:sacred_app/features/shop/providers/shop_providers.dart';
import 'package:sacred_app/shared/widgets/app_content_sheet.dart';
import 'package:sacred_app/shared/widgets/empty_state.dart';
import 'package:sacred_app/shared/widgets/error_state.dart';
import 'package:sacred_app/shared/widgets/monk_card_shimmer.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

const _categories = ['Бүгд', 'Ном', 'Эрдэнэ', 'Тос', 'Бусад'];

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final category = ref.watch(shopCategoryProvider);
    // Clear bottom nav + safe area (content was clipped behind floating bar).
    final bottomPad = MediaQuery.of(context).padding.bottom + 120;

    return AppTabSheetScaffold(
      onRefresh: () async {
        ref.invalidate(productsProvider);
        await ref.read(productsProvider.future);
      },
      headerSlot: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: SizedBox(
          height: 36,
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
      ),
      child: productsAsync.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPad),
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 18,
              childAspectRatio: 0.68,
              children: List.generate(6, (_) => const MonkCardShimmer()),
            ),
          ],
        ),
        error: (e, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.4,
              child: ErrorState(
                error: e,
                fallback: 'Бараа ачаалахад алдаа гарлаа.',
                onRetry: () => ref.invalidate(productsProvider),
              ),
            ),
          ],
        ),
        data: (products) {
          if (products.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.4,
                  child: const EmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'Бараа байхгүй',
                    message: 'Өөр ангилал сонгоно уу',
                  ),
                ),
              ],
            );
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(20, 4, 20, bottomPad),
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.68,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) => _ProductCard(
                  product: products[i],
                  badge: _badgeFor(products[i], i),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String? _badgeFor(Product product, int index) {
  if (product.stock <= 0) return null;
  final h = product.id.hashCode.abs() % 5;
  if (index < 2 || h == 0) return 'Онцлох';
  if (h == 1) return 'Шинэ';
  if (h == 2) return 'Bestseller';
  return null;
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product, this.badge});

  final Product product;
  final String? badge;

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  void _addToCart(BuildContext context, WidgetRef ref) {
    if (product.stock <= 0) return;
    HapticFeedback.lightImpact();
    ref.read(cartProvider.notifier).addItem(product);
    showAppSnackBar(
      context,
      SnackBar(
        content: Text('${product.name} сагсанд нэмэгдлээ'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _buyNow(BuildContext context, WidgetRef ref) {
    if (product.stock <= 0) return;
    HapticFeedback.lightImpact();
    ref.read(cartProvider.notifier).addItem(product);
    context.push('/shop/cart');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inStock = product.stock > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ScaleTap(
            pressedScale: 0.98,
            onTap: () => context.push('/shop/product/${product.id}'),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: const Color(0xFFF7F4F0),
                      child: product.image.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.image,
                              fit: BoxFit.cover,
                              memCacheWidth: 480,
                              placeholder: (_, __) => const ColoredBox(
                                color: Color(0xFFF7F4F0),
                              ),
                              errorWidget: (_, __, ___) => Icon(
                                Icons.storefront_outlined,
                                color: AppColors.orange.withValues(alpha: 0.28),
                                size: 36,
                              ),
                            )
                          : Icon(
                              Icons.storefront_outlined,
                              color: AppColors.orange.withValues(alpha: 0.28),
                              size: 36,
                            ),
                    ),
                    if (badge != null && inStock)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _ProductBadge(label: badge!),
                      ),
                    if (inStock)
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: ScaleTap(
                          pressedScale: 0.9,
                          onTap: () => _addToCart(context, ref),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.96),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderSub),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 20,
                              color: AppColors.inkDeep,
                            ),
                          ),
                        ),
                      ),
                    if (!inStock)
                      Container(
                        color: Colors.black.withValues(alpha: 0.42),
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
        ),
        const SizedBox(height: 10),
        ScaleTap(
          pressedScale: 0.99,
          onTap: () => context.push('/shop/product/${product.id}'),
          child: Text(
            product.name,
            style: AppText.body.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.25,
              letterSpacing: -0.15,
              color: AppColors.inkDeep,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '₮${_fmt(product.price)}',
          style: AppText.price.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.inkDeep,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        ScaleTap(
          pressedScale: 0.97,
          onTap: inStock ? () => _buyNow(context, ref) : null,
          child: Container(
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: inStock ? AppGradients.primary : null,
              color: inStock ? null : AppColors.borderSub,
              borderRadius: BorderRadius.circular(12),
              boxShadow: inStock
                  ? [
                      BoxShadow(
                        color: AppColors.orange.withValues(alpha: 0.22),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              inStock ? 'Худалдан авах' : 'Дууссан',
              style: AppText.caption.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: inStock ? Colors.white : AppColors.textHint,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductBadge extends StatelessWidget {
  const _ProductBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inkDeep.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}
