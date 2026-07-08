import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/app_timezone.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/features/monk_dash/models/monk_booking_item.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';
import 'package:sacred_app/features/monk_dash/utils/monk_dash_format.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_booking_card.dart';
import 'package:sacred_app/features/monk_dash/widgets/stat_card.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  MonkBookingItem? _nextCall(List<MonkBookingItem> bookings) {
    final today = AppTimezone.todayDateStr();
    final candidates = bookings.where((b) {
      if (b.status != 'confirmed' || b.paid != true) return false;
      final d = b.date;
      if (d == null || d.isEmpty || b.slot.isEmpty) return false;
      final ymd = d.length >= 10 ? d.substring(0, 10) : d;
      if (ymd.compareTo(today) < 0) return false;
      if (ymd == today && AppTimezone.isPastSlot(ymd, b.slot)) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        final da = a.date!.substring(0, 10);
        final db = b.date!.substring(0, 10);
        final c = da.compareTo(db);
        if (c != 0) return c;
        return AppTimezone.slotToMinutes(a.slot)
            .compareTo(AppTimezone.slotToMinutes(b.slot));
      });
    return candidates.isEmpty ? null : candidates.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(monkDashboardProvider);
    final bookingsAsync = ref.watch(monkBookingsProvider);

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
      data: (data) {
        final nextCall = bookingsAsync.valueOrNull != null
            ? _nextCall(bookingsAsync.valueOrNull!)
            : null;
        final inWindow = nextCall != null &&
            AppTimezone.isInCallWindow(nextCall.date, nextCall.slot);

        return RefreshIndicator(
        color: AppColors.goldPrime,
        onRefresh: () async {
          await ref.refresh(monkDashboardProvider.future);
          await ref.refresh(monkBookingsProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (nextCall != null)
                GestureDetector(
                  onTap: () => context.go('/monk/calls'),
                  child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: inWindow
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.orangeLight,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: inWindow
                          ? AppColors.success.withOpacity(0.35)
                          : AppColors.orange.withOpacity(0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inWindow
                            ? 'Одоо видео дуудлага'
                            : 'Дараагийн видео дуудлага',
                        style: AppText.caption.copyWith(
                          color: inWindow
                              ? AppColors.success
                              : AppColors.orangeDeep,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${nextCall.slot} · ${nextCall.clientName.isNotEmpty ? nextCall.clientName : 'Хэрэглэгч'}',
                        style: AppText.h3.copyWith(fontSize: 18),
                      ),
                      Text(
                        nextCall.serviceName,
                        style: AppText.bodySmall.copyWith(
                          color: AppColors.textSec,
                        ),
                      ),
                      if (inWindow) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => context.go(
                              '/call/${nextCall.id}?role=monk',
                            ),
                            icon: const Icon(Icons.videocam_rounded),
                            label: const Text('Дуудлагад орох'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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
      );
      },
    );
  }
}
