import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/app_timezone.dart';
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

  String _dateLabel(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final ymd = date.length >= 10 ? date.substring(0, 10) : date;
      final dt = AppTimezone.parseDateOnly(ymd);
      return DateFormat('M сарын d').format(dt);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canJoinCall =
        booking.status == 'confirmed' && booking.paid == true;
    final inWindow = canJoinCall &&
        AppTimezone.isInCallWindow(booking.date, booking.slot);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SacredCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(booking.slot, style: AppText.h3),
                if (_dateLabel(booking.date).isNotEmpty)
                  Text(
                    _dateLabel(booking.date),
                    style: AppText.caption.copyWith(color: AppColors.textSec),
                  ),
                const SizedBox(height: 4),
                Container(
                  width: 2,
                  height: 28,
                  color: _statusColor(booking.status),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.clientName.isNotEmpty
                        ? booking.clientName
                        : 'Хэрэглэгч',
                    style: AppText.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(booking.serviceName, style: AppText.bodySmall),
                  if (inWindow)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '● Одоо видео дуудлагад орох боломжтой',
                        style: AppText.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(status: booking.status),
                if (canJoinCall) ...[
                  const SizedBox(height: 8),
                  SmallBtn(
                    label: inWindow ? 'Орох' : 'Дуудлага',
                    color: inWindow ? AppColors.success : AppColors.goldPrime,
                    textColor: inWindow ? Colors.white : AppColors.inkDeep,
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
