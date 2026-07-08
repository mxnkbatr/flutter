import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/utils/app_feedback.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/shop/models/shop_order.dart';
import 'package:sacred_app/features/shop/providers/shop_providers.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';

class AdminShopOrdersTab extends ConsumerWidget {
  const AdminShopOrdersTab({super.key});

  static const _filters = [
    ('all', 'Бүгд'),
    ('pending', 'Хүлээгдэж буй'),
    ('paid', 'Төлөгдсөн'),
    ('shipped', 'Хүргэлтэд'),
    ('delivered', 'Хүргэгдсэн'),
    ('cancelled', 'Цуцлагдсан'),
  ];

  static const _statusActions = [
    ('paid', 'Төлөгдсөн'),
    ('shipped', 'Хүргэлтэд гаргах'),
    ('delivered', 'Хүргэгдсэн'),
    ('cancelled', 'Цуцлах'),
  ];

  String _fmt(int n) =>
      n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  List<ShopOrder> _filterOrders(List<ShopOrder> orders, String filter) {
    if (filter == 'all') return orders;
    return orders.where((o) => o.status == filter).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(adminShopOrderFilterProvider);
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final (value, label) = _filters[index];
              final selected = filter == value;
              return FilterChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) =>
                    ref.read(adminShopOrderFilterProvider.notifier).state = value,
                selectedColor: AppColors.goldLight,
              );
            },
          ),
        ),
        Expanded(
          child: ordersAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.goldPrime),
            ),
            error: (e, _) => Center(child: Text(formatUserError(e))),
            data: (orders) {
              final filtered = _filterOrders(orders, filter);
              return RefreshIndicator(
                color: AppColors.goldPrime,
                onRefresh: () => ref.refresh(adminOrdersProvider.future),
                child: filtered.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(
                            child: Text(
                              'Дэлгүүрийн захиалга байхгүй',
                              style: AppText.bodySmall,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _AdminOrderCard(
                          order: filtered[i],
                          fmt: _fmt,
                          onStatusChange: (status) async {
                            try {
                              await adminUpdateOrderStatus(
                                ref,
                                filtered[i].id,
                                status,
                              );
                              if (context.mounted) {
                                showAppSnackBar(
                                  context,
                                  const SnackBar(
                                    content: Text('Захиалгын төлөв шинэчлэгдлээ'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showAppSnackBar(
                                  context,
                                  SnackBar(
                                    content: Text(formatUserError(e)),
                                    backgroundColor: AppColors.danger,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({
    required this.order,
    required this.fmt,
    required this.onStatusChange,
  });

  final ShopOrder order;
  final String Function(int) fmt;
  final Future<void> Function(String status) onStatusChange;

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
                Expanded(
                  child: Text(
                    order.userName.isNotEmpty ? order.userName : 'Хэрэглэгч',
                    style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  order.statusLabel,
                  style: AppText.bodySmall.copyWith(
                    color: order.paid ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  color: AppColors.surfaceEl,
                  onSelected: onStatusChange,
                  itemBuilder: (_) => AdminShopOrdersTab._statusActions
                      .map(
                        (e) => PopupMenuItem(
                          value: e.$1,
                          child: Text(e.$2),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            if (order.phone.isNotEmpty || order.address.isNotEmpty) ...[
              const SizedBox(height: 6),
              if (order.phone.isNotEmpty)
                Text('Утас: ${order.phone}', style: AppText.caption),
              if (order.address.isNotEmpty)
                Text('Хаяг: ${order.address}', style: AppText.caption),
            ],
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${item.name} × ${item.quantity} — ₮${fmt(item.price * item.quantity)}',
                  style: AppText.bodySmall,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (order.createdAt.isNotEmpty)
                  Text(
                    order.createdAt.split('T').first,
                    style: AppText.caption,
                  ),
                const Spacer(),
                Text('Нийт: ₮${fmt(order.totalAmount)}', style: AppText.price),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
