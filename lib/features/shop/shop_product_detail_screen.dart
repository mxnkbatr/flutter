import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/core/utils/app_feedback.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/features/home/widgets/category_chip.dart';
import 'package:sacred_app/features/shop/models/product.dart';
import 'package:sacred_app/features/shop/providers/shop_providers.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

class ShopProductDetailScreen extends ConsumerWidget {
  const ShopProductDetailScreen({super.key, required this.productId});

  final String productId;

  String _fmt(int n) =>
      n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final product = productAsync.valueOrNull;
    final bottom = MediaQuery.of(context).padding.bottom;

    return PremiumLayeredScaffold(
      subtitle: 'Дэлгүүр',
      title: 'Бараа',
      showBackButton: true,
      useNativeNavBar: true,
      expandBody: true,
      bottomBar: product != null && product.stock > 0
          ? Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceEl,
                border: Border(top: BorderSide(color: AppColors.borderSub)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: SacredButton(
                          label: 'Сагсанд',
                          outline: true,
                          small: true,
                          icon: Icons.add_shopping_cart_outlined,
                          onTap: () => _addToCart(context, ref, product),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SacredButton(
                          label: '₮${_fmt(product.price)} · Авах',
                          small: true,
                          sunShadow: true,
                          icon: Icons.shopping_bag_outlined,
                          onTap: () {
                            _addToCart(context, ref, product);
                            context.push('/shop/cart');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(formatUserError(e), style: AppText.bodySmall),
          ),
        ),
        data: (p) => ListView(
          padding: EdgeInsets.fromLTRB(20, 4, 20, bottom + 100),
          children: [
            _ProductHeroImage(product: p),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: MinimalStyle.card(radius: MinimalStyle.cardRadiusLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CategoryTag(label: p.category),
                      const Spacer(),
                      _StockBadge(stock: p.stock),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    p.name,
                    style: AppText.h2.copyWith(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₮${_fmt(p.price)}',
                        style: AppText.price.copyWith(
                          fontSize: 28,
                          color: AppColors.orange,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'MNT',
                          style: AppText.caption.copyWith(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (p.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: MinimalStyle.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Тайлбар',
                      style: AppText.h3.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.description,
                      style: AppText.body.copyWith(
                        color: AppColors.textSec,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (p.stock <= 0) ...[
              const SizedBox(height: 16),
              SacredButton(
                label: 'Дууссан',
                onTap: null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, Product product) {
    HapticFeedback.lightImpact();
    ref.read(cartProvider.notifier).addItem(product);
    showAppSnackBar(
      context,
      SnackBar(
        content: Text('${product.name} нэмэгдлээ'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ProductHeroImage extends StatelessWidget {
  const _ProductHeroImage({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MinimalStyle.card(radius: MinimalStyle.cardRadiusLg),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 1,
        child: product.image.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: product.image,
                fit: BoxFit.cover,
                placeholder: (_, __) => _ProductImagePlaceholder(
                  category: product.category,
                  loading: true,
                ),
                errorWidget: (_, __, ___) => _ProductImagePlaceholder(
                  category: product.category,
                ),
              )
            : _ProductImagePlaceholder(category: product.category),
      ),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder({
    required this.category,
    this.loading = false,
  });

  final String category;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final icon = CategoryChip.iconFor(category);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.orangeLight,
            AppColors.orangeLight.withOpacity(0.55),
            AppColors.creamBg,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -24,
            right: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orange.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -16,
            left: -16,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orange.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.all(22),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.orange,
                        ),
                      )
                    : Icon(
                        icon,
                        size: 34,
                        color: AppColors.orange.withOpacity(0.75),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                loading ? 'Зураг ачаалж байна...' : 'Зураг байхгүй',
                style: AppText.caption.copyWith(
                  color: AppColors.textSec,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.orangeLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.orange.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.orangeDeep,
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final inStock = stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: inStock
            ? AppColors.success.withOpacity(0.1)
            : AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: inStock ? AppColors.success : AppColors.danger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            inStock ? 'Байгаа · $stock' : 'Дууссан',
            style: AppText.caption.copyWith(
              color: inStock ? AppColors.success : AppColors.danger,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
