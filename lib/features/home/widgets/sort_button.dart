import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

const monkSortOptions = ['Үнэлгээ', 'Үнэ (доош)', 'Үнэ (дээш)', 'Шинэ'];

class SortButton extends StatelessWidget {
  const SortButton({
    super.key,
    required this.current,
    required this.onSort,
  });

  final String current;
  final ValueChanged<String> onSort;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        HapticFeedback.lightImpact();
        onSort(value);
      },
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            current,
            style: AppText.bodySmall.copyWith(color: AppColors.sunGold),
          ),
          const SizedBox(width: 2),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.sunGold,
          ),
        ],
      ),
      itemBuilder: (context) => monkSortOptions
          .map(
            (opt) => PopupMenuItem<String>(
              value: opt,
              child: Text(
                opt,
                style: AppText.bodySmall.copyWith(
                  fontWeight: opt == current ? FontWeight.w600 : FontWeight.w400,
                  color: opt == current ? AppColors.sunGold : AppColors.textPri,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
