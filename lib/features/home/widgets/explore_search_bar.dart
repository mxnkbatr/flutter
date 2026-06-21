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
        height: 54,
        padding: EdgeInsets.only(
          left: 8,
          right: minimal ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.borderSub,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.orange.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: AppColors.orangeSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                color: AppColors.orange.withOpacity(0.85),
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
                      : AppColors.textSec,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.1,
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
                    color: AppColors.orangeSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: AppColors.orangeDeep,
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
