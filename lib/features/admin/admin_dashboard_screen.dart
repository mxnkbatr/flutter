import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/features/admin/providers/admin_providers.dart';
import 'package:sacred_app/features/admin/utils/admin_format.dart';
import 'package:sacred_app/features/admin/widgets/admin_booking_row.dart';
import 'package:sacred_app/features/admin/widgets/admin_page_scaffold.dart';
import 'package:sacred_app/features/admin/widgets/kpi_card.dart';
import 'package:sacred_app/features/admin/widgets/pending_monk_card.dart';
import 'package:sacred_app/features/admin/widgets/revenue_chart.dart';
import 'package:sacred_app/shared/widgets/error_state.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardProvider);

    return AdminPageScaffold(
      title: 'Платформын самбар',
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.inkDeep),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Мэдэгдлийн төв удахгүй нээгдэнэ'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        ),
        error: (e, _) => ErrorState(
          error: e,
          fallback: 'Самбарын мэдээлэл ачаалахад алдаа гарлаа.',
          onRetry: () => ref.invalidate(adminDashboardProvider),
        ),
        data: (stats) => RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () => ref.refresh(adminDashboardProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    KpiCard(
                      icon: Icons.monetization_on_outlined,
                      label: 'Нийт орлого',
                      value: '₮${fmtAdmin(stats.totalRevenue)}',
                      sub: 'Энэ сар',
                      dark: true,
                    ),
                    KpiCard(
                      icon: Icons.calendar_month_outlined,
                      label: 'Нийт захиалга',
                      value: '${stats.totalBookings}',
                      sub: '+${stats.bookingsGrowth.toStringAsFixed(1)}% сараас',
                    ),
                    KpiCard(
                      icon: Icons.self_improvement_outlined,
                      label: 'Идэвхтэй лам',
                      value: '${stats.activeMonks}',
                      sub: '${stats.pendingMonks} хүлээгдэж буй',
                    ),
                    KpiCard(
                      icon: Icons.people_outline,
                      label: 'Нийт хэрэглэгч',
                      value: '${stats.totalUsers}',
                      sub: '+${stats.newUsersThisWeek} энэ долоо хоног',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AdminSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Сарын орлого', style: AppText.h3),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: RevenueChart(monthlyData: stats.monthlyRevenue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (stats.pendingMonks > 0)
                  AdminSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Батлах хүлээж буй ламнар',
                              style: AppText.h3.copyWith(color: AppColors.warning),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...stats.pendingMonksList.map(
                          (m) => PendingMonkCard(monk: m),
                        ),
                      ],
                    ),
                  ),
                if (stats.pendingMonks > 0) const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Сүүлийн захиалгууд', style: AppText.h3),
                    TextButton(
                      onPressed: () => context.go('/admin/bookings'),
                      child: Text(
                        'Бүгд харах',
                        style: AppText.bodySmall.copyWith(
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...stats.recentBookings.map(
                  (b) => AdminBookingRow(booking: b),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
