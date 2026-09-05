import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({
    super.key,
    required this.hint,
    required this.onTap,
    this.onFilterTap,
    this.value,
    this.minimal = false,
  });

  final String hint;
  final VoidCallback onTap;
  final VoidCallback? onFilterTap;
  final String? value;
  final bool minimal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSub),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(left: 4),
              decoration: const BoxDecoration(
                color: AppColors.orangeSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.orangeDeep,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value?.isNotEmpty == true ? value! : hint,
                style: AppText.body.copyWith(
                  color: value?.isNotEmpty == true
                      ? AppColors.textPri
                      : AppColors.textHint,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!minimal)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  (onFilterTap ?? onTap)();
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.orangeSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    onFilterTap != null
                        ? Icons.tune_rounded
                        : Icons.history_rounded,
                    color: AppColors.orangeDeep,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
