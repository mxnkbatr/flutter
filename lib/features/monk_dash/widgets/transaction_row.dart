import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/models/monk_earnings_data.dart';
import 'package:sacred_app/features/monk_dash/utils/monk_dash_format.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';

class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.transaction});

  final EarningTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SacredCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.clientName, style: AppText.body),
                  Text(transaction.serviceName, style: AppText.bodySmall),
                  Text(transaction.date, style: AppText.caption),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₮${fmtCurrency(transaction.monkEarns)}',
                  style: AppText.price.copyWith(fontSize: 14),
                ),
                Text(
                  '₮${fmtCurrency(transaction.amount)}',
                  style: AppText.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
