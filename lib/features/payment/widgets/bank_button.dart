import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/api/api_config.dart';
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

  /// qpay.mn logos have no CORS — use our API proxy on all platforms.
  static String? proxiedLogo(String? logo) {
    if (logo == null || logo.isEmpty) return null;
    if (logo.contains('/qpay/logo')) return logo;
    return '${ApiConfig.baseUrl}/qpay/logo?u=${Uri.encodeQueryComponent(logo)}';
  }

  @override
  Widget build(BuildContext context) {
    final logoUrl = proxiedLogo(bank.logo);

    return Material(
      color: AppColors.surfaceEl,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSub),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: logoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: logoUrl,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 120),
                        placeholder: (_, __) => const ColoredBox(
                          color: AppColors.orangeSoft,
                          child: SizedBox(width: 32, height: 32),
                        ),
                        errorWidget: (_, __, ___) => const ColoredBox(
                          color: AppColors.orangeSoft,
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Icon(
                              Icons.account_balance_rounded,
                              size: 18,
                              color: AppColors.orangeDeep,
                            ),
                          ),
                        ),
                      )
                    : const ColoredBox(
                        color: AppColors.orangeSoft,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.account_balance_rounded,
                            size: 18,
                            color: AppColors.orangeDeep,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  bank.name,
                  style: AppText.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.15,
                    color: AppColors.inkDeep,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
