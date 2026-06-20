import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';
import 'package:sacred_app/features/monk_dash/utils/monk_dash_format.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_booking_card.dart';
import 'package:sacred_app/features/monk_dash/widgets/stat_card.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(monkDashboardProvider);

    return dataAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.goldPrime),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(formatUserError(e), style: AppText.bodySmall),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(monkDashboardProvider),
              child: const Text('Дахин оролдох'),
            ),
          ],
        ),
      ),
      data: (data) => RefreshIndicator(
        color: AppColors.goldPrime,
        onRefresh: () => ref.refresh(monkDashboardProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    label: 'Энэ сарын орлого',
                    value: '₮${fmtCurrency(data.monthlyEarnings)}',
                    sub:
                        '+${data.earningsChangePercent.toStringAsFixed(1)}%',
                    dark: true,
                  ),
                  StatCard(
                    label: 'Нийт захиалга',
                    value: '${data.totalBookings}',
                    sub: 'Энэ долоо хоног: ${data.weeklyBookings}',
                  ),
                  StatCard(
                    label: 'Дундаж үнэлгээ',
                    value: data.rating.toStringAsFixed(1),
                    sub: '★ ${data.reviewCount} санал',
                    accent: true,
                  ),
                  StatCard(
                    label: 'Хүлээгдэж буй',
                    value: '${data.pendingCount}',
                    sub: 'Баталгаажуулах',
                    danger: data.pendingCount > 0,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Өнөөдрийн захиалга', style: AppText.h3),
                  Text(
                    '${data.todayBookings.length} захиалга',
                    style: AppText.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (data.todayBookings.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Өнөөдөр захиалга байхгүй',
                    style: AppText.bodySmall,
                  ),
                )
              else
                ...data.todayBookings.map(
                  (b) => MonkBookingCard(booking: b),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
