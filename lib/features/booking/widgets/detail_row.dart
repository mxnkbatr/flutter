import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: labelStyle ?? AppText.bodySmall),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: valueStyle ?? AppText.body,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
