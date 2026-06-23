import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/formatters.dart';
import 'package:sacred_app/features/payment/models/qpay_data.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key, required this.args});

  final PaymentSuccessArgs args;

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _navigated = false;

  void _scheduleNavigate(Duration delay) {
    Future.delayed(delay, () {
      if (!mounted || _navigated) return;
      _navigated = true;
      context.go('/bookings');
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return Scaffold(
      backgroundColor: AppColors.inkDeep,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Lottie.asset(
              'assets/lottie/payment_success.json',
              width: 180,
              repeat: false,
              errorBuilder: (_, __, ___) {
                _scheduleNavigate(const Duration(milliseconds: 2000));
                return const Icon(
                  Icons.check_circle_rounded,
                  size: 120,
                  color: AppColors.goldPrime,
                );
              },
              onLoaded: (comp) {
                _scheduleNavigate(
                  comp.duration + const Duration(milliseconds: 800),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Төлбөр амжилттай!',
              style: AppText.h2.copyWith(color: AppColors.onDark),
            ),
            const SizedBox(height: 8),
            Text(
              args.canJoinCall
                  ? 'Захиалга баталгаажлаа'
                  : 'Төлбөр амжилттай төлөгдлөө',
              style: AppText.bodySmall.copyWith(color: AppColors.goldMuted),
            ),
            if (!args.canJoinCall) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Лам таны захиалгыг баталгаажуулах хүртэл хүлээнэ үү. '
                  'Баталгаажсаны дараа «Миний захиалга» хэсгээс видео дуудлага эхлүүлнэ.',
                  textAlign: TextAlign.center,
                  style: AppText.caption.copyWith(
                    color: AppColors.goldMuted.withOpacity(0.9),
                    height: 1.45,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.inkMid,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.goldPrime.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    _ConfirmRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Лам',
                      value: args.monkName,
                    ),
                    const SizedBox(height: 10),
                    _ConfirmRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Огноо',
                      value: args.dateStr,
                    ),
                    const SizedBox(height: 10),
                    _ConfirmRow(
                      icon: Icons.access_time_rounded,
                      label: 'Цаг',
                      value: args.timeSlot,
                    ),
                    const Divider(color: AppColors.inkLight, height: 20),
                    _ConfirmRow(
                      icon: Icons.monetization_on_outlined,
                      label: 'Төлсөн дүн',
                      value: Formatters.currency(args.amount),
                      valueStyle: AppText.price.copyWith(
                        color: AppColors.goldPrime,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (args.canJoinCall)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SacredButton(
                  label: 'Оруулах',
                  icon: Icons.videocam_rounded,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/call/${args.bookingId}');
                  },
                ),
              ),
            if (args.canJoinCall) const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SacredButton(
                label: 'Захиалга харах',
                outline: true,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/bookings');
                },
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.go('/home');
              },
              child: Text(
                'Нүүр хуудас руу буцах',
                style: AppText.bodySmall.copyWith(color: AppColors.goldMuted),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.goldMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: AppText.caption),
        ),
        Text(
          value,
          style: valueStyle ?? AppText.bodySmall.copyWith(color: AppColors.onDark),
        ),
      ],
    );
  }
}
