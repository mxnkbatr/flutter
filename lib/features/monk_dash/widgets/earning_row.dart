import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/utils/monk_dash_format.dart';

class EarningRow extends StatelessWidget {
  const EarningRow({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.bold = false,
  });

  final String label;
  final int value;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final prefix = value < 0 ? '-₮' : '₮';
    final display = '$prefix${fmtCurrency(value.abs())}';
    final style = (bold ? AppText.h3 : AppText.body).copyWith(
      color: color ?? AppColors.textPri,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.bodySmall)),
          Text(display, style: style),
        ],
      ),
    );
  }
}
