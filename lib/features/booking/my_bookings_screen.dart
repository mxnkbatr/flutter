import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/booking/models/client_booking.dart';
import 'package:sacred_app/features/booking/providers/my_bookings_provider.dart';
import 'package:sacred_app/features/booking/widgets/bookings_page_scaffold.dart';
import 'package:sacred_app/features/monk_dash/widgets/status_badge.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

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

  Widget _emptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0EB),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.9),
                      ),
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      size: 40,
                      color: AppColors.saffronDeep,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Захиалга байхгүй',
                    style: AppText.h3.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkDeep,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Лам нараас цаг захиалж\nоюун санааны замаа эхлүүлээрэй',
                    style: AppText.bodySmall.copyWith(
                      color: const Color(0xFF666666),
                      fontSize: 14,
                      height: 20 / 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SacredButton(
                    label: 'Лам хайх',
                    small: true,
                    sunShadow: true,
                    onTap: () => context.go('/home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
    final bottomPad = MediaQuery.of(context).padding.bottom + 80;

    return BookingsPageScaffold(
      onRefresh: () async {
        ref.invalidate(myBookingsProvider);
        await ref.read(myBookingsProvider.future);
      },
      body: bookingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.saffron),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _formatBookingsError(e),
              style: AppText.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (bookings) {
          if (bookings.isEmpty) return _emptyState(context);

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPad),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _BookingCard(
              booking: bookings[i],
              onCall: () {
                if (!TierGating.checkVideoCall(context, ref)) return;
                context.go('/call/${bookings[i].id}');
              },
              onPay: () => context.go('/payment/${bookings[i].id}'),
              fmt: _fmt,
            ),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppGradients.cardShadow(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    booking.monkName.isNotEmpty
                        ? booking.monkName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.inkDeep,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.monkName,
                      style: AppText.h3.copyWith(fontSize: 16),
                    ),
                    Text(
                      '${booking.serviceName} · ${booking.slot}',
                      style: AppText.bodySmall,
                    ),
                  ],
                ),
              ),
              if (booking.canJoinCall)
                IconButton(
                  icon: const Icon(
                    Icons.videocam_rounded,
                    color: AppColors.saffron,
                  ),
                  onPressed: onCall,
                )
              else if (booking.status == 'pending' && !booking.paid)
                TextButton(onPressed: onPay, child: const Text('Төлөх')),
            ],
          ),
          if (booking.date != null) ...[
            const SizedBox(height: 8),
            Text(booking.date!, style: AppText.caption),
          ],
          const SizedBox(height: 10),
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
    );
  }
}
