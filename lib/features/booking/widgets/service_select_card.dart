import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/formatters.dart';
import 'package:sacred_app/features/monk_profile/models/monk_service.dart';

class ServiceSelectCard extends StatelessWidget {
  const ServiceSelectCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  final MonkService service;
  final bool isSelected;
  final VoidCallback onTap;

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Ерөөл':
        return Icons.volunteer_activism_outlined;
      case 'Зурхай':
        return Icons.nightlight_round_outlined;
      case 'Тахилга':
        return Icons.local_fire_department_outlined;
      case 'Номын тайлбар':
        return Icons.menu_book_outlined;
      default:
        return Icons.spa_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.goldPrime : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.goldLight : AppColors.borderSub,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconForCategory(service.category),
                color: AppColors.goldDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.displayName, style: AppText.h3),
                  if (service.description != null) ...[
                    const SizedBox(height: 4),
                    Text(service.description!, style: AppText.bodySmall),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppColors.textHint),
                      Text(
                        ' ${service.durationMinutes} мин',
                        style: AppText.caption,
                      ),
                      const Spacer(),
                      Text(
                        Formatters.currency(service.price),
                        style: AppText.price.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8, top: 4),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.goldPrime,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
