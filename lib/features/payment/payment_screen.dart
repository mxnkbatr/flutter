import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/formatters.dart';
import 'package:sacred_app/features/payment/models/qpay_data.dart';
import 'package:sacred_app/features/payment/widgets/bank_button.dart';
import 'package:sacred_app/features/payment/widgets/countdown_timer.dart';
import 'package:sacred_app/features/payment/widgets/pulsing_dot.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';
import 'package:sacred_app/shared/widgets/sacred_confirm_dialog.dart';
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

  QPayData? get _data => widget.qpayData;

  @override
  void initState() {
    super.initState();
    if (_data?.invoiceId != null) {
      _pollTimer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _checkPayment(),
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPayment() async {
    if (_paid || _data == null) return;
    try {
      final res = await ref.read(apiClientProvider).get(
            '/payment/qpay/check/${_data!.invoiceId}',
          );
      final body = res.data as Map<String, dynamic>;
      if (body['paid'] == true) {
        _pollTimer?.cancel();
        if (!mounted) return;
        setState(() => _paid = true);
        _navigateToSuccess();
      }
    } catch (_) {}
  }

  void _navigateToSuccess() {
    final data = _data!;
    context.go(
      '/payment/${widget.bookingId}/success',
      extra: PaymentSuccessArgs(
        monkName: data.monkName ?? 'Лам',
        dateStr: data.dateStr ?? '',
        timeSlot: data.timeSlot ?? '',
        amount: data.totalAmount,
      ),
    );
  }

  void _showExpiredDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => SacredConfirmDialog(
        title: 'QR хугацаа дууссан',
        message: 'Шинэ QR код авахын тулд захиалга хуудсаас дахин оролдоно уу.',
        confirmLabel: 'Ойлголоо',
        confirmColor: AppColors.goldPrime,
      ),
    ).then((_) {
      if (mounted) context.pop();
    });
  }

  void _showCancelWarning(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => const SacredConfirmDialog(
        title: 'Төлбөр цуцлах уу?',
        message: 'Төлбөр дуусаагүй бол захиалга хүчинтэй хэвээр үлдэнэ.',
        confirmLabel: 'Гарах',
        confirmColor: AppColors.danger,
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) context.pop();
    });
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
    final data = _data;

    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Төлбөр')),
        body: const Center(
          child: Text('Төлбөрийн мэдээлэл олдсонгүй', style: AppText.bodySmall),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Төлбөр'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPri),
          onPressed: () => _showCancelWarning(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          children: [
            Container(
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
                    style: AppText.bodySmall.copyWith(
                      color: AppColors.goldMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.currency(data.totalAmount),
                    style: AppText.h1.copyWith(
                      color: AppColors.goldPrime,
                      fontSize: 36,
                    ),
                  ),
                  if (data.monkName != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.inkMid,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          if (data.monkImage != null &&
                              data.monkImage!.isNotEmpty)
                            CircleAvatar(
                              radius: 18,
                              backgroundImage:
                                  CachedNetworkImageProvider(data.monkImage!),
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
                                  data.monkName!,
                                  style: AppText.bodySmall.copyWith(
                                    color: AppColors.onDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (data.serviceName != null)
                                  Text(
                                    data.serviceName!,
                                    style: AppText.caption.copyWith(
                                      color: AppColors.goldMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (data.timeSlot != null)
                            Text(
                              data.timeSlot!,
                              style: AppText.caption.copyWith(
                                color: AppColors.goldMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SacredCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('QPay QR код', style: AppText.h3),
                      CountdownTimer(
                        seconds: 600,
                        onExpired: () {
                          setState(() => _expired = true);
                          _showExpiredDialog();
                        },
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
                  const SizedBox(height: 4),
                  Text(
                    'Төлбөр хүлээн авч байна...',
                    style: AppText.caption.copyWith(color: AppColors.goldPrime),
                  ),
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
        ),
      ),
    );
  }
}
