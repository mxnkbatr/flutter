import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.current,
    required this.total,
    required this.labels,
  });

  final int current;
  final int total;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total * 2 - 1, (i) {
          if (i.isOdd) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: 2,
              color: i ~/ 2 < current ? AppColors.goldPrime : AppColors.border,
            );
          }
          final step = i ~/ 2;
          final done = step < current;
          final active = step == current;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.goldPrime
                      : active
                          ? AppColors.inkDeep
                          : AppColors.surfaceEl,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done || active
                        ? AppColors.goldPrime
                        : AppColors.border,
                    width: active ? 2 : 0.5,
                  ),
                ),
                child: Center(
                  child: done
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: AppColors.inkDeep,
                        )
                      : Text(
                          '${step + 1}',
                          style: AppText.caption.copyWith(
                            color: active
                                ? AppColors.goldPrime
                                : AppColors.textHint,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[step],
                style: AppText.caption.copyWith(
                  color: active ? AppColors.textPri : AppColors.textHint,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
