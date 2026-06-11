import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class ExploreFilterRow extends StatelessWidget {
  const ExploreFilterRow({
    super.key,
    required this.categoryLabel,
    required this.sortLabel,
    this.onCategoryTap,
    this.onSortTap,
  });

  final String categoryLabel;
  final String sortLabel;
  final VoidCallback? onCategoryTap;
  final VoidCallback? onSortTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceEl,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _FilterCell(
                label: 'Ангилал',
                value: categoryLabel,
                onTap: onCategoryTap,
              ),
            ),
            Container(width: 1, color: AppColors.border),
            Expanded(
              child: _FilterCell(
                label: 'Эрэмбэ',
                value: sortLabel,
                onTap: onSortTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterCell extends StatelessWidget {
  const _FilterCell({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.caption),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppText.body.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
