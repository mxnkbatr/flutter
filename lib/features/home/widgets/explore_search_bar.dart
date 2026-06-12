import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({
    super.key,
    required this.hint,
    required this.onTap,
    this.onFilterTap,
    this.value,
    this.lightOnBlue = false,
  });

  final String hint;
  final VoidCallback onTap;
  final VoidCallback? onFilterTap;
  final String? value;
  final bool lightOnBlue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 54,
        padding: const EdgeInsets.only(left: 18, right: 6),
        decoration: BoxDecoration(
          color: lightOnBlue
              ? Colors.white.withOpacity(0.95)
              : AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: lightOnBlue
                ? Colors.white.withOpacity(0.5)
                : AppColors.border.withOpacity(0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(lightOnBlue ? 0.12 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: lightOnBlue ? AppColors.saffron : AppColors.textSec,
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
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onFilterTap == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      onFilterTap!();
                    },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  onFilterTap != null
                      ? Icons.tune_rounded
                      : Icons.search_rounded,
                  color: Colors.white,
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
