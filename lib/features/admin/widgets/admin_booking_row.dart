import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/models/admin_booking_item.dart';
import 'package:sacred_app/features/admin/utils/admin_format.dart';
import 'package:sacred_app/features/monk_dash/widgets/status_badge.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';

class AdminBookingRow extends StatelessWidget {
  const AdminBookingRow({super.key, required this.booking});

  final AdminBookingItem booking;

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
                  Text(booking.clientName, style: AppText.body),
                  Text(
                    '${booking.monkName} · ${booking.serviceName}',
                    style: AppText.bodySmall,
                  ),
                  if (booking.date != null)
                    Text(
                      '${booking.date} ${booking.slot ?? ''}',
                      style: AppText.caption,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₮${fmtAdmin(booking.amount)}',
                  style: AppText.price.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                StatusBadge(status: booking.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
