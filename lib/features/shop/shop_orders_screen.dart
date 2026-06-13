import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/shop/models/shop_order.dart';
import 'package:sacred_app/features/shop/providers/shop_providers.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';

class ShopOrdersScreen extends ConsumerWidget {
  const ShopOrdersScreen({super.key});

  String _fmt(int n) =>
      n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Миний захиалга')),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrime),
        ),
        error: (e, _) => Center(child: Text('Алдаа: $e')),
        data: (orders) => RefreshIndicator(
          color: AppColors.goldPrime,
          onRefresh: () => ref.refresh(myOrdersProvider.future),
          child: orders.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 80),
                    Center(child: Text('Захиалга байхгүй', style: AppText.bodySmall)),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (_, i) => _OrderCard(order: orders[i], fmt: _fmt),
                ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.fmt});
  final ShopOrder order;
  final String Function(int) fmt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SacredCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  order.statusLabel,
                  style: AppText.bodySmall.copyWith(
                    color: order.paid ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text('₮${fmt(order.totalAmount)}', style: AppText.price),
              ],
            ),
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${item.name} × ${item.quantity}',
                  style: AppText.bodySmall,
                ),
              ),
            ),
            if (order.createdAt.isNotEmpty)
              Text(order.createdAt.split('T').first, style: AppText.caption),
          ],
        ),
      ),
    );
  }
}
