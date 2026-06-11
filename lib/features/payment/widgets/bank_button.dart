import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/payment/models/qpay_data.dart';

class BankButton extends StatelessWidget {
  const BankButton({
    super.key,
    required this.bank,
    required this.onTap,
  });

  final QPayBankUrl bank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (bank.logo != null && bank.logo!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: bank.logo!,
                  width: 24,
                  height: 24,
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.account_balance,
                    size: 20,
                    color: AppColors.textSec,
                  ),
                ),
              )
            else
              const Icon(
                Icons.account_balance,
                size: 20,
                color: AppColors.textSec,
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                bank.name,
                style: AppText.bodySmall.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
