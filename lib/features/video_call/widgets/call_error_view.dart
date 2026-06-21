import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/auth_ambient_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

class CallErrorView extends StatelessWidget {
  const CallErrorView({
    super.key,
    required this.message,
    required this.onBack,
    this.onRetry,
  });

  final String message;
  final VoidCallback onBack;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: Stack(
        children: [
          const AuthAmbientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: AppColors.inkDeep,
                      ),
                      onPressed: onBack,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceEl,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.borderSub),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.videocam_off_rounded,
                            color: AppColors.danger,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Холболт амжилтгүй',
                          style: AppText.displaySerif(
                            size: 24,
                            color: AppColors.inkDeep,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          style: AppText.bodySmall.copyWith(
                            color: AppColors.textSec,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  if (onRetry != null) ...[
                    SacredButton(
                      label: 'Дахин оролдох',
                      sunShadow: true,
                      onTap: onRetry,
                    ),
                    const SizedBox(height: 12),
                  ],
                  SacredButton(
                    label: 'Буцах',
                    outline: true,
                    onTap: onBack,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
