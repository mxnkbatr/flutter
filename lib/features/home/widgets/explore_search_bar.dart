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
    this.value,
  });

  final String hint;
  final VoidCallback onTap;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.only(left: 20, right: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value?.isNotEmpty == true ? value! : hint,
                style: AppText.body.copyWith(
                  color: value?.isNotEmpty == true
                      ? AppColors.textPri
                      : AppColors.textSec,
                  fontWeight: value?.isNotEmpty == true
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: AppGradients.pillButton,
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.surfaceEl,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
