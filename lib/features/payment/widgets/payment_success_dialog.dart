import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

class PaymentSuccessDialog extends StatefulWidget {
  const PaymentSuccessDialog({
    super.key,
    required this.onDone,
  });

  final VoidCallback onDone;

  @override
  State<PaymentSuccessDialog> createState() => _PaymentSuccessDialogState();
}

class _PaymentSuccessDialogState extends State<PaymentSuccessDialog> {
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _autoCloseTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceEl,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/success.json',
              width: 120,
              height: 120,
              repeat: false,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Төлбөр амжилттай!', style: AppText.h2),
            const SizedBox(height: 8),
            const Text(
              'Таны захиалга баталгаажлаа',
              style: AppText.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SacredButton(
              label: 'Захиалгууд руу',
              onTap: widget.onDone,
            ),
          ],
        ),
      ),
    );
  }
}
