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
  /// Clean pill — white bg, thin border, no gradient filter button.
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
        padding: EdgeInsets.only(
          left: 18,
          right: minimal ? 18 : 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderSub, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: AppColors.textSec.withOpacity(0.7),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value?.isNotEmpty == true ? value! : hint,
                style: AppText.body.copyWith(
                  color: value?.isNotEmpty == true
                      ? AppColors.textPri
                      : AppColors.textSec,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!minimal && onFilterTap != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onFilterTap!();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.earthBrownLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.earthBrown,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
