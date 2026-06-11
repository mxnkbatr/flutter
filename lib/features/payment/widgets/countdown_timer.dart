import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    required this.seconds,
    this.onExpired,
  });

  final int seconds;
  final VoidCallback? onExpired;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= 0) {
        _timer?.cancel();
        widget.onExpired?.call();
        return;
      }
      setState(() => _remaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expired = _remaining <= 0;
    final isUrgent = _remaining < 60 && !expired;
    final minutes = (_remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remaining % 60).toString().padLeft(2, '0');

    if (expired) {
      return Text(
        'QR хугацаа дууссан',
        style: AppText.caption.copyWith(color: AppColors.danger),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 14,
          color: isUrgent ? AppColors.danger : AppColors.textSec,
        ),
        const SizedBox(width: 3),
        Text(
          '$minutes:$seconds',
          style: AppText.bodySmall.copyWith(
            color: isUrgent ? AppColors.danger : AppColors.textSec,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
