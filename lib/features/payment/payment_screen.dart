import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/formatters.dart';
import 'package:sacred_app/features/booking/providers/my_bookings_provider.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';
import 'package:sacred_app/features/payment/models/booking_payment_data.dart';
import 'package:sacred_app/features/payment/models/qpay_data.dart';
import 'package:sacred_app/features/payment/providers/booking_payment_provider.dart';
import 'package:sacred_app/features/shop/providers/shop_providers.dart';
import 'package:sacred_app/features/payment/widgets/bank_button.dart';
import 'package:sacred_app/features/payment/widgets/countdown_timer.dart';
import 'package:sacred_app/features/payment/widgets/pulsing_dot.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';
import 'package:sacred_app/shared/widgets/sacred_divider.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.bookingId,
    this.qpayData,
    this.initialMethodTab = 0,
  });

  final String bookingId;
  final QPayData? qpayData;
  final int initialMethodTab;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  Timer? _pollTimer;
  bool _paid = false;
  bool _expired = false;
  late int _methodTab;
  QPayData? _qpayData;
  bool _creatingQpay = false;
  bool _submittingBank = false;

  @override
  void initState() {
    super.initState();
    _methodTab = widget.initialMethodTab.clamp(0, 1);
    if (widget.qpayData != null) {
      _qpayData = widget.qpayData;
      _startPolling(widget.qpayData!.invoiceId);
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
    if (_paid) return;
    try {
      final res = await ref.read(apiClientProvider).get(
            '/payment/qpay/check/$invoiceId',
          );
      final body = res.data as Map<String, dynamic>;
      if (body['paid'] == true) {
        _pollTimer?.cancel();
        if (!mounted) return;
        setState(() => _paid = true);
        _invalidateBookings();
        _navigateToSuccess();
      }
    } catch (_) {}
  }

  void _invalidateBookings() {
    ref.invalidate(myBookingsProvider);
    ref.invalidate(monkBookingsProvider);
    ref.invalidate(bookingPaymentProvider(widget.bookingId));
  }

  void _navigateToSuccess([BookingPaymentData? payment]) {
    final data = _qpayData;
    final amount = data?.totalAmount ?? payment?.amount ?? 0;

    final isShopOrder = data?.monkName == 'Gevabal Дэлгүүр' ||
        data?.monkName == 'Sacred Дэлгүүр' ||
        (widget.bookingId.length == 24 &&
            (data?.serviceName?.contains('бараа') ?? false));

    if (isShopOrder) {
      ref.invalidate(myOrdersProvider);
      if (mounted) {
        context.go('/shop/orders');
      }
      return;
    }

    if (mounted) {
      context.go(
        '/payment/${widget.bookingId}/success',
        extra: PaymentSuccessArgs(
          monkName: data?.monkName ?? payment?.monkName ?? 'Лам',
          dateStr: data?.dateStr ?? payment?.date ?? '',
          timeSlot: data?.timeSlot ?? payment?.slot ?? '',
          amount: amount,
        ),
      );
    }
  }

  Future<void> _ensureQPay(BookingPaymentData payment) async {
    if (_qpayData != null || _creatingQpay) return;
    if (payment.qpay != null) {
      setState(() => _qpayData = payment.qpay);
      _startPolling(payment.qpay!.invoiceId);
      return;
    }
    setState(() => _creatingQpay = true);
    try {
      final qpay = await createBookingQPayInvoice(
        ref,
        bookingId: widget.bookingId,
        amount: payment.amount,
        payment: payment,
      );
      if (!mounted) return;
      setState(() => _qpayData = qpay);
      _startPolling(qpay.invoiceId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Алдаа: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _creatingQpay = false);
    }
  }

  Future<void> _submitBankTransfer() async {
    setState(() => _submittingBank = true);
    try {
      final res = await ref.read(apiClientProvider).post(
            '/payment/bank-transfer/${widget.bookingId}',
          );
      final data = res.data as Map<String, dynamic>;
      _invalidateBookings();
      if (!mounted) return;
      if (data['paid'] == true) {
        setState(() => _paid = true);
        final payment = await ref.read(
          bookingPaymentProvider(widget.bookingId).future,
        );
        _navigateToSuccess(payment);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Шилжүүлэг бүртгэгдлээ. Админ баталгаажуулах хүлээнэ.'),
          backgroundColor: AppColors.success,
        ),
      );
      ref.invalidate(bookingPaymentProvider(widget.bookingId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Алдаа: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _submittingBank = false);
    }
  }

  void _copy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label хуулагдлаа'), duration: const Duration(seconds: 1)),
    );
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

  Widget _summaryCard(BookingPaymentData payment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.inkDeep,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.goldPrime.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Нийт дүн',
            style: AppText.bodySmall.copyWith(color: AppColors.goldMuted),
          ),
          const SizedBox(height: 6),
          Text(
            Formatters.currency(payment.amount),
            style: AppText.h1.copyWith(color: AppColors.goldPrime, fontSize: 36),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.inkMid,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                if (payment.monkImage != null && payment.monkImage!.isNotEmpty)
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: CachedNetworkImageProvider(payment.monkImage!),
                  )
                else
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.inkLight,
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 18,
                      color: AppColors.goldMuted,
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.monkName,
                        style: AppText.bodySmall.copyWith(
                          color: AppColors.onDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        payment.serviceName,
                        style: AppText.caption.copyWith(color: AppColors.goldMuted),
                      ),
                    ],
                  ),
                ),
                Text(
                  payment.slot,
                  style: AppText.caption.copyWith(color: AppColors.goldMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankTab(BookingPaymentData payment, bool canPay) {
    final bank = payment.bank;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SacredCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Банкны данс', style: AppText.h3),
              const SizedBox(height: 16),
              _bankRow('Банк', bank.bankName, canPay),
              _bankRow('Данс', bank.accountNumber, canPay),
              _bankRow('Эзэмшигч', bank.accountHolder, canPay),
              _bankRow('Гүйлгээний утга', payment.reference, canPay),
              _bankRow('Дүн', Formatters.currency(payment.amount), false),
              if (!canPay)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Хэрэглэгч банкаар шилжүүлэг хийнэ',
                    style: AppText.caption.copyWith(color: AppColors.textSec),
                  ),
                ),
            ],
          ),
        ),
        if (payment.paymentPending) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_top_rounded, color: AppColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Банкны шилжүүлэг админ баталгаажуулах хүлээгдэж байна',
                    style: AppText.bodySmall.copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (canPay && !payment.paymentPending) ...[
          const SizedBox(height: 20),
          SacredButton(
            label: 'Би шилжүүлсэн',
            icon: Icons.check_circle_outline_rounded,
            isLoading: _submittingBank,
            onTap: _submittingBank ? null : _submitBankTransfer,
          ),
        ],
      ],
    );
  }

  Widget _bankRow(String label, String value, bool copyable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: AppText.bodySmall)),
          Expanded(
            child: Text(
              value,
              style: AppText.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18),
              color: AppColors.saffron,
              onPressed: () => _copy(label, value),
            ),
        ],
      ),
    );
  }

  Widget _qpayTab(BookingPaymentData payment, bool canPay) {
    if (!canPay) {
      return SacredCard(
        child: Text(
          'Хэрэглэгч QPay-ээр төлбөр төлнө',
          style: AppText.bodySmall.copyWith(color: AppColors.textSec),
        ),
      );
    }

    if (_creatingQpay || _qpayData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AppColors.saffron),
        ),
      );
    }

    final data = _qpayData!;
    return Column(
      children: [
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
                      : _buildQrImage(data.qrImageBase64),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Банкны апп-аар уншуулна уу', style: AppText.bodySmall),
              const SizedBox(height: 8),
              const PulsingDot(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: SacredDivider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('эсвэл банкаар нэвтрэх', style: AppText.caption),
            ),
            const Expanded(child: SacredDivider()),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.8,
          children: data.urls.map((bank) {
            return BankButton(
              bank: bank,
              onTap: () => launchUrl(
                Uri.parse(bank.link),
                mode: LaunchMode.externalApplication,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authStateProvider).valueOrNull?.role ?? 'client';
    final paymentAsync = ref.watch(bookingPaymentProvider(widget.bookingId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Төлбөр'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPri),
          onPressed: () => context.pop(),
        ),
      ),
      body: paymentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.saffron),
        ),
        error: (e, _) => Center(child: Text('Алдаа: $e', style: AppText.bodySmall)),
        data: (payment) {
          if (payment.paid) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 56, color: AppColors.success),
                    const SizedBox(height: 12),
                    Text('Төлбөр төлөгдсөн', style: AppText.h3),
                    const SizedBox(height: 20),
                    SacredButton(
                      label: 'Буцах',
                      outline: true,
                      small: true,
                      onTap: () => context.pop(),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!payment.canOpenPayment) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  payment.status == 'pending'
                      ? 'Админ баталгаажуулах хүлээгдэж байна'
                      : 'Төлбөр төлөх боломжгүй',
                  style: AppText.body,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final canPay = payment.canPay && role == 'client';
          if (_methodTab == 1 && canPay && _qpayData == null && !_creatingQpay) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _ensureQPay(payment);
            });
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Column(
              children: [
                if (role == 'monk')
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Хэрэглэгч төлбөр төлөх хэсэг — ${payment.clientName ?? "Захиалагч"}',
                      style: AppText.bodySmall.copyWith(color: AppColors.info),
                    ),
                  ),
                _summaryCard(payment),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceEl,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MethodTab(
                          label: 'Банкаар',
                          icon: Icons.account_balance_outlined,
                          selected: _methodTab == 0,
                          onTap: () => setState(() => _methodTab = 0),
                        ),
                      ),
                      Expanded(
                        child: _MethodTab(
                          label: 'QPay',
                          icon: Icons.qr_code_2_rounded,
                          selected: _methodTab == 1,
                          onTap: () {
                            setState(() => _methodTab = 1);
                            if (canPay) _ensureQPay(payment);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_methodTab == 0)
                  _bankTab(payment, canPay)
                else
                  _qpayTab(payment, canPay),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MethodTab extends StatelessWidget {
  const _MethodTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.primary : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.inkDeep : AppColors.textSec,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppText.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.inkDeep : AppColors.textSec,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
