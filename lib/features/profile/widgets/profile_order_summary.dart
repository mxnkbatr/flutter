import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/features/booking/providers/my_bookings_provider.dart';
import 'package:sacred_app/features/profile/utils/booking_summary.dart';

class ProfileOrderSummary extends ConsumerWidget {
  const ProfileOrderSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return bookingsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          height: 96,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.orange,
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (bookings) {
        final counts = BookingSummaryCounts.fromBookings(bookings);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'ЗАХИАЛГЫН ТӨЛӨВ',
                  style: AppText.caption.copyWith(
                    color: AppColors.textSec,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    fontSize: 11,
                  ),
                ),
              ),
              Container(
                decoration: MinimalStyle.card(),
                clipBehavior: Clip.antiAlias,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      _SummaryColumn(
                        icon: Icons.hourglass_top_rounded,
                        iconBg: const Color(0xFFFFF4E5),
                        iconColor: AppColors.orange,
                        title: 'Хүлээгдэж\nбуй',
                        count: counts.pending,
                        onTap: () => context.go('/bookings?filter=pending'),
                      ),
                      const VerticalDivider(
                        width: 0.5,
                        thickness: 0.5,
                        color: AppColors.borderSub,
                      ),
                      _SummaryColumn(
                        icon: Icons.videocam_rounded,
                        iconBg: const Color(0xFFE8F8EF),
                        iconColor: AppColors.success,
                        title: 'Идэвхтэй',
                        count: counts.active,
                        onTap: () => context.go('/bookings?filter=active'),
                      ),
                      const VerticalDivider(
                        width: 0.5,
                        thickness: 0.5,
                        color: AppColors.borderSub,
                      ),
                      _SummaryColumn(
                        icon: Icons.history_rounded,
                        iconBg: const Color(0xFFF0F0F0),
                        iconColor: AppColors.textSec,
                        title: 'Түүх',
                        count: counts.history,
                        onTap: () => context.go('/bookings?filter=history'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: AppText.caption.copyWith(
                    color: AppColors.textSec,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '$count',
                  style: AppText.h2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkDeep,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
