import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/booking/models/client_booking.dart';
import 'package:sacred_app/features/booking/providers/my_bookings_provider.dart';
import 'package:sacred_app/features/monk_dash/widgets/status_badge.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';
import 'package:sacred_app/shared/widgets/ios_grouped_section.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  String _formatBookingsError(Object error) {
    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        return 'Нэвтрэлт хүчинтэй биш байна.\nДахин нэвтэрнэ үү.';
      }
      return 'Захиалга ачаалахад алдаа гарлаа.';
    }
    return 'Алдаа гарлаа';
  }

  String _fmt(int? n) {
    if (n == null) return '';
    return n.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return IosLargeTitleScaffold(
      title: 'Захиалга',
      body: bookingsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              _formatBookingsError(e),
              style: AppText.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 48, color: AppColors.textSec.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text('Захиалга байхгүй', style: AppText.bodySmall),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: IosGroupedSection(
              children: bookings.map((b) => _BookingTile(
                booking: b,
                onCall: () {
                  if (!TierGating.checkVideoCall(context, ref)) return;
                  context.go('/call/${b.id}');
                },
                onPay: () => context.go('/payment/${b.id}'),
                fmt: _fmt,
              )).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({
    required this.booking,
    required this.onCall,
    required this.onPay,
    required this.fmt,
  });

  final ClientBooking booking;
  final VoidCallback onCall;
  final VoidCallback onPay;
  final String Function(int?) fmt;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(booking.monkName, style: AppText.h3.copyWith(fontSize: 16)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text('${booking.serviceName} · ${booking.slot}',
              style: AppText.bodySmall),
          if (booking.date != null)
            Text(booking.date!, style: AppText.caption),
          const SizedBox(height: 6),
          Row(
            children: [
              StatusBadge(status: booking.status),
              if (booking.amount != null) ...[
                const SizedBox(width: 8),
                Text('₮${fmt(booking.amount)}', style: AppText.caption),
              ],
            ],
          ),
        ],
      ),
      trailing: booking.canJoinCall
          ? IconButton(
              icon: const Icon(Icons.videocam_rounded, color: AppColors.accent),
              onPressed: onCall,
            )
          : booking.status == 'pending' && !booking.paid
              ? TextButton(onPressed: onPay, child: const Text('Төлөх'))
              : null,
    );
  }
}
