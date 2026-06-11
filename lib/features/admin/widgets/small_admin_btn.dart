import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class SmallAdminBtn extends StatelessWidget {
  const SmallAdminBtn({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.outline = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: AppText.caption.copyWith(
            color: outline ? color : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
