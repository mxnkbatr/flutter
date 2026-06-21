import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  static IconData iconFor(String label) {
    return switch (label) {
      'Ерөөл' => Icons.volunteer_activism_outlined,
      'Зурхай' => Icons.auto_awesome_outlined,
      'Тахилга' => Icons.spa_outlined,
      'Номын тайлбар' => Icons.menu_book_outlined,
      'Бүгд' => Icons.grid_view_rounded,
      'Ном' => Icons.menu_book_outlined,
      'Эрдэнэ' => Icons.diamond_outlined,
      'Тос' => Icons.water_drop_outlined,
      'Бусад' => Icons.more_horiz_rounded,
      _ => Icons.circle_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final chipIcon = icon ?? iconFor(label);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.primary : null,
          color: isSelected ? null : AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.orange.withOpacity(0.35),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              chipIcon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.orange,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: isSelected ? AppText.chipActive : AppText.chipInactive,
            ),
          ],
        ),
      ),
    );
  }
}
