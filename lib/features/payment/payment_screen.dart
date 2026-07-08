import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
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
import 'package:sacred_app/shared/widgets/error_state.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';
import 'package:sacred_app/shared/widgets/sacred_divider.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.bookingId,
    this.qpayData,
  });

  final String bookingId;
  final QPayData? qpayData;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  Timer? _pollTimer;
  bool _paid = false;
  bool _expired = false;
  bool _checkingPayment = false;
  QPayData? _qpayData;
  bool _creatingQpay = false;

  @override
  void initState() {
    super.initState();
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
    if (_paid || _checkingPayment) return;
    _checkingPayment = true;
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
    } catch (_) {} finally {
      _checkingPayment = false;
    }
  }

  void _invalidateBookings() {
    ref.invalidate(myBookingsProvider);
    ref.invalidate(monkBookingsProvider);
    ref.invalidate(bookingPaymentProvider(widget.bookingId));
  }

  Future<void> _navigateToSuccess([BookingPaymentData? payment]) async {
    final data = _qpayData;
    BookingPaymentData? info = payment;
    try {
      info ??= await ref.read(bookingPaymentProvider(widget.bookingId).future);
    } catch (_) {}
    final amount = data?.totalAmount ?? info?.amount ?? 0;

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
      final status = info?.status ?? 'pending';
      final canJoin = info != null && info.paid && status == 'confirmed';
      context.go(
        '/payment/${widget.bookingId}/success',
        extra: PaymentSuccessArgs(
          bookingId: widget.bookingId,
          monkName: data?.monkName ?? info?.monkName ?? 'Лам',
          dateStr: data?.dateStr ?? info?.date ?? '',
          timeSlot: data?.timeSlot ?? info?.slot ?? '',
          amount: amount,
          bookingStatus: status,
          canJoinCall: canJoin,
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
          SnackBar(content: Text(formatUserError(e)), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _creatingQpay = false);
    }
  }

  Future<void> _regenerateQPay(BookingPaymentData payment) async {
    setState(() {
      _creatingQpay = true;
      _expired = false;
      _qpayData = null;
    });
    _pollTimer?.cancel();
    try {
      final qpay = await createBookingQPayInvoice(
        ref,
        bookingId: widget.bookingId,
        amount: payment.amount,
        payment: payment,
        regenerate: true,
      );
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
      if (mounted) setState(() => _creatingQpay = false);
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
                Flexible(
                  child: Text(
                    payment.slot,
                    style: AppText.caption.copyWith(color: AppColors.goldMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qpaySection(BookingPaymentData payment, bool canPay) {
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
              if (_expired) ...[
                SacredButton(
                  label: 'Шинэ QR авах',
                  isLoading: _creatingQpay,
                  onTap: _creatingQpay ? null : () => _regenerateQPay(payment),
                ),
                const SizedBox(height: 8),
              ] else ...[
                const Text('Банкны апп-аар уншуулна уу', style: AppText.bodySmall),
                const SizedBox(height: 8),
                const PulsingDot(),
              ],
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

    return PremiumLayeredScaffold(
      title: 'Төлбөр',
      showBackButton: true,
      backIcon: Icons.close_rounded,
      expandBody: true,
      body: paymentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.saffron),
        ),
        error: (e, _) => ErrorState(
          error: e,
          fallback: 'Төлбөрийн мэдээлэл ачаалахад алдаа гарлаа.',
          onRetry: () => ref.invalidate(bookingPaymentProvider(widget.bookingId)),
        ),
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
                    const SizedBox(height: 8),
                    Text(
                      payment.status == 'confirmed'
                          ? 'Одоо үйлчилгээнд орох боломжтой'
                          : 'Баталгаажуулалт хүлээгдэж байна',
                      style: AppText.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    if (payment.status == 'confirmed') ...[
                      SacredButton(
                        label: 'Оруулах',
                        icon: Icons.videocam_rounded,
                        onTap: () => context.go('/call/${widget.bookingId}'),
                      ),
                      const SizedBox(height: 10),
                    ],
                    SacredButton(
                      label: 'Захиалга харах',
                      outline: true,
                      small: true,
                      onTap: () => context.go('/bookings'),
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
                      ? 'Лам баталгаажуулах хүлээгдэж байна'
                      : 'Төлбөр төлөх боломжгүй',
                  style: AppText.body,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final canPay = payment.canPay && role == 'client';
          if (canPay && _qpayData == null && !_creatingQpay) {
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
                _qpaySection(payment, canPay),
              ],
            ),
          );
        },
      ),
    );
  }
}
