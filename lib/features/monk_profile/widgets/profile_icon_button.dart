import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';

class ProfileIconButton extends StatelessWidget {
  const ProfileIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: filled
            ? AppColors.sunOrange.withOpacity(0.15)
            : Colors.white.withOpacity(0.95),
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 20,
              color: filled ? AppColors.sunOrange : AppColors.inkDeep,
            ),
          ),
        ),
      ),
    );
  }
}
