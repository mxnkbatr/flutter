import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sacred_app/core/theme/app_colors.dart';

class MonkCardShimmer extends StatelessWidget {
  const MonkCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.borderSub,
      highlightColor: const Color(0xFFFFF1C5),
      period: const Duration(milliseconds: 1400),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSub, width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              height: 88,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.earthBrownLight,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 10,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
