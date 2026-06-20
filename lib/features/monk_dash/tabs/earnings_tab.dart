import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/models/monk_earnings_data.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_earnings_provider.dart';
import 'package:sacred_app/features/monk_dash/utils/earnings_pdf_export.dart';
import 'package:sacred_app/features/monk_dash/utils/monk_dash_format.dart';
import 'package:sacred_app/features/monk_dash/widgets/earning_row.dart';
import 'package:sacred_app/features/monk_dash/widgets/earnings_bar_chart.dart';
import 'package:sacred_app/features/monk_dash/widgets/month_picker.dart';
import 'package:sacred_app/features/monk_dash/widgets/transaction_row.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';

List<String> _monthLabels(List<EarningTransaction> transactions) {
  if (transactions.isEmpty) {
    return const ['1', '2', '3', '4', '5', '6'];
  }
  return List.generate(
    transactions.length.clamp(1, 6),
    (i) => '${i + 1}-р',
  );
}

List<int> _monthValues(List<EarningTransaction> transactions) {
  if (transactions.isEmpty) {
    return const [0, 0, 0, 0, 0, 0];
  }
  return transactions.take(6).map((t) => t.monkEarns).toList();
}

class EarningsTab extends ConsumerWidget {
  const EarningsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedEarningsMonthProvider);
    final earningsAsync = ref.watch(monkEarningsProvider);

    return earningsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.goldPrime),
      ),
      error: (e, _) => Center(child: Text(formatUserError(e), style: AppText.bodySmall)),
      data: (earnings) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MonthPicker(
              selectedMonth: month,
              onChanged: (m) =>
                  ref.read(selectedEarningsMonthProvider.notifier).state = m,
            ),
            const SizedBox(height: 20),
            SacredCard(
              inkDeep: true,
              child: Column(
                children: [
                  Text(
                    'Нийт орлого',
                    style: AppText.bodySmall.copyWith(color: AppColors.goldMuted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₮${fmtCurrency(earnings.netEarnings)}',
                    style: AppText.h1.copyWith(
                      color: AppColors.goldPrime,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${earnings.completedCount} захиалга дууссан',
                    style: AppText.caption.copyWith(color: AppColors.goldMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            EarningsBarChart(
              labels: _monthLabels(earnings.transactions),
              values: _monthValues(earnings.transactions),
            ),
            const SizedBox(height: 16),
            SacredCard(
              child: Column(
                children: [
                  EarningRow(
                    label: 'Нийт захиалгын дүн',
                    value: earnings.grossAmount,
                  ),
                  EarningRow(
                    label: 'Платформын хураамж (20%)',
                    value: -earnings.platformFee,
                    color: AppColors.danger,
                  ),
                  EarningRow(
                    label: 'QPay шимтгэл (1.5%)',
                    value: -earnings.qpayFee,
                    color: AppColors.danger,
                  ),
                  const Divider(),
                  EarningRow(
                    label: 'Цэвэр орлого',
                    value: earnings.netEarnings,
                    bold: true,
                    color: AppColors.goldPrime,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Захиалгуудын дэлгэрэнгүй', style: AppText.h3),
            const SizedBox(height: 12),
            if (earnings.transactions.isEmpty)
              const Text('Гүйлгээ байхгүй', style: AppText.bodySmall)
            else
              ...earnings.transactions.map(
                (t) => TransactionRow(transaction: t),
              ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => exportEarningsPdf(earnings),
              icon: const Icon(Icons.download_outlined),
              label: const Text('PDF тайлан татах'),
            ),
          ],
        ),
      ),
    );
  }
}
