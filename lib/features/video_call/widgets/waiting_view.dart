import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class WaitingView extends StatelessWidget {
  const WaitingView({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final message = role == 'monk'
        ? 'Хэрэглэгч холбогдохыг хүлээж байна...'
        : 'Лам холбогдохыг хүлээж байна...';

    return Container(
      color: AppColors.inkDeep,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/success.json',
            width: 140,
            height: 140,
            repeat: true,
            errorBuilder: (_, __, ___) => const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(color: AppColors.goldPrime),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: AppText.body.copyWith(color: AppColors.goldLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
