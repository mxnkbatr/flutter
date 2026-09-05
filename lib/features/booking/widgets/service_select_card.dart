import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.orange : AppColors.borderSub,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.14),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : AppGradients.softCardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.orangeSoft : AppColors.creamWash,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _iconForCategory(service.category),
                color: AppColors.orangeDeep,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.displayName,
                    style: AppText.h3.copyWith(letterSpacing: -0.2),
                  ),
                  if (service.description != null) ...[
                    const SizedBox(height: 4),
                    Text(service.description!, style: AppText.bodySmall),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                      Text(
                        ' ${service.durationMinutes} мин',
                        style: AppText.caption,
                      ),
                      const Spacer(),
                      Text(
                        Formatters.currency(service.price),
                        style: AppText.price.copyWith(
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8, top: 2),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.orange,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
