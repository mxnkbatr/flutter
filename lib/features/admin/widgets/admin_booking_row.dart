import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/models/admin_booking_item.dart';
import 'package:sacred_app/features/admin/providers/admin_providers.dart';
import 'package:sacred_app/features/monk_dash/widgets/status_badge.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';

class AdminBookingRow extends StatelessWidget {
  const AdminBookingRow({super.key, required this.booking});
  final AdminBookingItem booking;

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  Color _lineColor(String status) => switch (status) {
        'confirmed' => AppColors.goldPrime,
        'completed' => AppColors.success,
        'cancelled' => AppColors.danger,
        'approved' => AppColors.saffronDeep,
        _ => AppColors.warning,
      };

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DetailSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SacredCard(
        onTap: () => _showDetail(context),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  booking.slot.isNotEmpty ? booking.slot : '--:--',
                  style: AppText.bodySmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 2,
                  height: 24,
                  color: _lineColor(booking.status),
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
                    style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (booking.monkName.isNotEmpty)
                    Text(
                      '→ ${booking.monkName}',
                      style: AppText.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(booking.date, style: AppText.caption),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₮${_fmt(booking.amount)}',
                  style: AppText.price.copyWith(fontSize: 13),
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

class _DetailSheet extends ConsumerStatefulWidget {
  const _DetailSheet({required this.booking});
  final AdminBookingItem booking;

  @override
  ConsumerState<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends ConsumerState<_DetailSheet> {
  bool _loading = false;

  AdminBookingItem get booking => widget.booking;

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Захиалгын дэлгэрэнгүй', style: AppText.h3),
                StatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 20),
            _Row('Хэрэглэгч', booking.clientName),
            _Row('Лам', booking.monkName),
            _Row('Үйлчилгээ', booking.serviceName),
            _Row('Огноо', booking.date),
            _Row('Цаг', booking.slot),
            const Divider(height: 24),
            _Row(
              'Нийт дүн',
              '₮${_fmt(booking.amount)}',
              accent: true,
            ),
            if (booking.status == 'pending') ...[
              const SizedBox(height: 20),
              SacredButton(
                label: 'Батлах',
                isLoading: _loading,
                onTap: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        await approveBooking(ref, booking.id);
                        if (mounted) Navigator.pop(context);
                      },
              ),
              const SizedBox(height: 10),
              SacredButton(
                label: 'Татгалзах',
                outline: true,
                onTap: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        await rejectBooking(ref, booking.id);
                        if (mounted) Navigator.pop(context);
                      },
              ),
            ],
            if (booking.status == 'approved' && !booking.paid) ...[
              const SizedBox(height: 20),
              SacredButton(
                label: 'Банкны төлбөр батлах',
                isLoading: _loading,
                onTap: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        await confirmBookingPayment(ref, booking.id);
                        if (mounted) Navigator.pop(context);
                      },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.accent = false});
  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.bodySmall),
          Flexible(
            child: Text(
              value.isNotEmpty ? value : '—',
              textAlign: TextAlign.end,
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w600,
                color: accent ? AppColors.saffronDeep : AppColors.textPri,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
