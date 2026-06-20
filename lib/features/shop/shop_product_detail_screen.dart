import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/shop/providers/shop_providers.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

class ShopProductDetailScreen extends ConsumerWidget {
  const ShopProductDetailScreen({super.key, required this.productId});

  final String productId;

  String _fmt(int n) =>
      n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Бараа')),
      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrime),
        ),
        error: (e, _) => Center(child: Text(formatUserError(e))),
        data: (product) => ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: product.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.category, style: AppText.caption),
                  const SizedBox(height: 6),
                  Text(product.name, style: AppText.h2),
                  const SizedBox(height: 8),
                  Text(
                    '₮${_fmt(product.price)}',
                    style: AppText.price.copyWith(color: AppColors.saffronDeep),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.stock > 0
                        ? 'Үлдэгдэл: ${product.stock}'
                        : 'Дууссан',
                    style: AppText.bodySmall.copyWith(
                      color: product.stock > 0
                          ? AppColors.textSec
                          : AppColors.danger,
                    ),
                  ),
                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Тайлбар', style: AppText.h3.copyWith(fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(product.description, style: AppText.body),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SacredButton(
                          label: product.stock > 0 ? 'Сагсанд нэмэх' : 'Дууссан',
                          outline: true,
                          small: true,
                          icon: Icons.add_shopping_cart_outlined,
                          onTap: product.stock > 0
                              ? () {
                                  HapticFeedback.lightImpact();
                                  ref.read(cartProvider.notifier).addItem(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} нэмэгдлээ'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SacredButton(
                          label: product.stock > 0 ? 'Худалдаж авах' : 'Дууссан',
                          small: true,
                          sunShadow: true,
                          icon: Icons.shopping_bag_outlined,
                          onTap: product.stock > 0
                              ? () {
                                  HapticFeedback.lightImpact();
                                  ref.read(cartProvider.notifier).addItem(product);
                                  context.push('/shop/cart');
                                }
                              : null,
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

  Widget _placeholder() {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.monkCardBg),
      child: const Center(
        child: Icon(Icons.storefront_outlined, size: 48, color: AppColors.goldMuted),
      ),
    );
  }
}
