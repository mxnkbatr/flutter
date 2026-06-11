import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/payment/models/qpay_data.dart';
import 'package:sacred_app/features/payment/widgets/bank_button.dart';
import 'package:sacred_app/features/payment/widgets/countdown_timer.dart';
import 'package:sacred_app/features/subscription/providers/subscription_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPaymentSheet extends ConsumerStatefulWidget {
  const SubscriptionPaymentSheet({
    super.key,
    required this.tier,
    required this.monthlyPrice,
  });

  final String tier;
  final int monthlyPrice;

  @override
  ConsumerState<SubscriptionPaymentSheet> createState() =>
      _SubscriptionPaymentSheetState();
}

class _SubscriptionPaymentSheetState
    extends ConsumerState<SubscriptionPaymentSheet> {
  static const _monthOptions = [1, 3, 6, 12];

  int _months = 1;
  QPayData? _qpayData;
  bool _loading = false;
  bool _paid = false;
  bool _expired = false;
  Timer? _pollTimer;
  String? _error;

  int get _total => widget.monthlyPrice * _months;

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );

  String _tierTitle() => switch (widget.tier) {
        'vip' => 'VIP',
        _ => 'Premium',
      };

  Future<void> _createInvoice() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await createSubscriptionInvoice(
        ref,
        tier: widget.tier,
        months: _months,
      );
      if (!mounted) return;
      setState(() {
        _qpayData = data.totalAmount > 0
            ? data
            : QPayData(
                invoiceId: data.invoiceId,
                qrImageBase64: data.qrImageBase64,
                totalAmount: _total,
                urls: data.urls,
              );
        _loading = false;
      });
      _startPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkPayment());
  }

  Future<void> _checkPayment() async {
    if (_paid || _qpayData == null) return;
    try {
      final res = await ref.read(apiClientProvider).get(
            '/payment/qpay/check/${_qpayData!.invoiceId}',
          );
      final data = res.data as Map<String, dynamic>;
      if (data['paid'] == true) {
        _pollTimer?.cancel();
        await activateSubscription(
          ref,
          tier: widget.tier,
          invoiceId: _qpayData!.invoiceId,
        );
        if (!mounted) return;
        setState(() => _paid = true);
      }
    } catch (_) {}
  }

  Widget _buildQrImage(String base64Str) {
    try {
      final bytes = base64Decode(base64Str);
      return Image.memory(bytes, fit: BoxFit.contain);
    } catch (_) {
      return const Icon(Icons.qr_code_2, size: 64, color: AppColors.goldPrime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inkLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_tierTitle()} багц',
            style: AppText.h2.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_paid) ...[
            const Icon(Icons.check_circle, color: AppColors.success, size: 56),
            const SizedBox(height: 12),
            Text(
              'Premium идэвхжлээ!',
              style: AppText.h3.copyWith(color: AppColors.goldPrime),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Хаах'),
            ),
          ] else if (_qpayData == null) ...[
            Text(
              'Хугацаа сонгох',
              style: AppText.bodySmall.copyWith(color: AppColors.goldMuted),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _monthOptions.map((m) {
                final selected = _months == m;
                return ChoiceChip(
                  label: Text('$m сар'),
                  selected: selected,
                  onSelected: (_) => setState(() => _months = m),
                  selectedColor: AppColors.goldPrime,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.inkDeep : AppColors.goldMuted,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Нийт: ₮${_fmt(_total)}',
              style: AppText.h2.copyWith(color: AppColors.goldPrime),
              textAlign: TextAlign.center,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: AppText.caption.copyWith(color: AppColors.danger)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _createInvoice,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrime,
                foregroundColor: AppColors.inkDeep,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('QPay-ээр төлөх'),
            ),
          ] else ...[
            Text(
              '₮${_fmt(_qpayData!.totalAmount)}',
              style: AppText.h2.copyWith(color: AppColors.goldPrime),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.inkMid,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: _expired
                  ? const Center(
                      child: Text(
                        'QR хугацаа дууссан',
                        style: TextStyle(color: AppColors.goldMuted),
                      ),
                    )
                  : _buildQrImage(_qpayData!.qrImageBase64),
            ),
            const SizedBox(height: 8),
            CountdownTimer(
              seconds: 600,
              onExpired: () => setState(() => _expired = true),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _qpayData!.urls.map((bank) {
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
        ],
      ),
    );
  }
}
