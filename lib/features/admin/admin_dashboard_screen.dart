import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/models/admin_dashboard_data.dart';
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
          onPressed: () => context.go('/notifications'),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _QpayBanner(configured: stats.qpayConfigured),
                const SizedBox(height: 12),
                _TodaySection(stats: stats),
                const SizedBox(height: 16),
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
                      label: 'Энэ сарын орлого',
                      value: '₮${fmtAdmin(stats.monthRevenue > 0 ? stats.monthRevenue : stats.totalRevenue)}',
                      sub: 'Нийт: ₮${fmtAdmin(stats.totalRevenue)}',
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

class _QpayBanner extends StatelessWidget {
  const _QpayBanner({required this.configured});

  final bool configured;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: configured
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: configured
              ? AppColors.success.withOpacity(0.35)
              : AppColors.warning.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            configured ? Icons.payments_outlined : Icons.warning_amber_rounded,
            color: configured ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              configured
                  ? 'QPay: идэвхтэй (бодит төлбөр)'
                  : 'QPay: идэвхгүй — dev горим (15 сек дараа автоматаар төлөгдөнө)',
              style: AppText.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySection extends StatelessWidget {
  const _TodaySection({required this.stats});

  final AdminDashboardData stats;

  @override
  Widget build(BuildContext context) {
    return AdminSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Өнөөдөр', style: AppText.h3),
          const SizedBox(height: 4),
          Text(
            'Орлого, үзэлт, хуваарилалт (${stats.monkSharePercent}/${stats.platformSharePercent})',
            style: AppText.caption.copyWith(color: AppColors.textSec),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniStat(
                label: 'Орлого',
                value: '₮${fmtAdmin(stats.todayRevenue)}',
                highlight: true,
              ),
              _MiniStat(
                label: 'Захиалга',
                value: '${stats.todayBookingsCount}',
              ),
              _MiniStat(
                label: 'Үзсэн хүн',
                value: '${stats.todayUniqueViewers}',
              ),
              _MiniStat(
                label: 'Профайл үзэлт',
                value: '${stats.todayProfileViews}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SplitRow(
            label: 'Үзмэрчдийн цалин (${stats.monkSharePercent}%)',
            value: '₮${fmtAdmin(stats.todayMonkPayout)}',
            color: AppColors.orangeDeep,
          ),
          _SplitRow(
            label: 'Платформ (${stats.platformSharePercent}%)',
            value: '₮${fmtAdmin(stats.todayPlatformShare)}',
          ),
          _SplitRow(
            label: 'QPay шимтгэл',
            value: '-₮${fmtAdmin(stats.todayQpayFees)}',
            color: AppColors.danger,
          ),
          _SplitRow(
            label: 'Платформын цэвэр',
            value: '₮${fmtAdmin(stats.todayPlatformNet)}',
            bold: true,
          ),
          if (stats.todayBookingsDetail.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Өнөөдрийн төлбөрүүд', style: AppText.body.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...stats.todayBookingsDetail.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${b.monkName.isNotEmpty ? b.monkName : 'Лам'} · ${b.clientName.isNotEmpty ? b.clientName : 'Хэрэглэгч'}',
                            style: AppText.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${b.serviceName}${b.slot.isNotEmpty ? ' · ${b.slot}' : ''}',
                            style: AppText.caption.copyWith(color: AppColors.textSec),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₮${fmtAdmin(b.amount)}',
                          style: AppText.bodySmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'цалин ₮${fmtAdmin(b.monkEarns)}',
                          style: AppText.caption.copyWith(color: AppColors.orangeDeep),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (stats.todayViewsByMonk.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Хэн хэдэн удаа үзэгдсэн', style: AppText.body.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...stats.todayViewsByMonk.map(
              (v) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        v.monkName.isNotEmpty ? v.monkName : 'Лам',
                        style: AppText.bodySmall,
                      ),
                    ),
                    Text(
                      '${v.views} үзэлт',
                      style: AppText.caption.copyWith(
                        color: AppColors.orangeDeep,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight ? AppColors.orangeSoft : AppColors.creamBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSub),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption.copyWith(color: AppColors.textSec)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppText.body.copyWith(
              fontWeight: FontWeight.w800,
              color: highlight ? AppColors.orangeDeep : AppColors.inkDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.label,
    required this.value,
    this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppText.bodySmall.copyWith(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: AppText.bodySmall.copyWith(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: color ?? AppColors.inkDeep,
            ),
          ),
        ],
      ),
    );
  }
}
