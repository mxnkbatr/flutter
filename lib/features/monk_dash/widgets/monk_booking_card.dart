import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/models/monk_booking_item.dart';
import 'package:sacred_app/features/monk_dash/widgets/small_btn.dart';
import 'package:sacred_app/features/monk_dash/widgets/status_badge.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';

class MonkBookingCard extends ConsumerWidget {
  const MonkBookingCard({super.key, required this.booking});

  final MonkBookingItem booking;

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.success;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SacredCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(booking.slot, style: AppText.h3),
                Container(
                  width: 2,
                  height: 32,
                  color: _statusColor(booking.status),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.clientName, style: AppText.body),
                  Text(booking.serviceName, style: AppText.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(status: booking.status),
                if (booking.status == 'pending') ...[
                  const SizedBox(height: 8),
                  Text(
                    'Админ баталгаажуулах хүлээгдэж буй',
                    style: AppText.caption.copyWith(color: AppColors.textSec),
                  ),
                ],
                if (booking.status == 'approved' && !booking.paid) ...[
                  const SizedBox(height: 8),
                  SmallBtn(
                    label: 'Төлбөр харах',
                    color: AppColors.saffronDeep,
                    textColor: Colors.white,
                    onTap: () => context.push('/payment/${booking.id}'),
                  ),
                ],
                if (booking.status == 'confirmed' && booking.paid) ...[
                  const SizedBox(height: 8),
                  SmallBtn(
                    label: 'Дуудлага эхлэх',
                    color: AppColors.goldPrime,
                    textColor: AppColors.inkDeep,
                    onTap: () =>
                        context.go('/call/${booking.id}?role=monk'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
