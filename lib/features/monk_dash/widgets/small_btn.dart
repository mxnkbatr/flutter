import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class SmallBtn extends StatelessWidget {
  const SmallBtn({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.outline = false,
    this.textColor,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool outline;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: outline ? 1 : 0),
        ),
        child: Text(
          label,
          style: AppText.caption.copyWith(
            color: textColor ?? (outline ? color : Colors.white),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
