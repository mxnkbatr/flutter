import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/utils/app_feedback.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/providers/admin_providers.dart';
import 'package:sacred_app/features/admin/utils/admin_format.dart';
import 'package:sacred_app/features/admin/utils/finance_excel_export.dart';
import 'package:sacred_app/features/admin/widgets/finance_row.dart';
import 'package:sacred_app/features/admin/widgets/admin_page_scaffold.dart';
import 'package:sacred_app/features/monk_dash/widgets/month_picker.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';

class AdminFinanceScreen extends ConsumerWidget {
  const AdminFinanceScreen({super.key});

  Future<void> _exportExcel(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final finance = ref.read(adminFinanceProvider).valueOrNull;
    if (finance == null) {
      showAppSnackBar(
        context,
        const SnackBar(content: Text('Тайлан ачаалагдаагүй байна')),
      );
      return;
    }
    try {
      final path = await exportFinanceExcel(finance);
      if (context.mounted && path != null) {
        showAppSnackBar(
          context,
          SnackBar(content: Text('Хадгалагдлаа: $path')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          SnackBar(content: Text(formatUserError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedAdminFinanceMonthProvider);
    final financeAsync = ref.watch(adminFinanceProvider);

    return AdminPageScaffold(
      title: 'Санхүүгийн тайлан',
      actions: [
        IconButton(
          icon: const Icon(Icons.download_outlined, color: AppColors.orange),
          onPressed: () => _exportExcel(context, ref),
        ),
      ],
      body: financeAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrime),
        ),
        error: (e, _) => Center(child: Text(formatUserError(e))),
        data: (finance) => RefreshIndicator(
          color: AppColors.goldPrime,
          onRefresh: () => ref.refresh(adminFinanceProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MonthPicker(
                  selectedMonth: month,
                  onChanged: (m) => ref
                      .read(selectedAdminFinanceMonthProvider.notifier)
                      .state = m,
                ),
                const SizedBox(height: 20),
                SacredCard(
                  inkDeep: true,
                  child: Column(
                    children: [
                      FinanceRow(
                        label: 'Нийт захиалгын орлого',
                        value: finance.totalRevenue,
                        color: AppColors.goldPrime,
                      ),
                      FinanceRow(
                        label: 'Платформын хураамж (20%)',
                        value: finance.platformFees,
                      ),
                      FinanceRow(
                        label: 'QPay шимтгэл',
                        value: -finance.qpayFees,
                        color: AppColors.danger,
                      ),
                      const Divider(color: AppColors.inkLight),
                      FinanceRow(
                        label: 'Цэвэр ашиг',
                        value: finance.netProfit,
                        color: AppColors.goldPrime,
                        bold: true,
                      ),
                    ],
                  ),
                ),
                if (finance.monkSalaries.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text('Ламуудын цалин тооцоо', style: AppText.h3),
                  const SizedBox(height: 12),
                  ...finance.monkSalaries.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SacredCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.goldLight,
                              backgroundImage: s.monkImage.isNotEmpty
                                  ? CachedNetworkImageProvider(s.monkImage)
                                  : null,
                              child: s.monkImage.isEmpty
                                  ? Text(
                                      s.monkName.isNotEmpty ? s.monkName[0] : '?',
                                      style: AppText.body.copyWith(
                                        color: AppColors.saffronDeep,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.monkName,
                                    style: AppText.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${s.bookingCount} захиалга',
                                    style: AppText.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₮${fmtAdmin(s.netEarnings)}',
                                  style: AppText.price.copyWith(
                                    color: AppColors.saffronDeep,
                                    fontSize: 15,
                                  ),
                                ),
                                const Text('цэвэр орлого', style: AppText.caption),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
