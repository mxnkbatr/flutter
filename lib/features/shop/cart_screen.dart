import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/payment/models/qpay_data.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/features/shop/models/cart_item.dart';
import 'package:sacred_app/features/shop/providers/shop_providers.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';
import 'package:sacred_app/shared/widgets/sacred_input.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _ordering = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  String _fmt(int n) =>
      n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  Future<void> _checkout(List<CartItem> cart) async {
    if (cart.isEmpty) return;
    if (_phoneCtrl.text.trim().isEmpty || _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Утас болон хаяг заавал бөглөнө үү'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    setState(() => _ordering = true);
    try {
      final res = await ref.read(apiClientProvider).post(
            '/shop/orders',
            data: {
              'items': cart
                  .map(
                    (i) => {
                      'productId': i.product.id,
                      'quantity': i.quantity,
                    },
                  )
                  .toList(),
              'phone': _phoneCtrl.text.trim(),
              'address': _addressCtrl.text.trim(),
            },
          );
      final data = res.data as Map<String, dynamic>;

      if (data['dev'] == true) {
        ref.read(cartProvider.notifier).clear();
        ref.invalidate(myOrdersProvider);
        if (mounted) context.go('/shop/orders');
        return;
      }

      final orderId = (data['order'] as Map<String, dynamic>)['id'] as String;
      final qpayData = QPayData.fromJson(data)
          .copyWithAmount(ref.read(cartTotalProvider))
          .copyWithSummary(
            monkName: 'Gevabal Дэлгүүр',
            serviceName: '${cart.length} бараа',
          );

      if (mounted) context.go('/shop/payment/$orderId', extra: qpayData);
    } catch (e) {
      String msg = formatUserError(e, fallback: 'Захиалга үүсгэхэд алдаа гарлаа.');
      if (e.toString().contains('Бүтээгдэхүүн олдсонгүй')) {
        msg = 'Сагсан дахь зарим бараа худалдаанаас хасагдсан байна. Сагсыг шинэчилнэ үү.';
        ref.invalidate(productsProvider);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Сагс'),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              child: Text(
                'Цэвэрлэх',
                style: AppText.bodySmall.copyWith(color: AppColors.danger),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 56,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 12),
                  Text('Сагс хоосон', style: AppText.h3),
                  const SizedBox(height: 8),
                  Text('Дэлгүүрээс бараа нэмнэ үү', style: AppText.bodySmall),
                  const SizedBox(height: 20),
                  SacredButton(
                    label: 'Дэлгүүр рүү буцах',
                    small: true,
                    onTap: () => context.go('/shop'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...cart.map((item) => _CartItemRow(item: item)),
                      const SizedBox(height: 16),
                      SacredInput(
                        label: 'Утасны дугаар',
                        controller: _phoneCtrl,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      SacredInput(
                        label: 'Хүргэлтийн хаяг',
                        controller: _addressCtrl,
                        prefixIcon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    MediaQuery.of(context).padding.bottom + 16,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceEl,
                    border: Border(
                      top: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Нийт дүн', style: AppText.body),
                          Text(
                            '₮${_fmt(total)}',
                            style: AppText.price.copyWith(
                              color: AppColors.saffronDeep,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SacredButton(
                        label: 'QPay-р төлөх  ₮${_fmt(total)}',
                        isLoading: _ordering,
                        onTap: () => _checkout(cart),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartItemRow extends ConsumerWidget {
  const _CartItemRow({required this.item});
  final CartItem item;

  String _fmt(int n) =>
      n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SacredCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 60,
                child: item.product.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.product.image,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.goldLight,
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: AppColors.goldMuted,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: AppText.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₮${_fmt(item.product.price)}',
                    style: AppText.caption.copyWith(color: AppColors.saffronDeep),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _QtyBtn(
                  icon: Icons.remove_rounded,
                  onTap: () =>
                      ref.read(cartProvider.notifier).decrement(item.product.id),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '${item.quantity}',
                    style: AppText.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                _QtyBtn(
                  icon: Icons.add_rounded,
                  onTap: () =>
                      ref.read(cartProvider.notifier).increment(item.product.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.goldLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Icon(icon, size: 16, color: AppColors.saffronDeep),
      ),
    );
  }
}
