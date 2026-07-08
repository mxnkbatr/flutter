import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/utils/formatters.dart';
import 'package:sacred_app/features/payment/models/qpay_data.dart';
import 'package:sacred_app/features/payment/widgets/bank_button.dart';
import 'package:sacred_app/features/payment/widgets/countdown_timer.dart';
import 'package:sacred_app/features/payment/widgets/pulsing_dot.dart';
import 'package:sacred_app/features/shop/models/shop_order.dart';
import 'package:sacred_app/features/shop/providers/shop_providers.dart';
import 'package:sacred_app/shared/widgets/error_state.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopOrderPaymentData {
  const ShopOrderPaymentData({
    required this.order,
    required this.canPay,
    this.qpay,
  });

  final ShopOrder order;
  final bool canPay;
  final QPayData? qpay;

  factory ShopOrderPaymentData.fromJson(Map<String, dynamic> json) {
    final order = ShopOrder.fromJson(json['order'] as Map<String, dynamic>);
    final qpayRaw = json['qpay'] as Map<String, dynamic>?;
    QPayData? qpay;
    if (qpayRaw != null) {
      qpay = QPayData.fromJson(qpayRaw).copyWithSummary(
        monkName: 'Gevabal Дэлгүүр',
        serviceName: '${order.items.length} бараа',
      );
    }
    return ShopOrderPaymentData(
      order: order,
      canPay: json['canPay'] as bool? ?? false,
      qpay: qpay,
    );
  }
}

final shopOrderPaymentProvider =
    FutureProvider.family<ShopOrderPaymentData, String>((ref, orderId) async {
  final res = await ref.read(apiClientProvider).get('/payment/order/$orderId');
  return ShopOrderPaymentData.fromJson(res.data as Map<String, dynamic>);
});

class ShopPaymentScreen extends ConsumerStatefulWidget {
  const ShopPaymentScreen({
    super.key,
    required this.orderId,
    this.qpayData,
  });

  final String orderId;
  final QPayData? qpayData;

  @override
  ConsumerState<ShopPaymentScreen> createState() => _ShopPaymentScreenState();
}

class _ShopPaymentScreenState extends ConsumerState<ShopPaymentScreen> {
  Timer? _pollTimer;
  bool _paid = false;
  bool _expired = false;
  bool _regenerating = false;
  bool _checkingPayment = false;
  QPayData? _qpayData;

  @override
  void initState() {
    super.initState();
    _qpayData = widget.qpayData;
    if (_qpayData != null) {
      _startPolling(_qpayData!.invoiceId);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling(String invoiceId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkPayment(invoiceId),
    );
  }

  Future<void> _checkPayment(String invoiceId) async {
    if (_paid || _checkingPayment) return;
    _checkingPayment = true;
    try {
      final res = await ref.read(apiClientProvider).get(
            '/payment/qpay/check/$invoiceId',
          );
      if ((res.data as Map<String, dynamic>)['paid'] == true) {
        await _onPaid();
      }
    } catch (_) {} finally {
      _checkingPayment = false;
    }
  }

  Future<void> _onPaid() async {
    _pollTimer?.cancel();
    if (!mounted) return;
    setState(() => _paid = true);
    ref.read(cartProvider.notifier).clear();
    ref.invalidate(myOrdersProvider);
    ref.invalidate(shopOrderPaymentProvider(widget.orderId));
    if (mounted) context.go('/shop/orders');
  }

  Future<void> _regenerateQPay() async {
    setState(() {
      _regenerating = true;
      _expired = false;
      _qpayData = null;
    });
    _pollTimer?.cancel();
    try {
      final res = await ref.read(apiClientProvider).post(
            '/shop/orders/${widget.orderId}/qpay',
            data: {'regenerate': true},
          );
      final qpay = QPayData.fromJson(res.data as Map<String, dynamic>);
      if (!mounted) return;
      setState(() => _qpayData = qpay);
      _startPolling(qpay.invoiceId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatUserError(e)), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _regenerating = false);
    }
  }

  Widget _buildQrImage(String base64Str) {
    try {
      final bytes = base64Decode(base64Str);
      return Image.memory(bytes, fit: BoxFit.contain);
    } catch (_) {
      return const Center(
        child: Icon(Icons.qr_code_2, size: 64, color: AppColors.goldPrime),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentAsync = ref.watch(shopOrderPaymentProvider(widget.orderId));

    return PremiumLayeredScaffold(
      title: 'Дэлгүүрийн төлбөр',
      showBackButton: true,
      backIcon: Icons.close_rounded,
      expandBody: true,
      onRefresh: () =>
          ref.refresh(shopOrderPaymentProvider(widget.orderId).future),
      body: paymentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrime),
        ),
        error: (e, _) => ErrorState(
          error: e,
          fallback: 'Захиалгын мэдээлэл ачаалахад алдаа гарлаа.',
          onRetry: () => ref.invalidate(shopOrderPaymentProvider(widget.orderId)),
        ),
        data: (payment) {
          if (payment.order.paid || _paid) {
            return const Center(child: Text('Төлбөр төлөгдсөн'));
          }

          final qpay = _qpayData ?? payment.qpay;
          if (qpay != null && _qpayData == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _qpayData = qpay);
                _startPolling(qpay.invoiceId);
              }
            });
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
                SacredCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gevabal Дэлгүүр', style: AppText.h3),
                      const SizedBox(height: 8),
                      ...payment.order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${item.name} × ${item.quantity}',
                            style: AppText.bodySmall,
                          ),
                        ),
                      ),
                      const Divider(height: 20),
                      Text(
                        'Нийт: ${Formatters.currency(payment.order.totalAmount)}',
                        style: AppText.price,
                      ),
                    ],
                  ),
                ),
                if (qpay != null) ...[
                  const SizedBox(height: 20),
                  SacredCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('QPay QR код', style: AppText.h3),
                            CountdownTimer(
                              seconds: 600,
                              onExpired: () => setState(() => _expired = true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 200,
                          height: 200,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.inkDeep,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _expired
                                ? Center(
                                    child: Text(
                                      'QR хугацаа\nдууссан',
                                      textAlign: TextAlign.center,
                                      style: AppText.bodySmall.copyWith(
                                        color: AppColors.goldMuted,
                                      ),
                                    ),
                                  )
                                : _buildQrImage(qpay.qrImageBase64),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_expired) ...[
                          SacredButton(
                            label: 'Шинэ QR авах',
                            isLoading: _regenerating,
                            onTap: _regenerating ? null : _regenerateQPay,
                          ),
                        ] else ...[
                          const Text('Банкны апп-аар уншуулна уу', style: AppText.bodySmall),
                          const SizedBox(height: 8),
                          const PulsingDot(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.8,
                    children: qpay.urls.map((bank) {
                      return BankButton(
                        bank: bank,
                        onTap: () => launchUrl(
                          Uri.parse(bank.link),
                          mode: LaunchMode.externalApplication,
                        ),
                      );
                    }).toList(),
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: Text('Төлбөрийн мэдээлэл ачаалж байна...')),
                  ),
              ],
            );
        },
      ),
    );
  }
}
