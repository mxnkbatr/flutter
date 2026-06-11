import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_profile/models/monk_review.dart';
import 'package:intl/intl.dart';

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review});

  final MonkReview review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(review.userName, style: AppText.h3.copyWith(fontSize: 14)),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: AppColors.goldPrime),
                  Text(
                    ' ${review.rating.toStringAsFixed(1)}',
                    style: AppText.caption,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(review.comment, style: AppText.body),
          const SizedBox(height: 4),
          Text(
            DateFormat('yyyy.MM.dd').format(review.createdAt),
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}
