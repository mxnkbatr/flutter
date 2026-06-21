import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/booking/models/client_booking.dart';
import 'package:sacred_app/features/booking/providers/my_bookings_provider.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/features/booking/widgets/bookings_page_scaffold.dart';
import 'package:sacred_app/features/booking/widgets/review_sheet.dart';
import 'package:sacred_app/features/monk_dash/widgets/status_badge.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';
import 'package:sacred_app/shared/widgets/error_state.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  Widget _emptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        size: 32,
                        color: AppColors.goldPrime,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Захиалга байхгүй', style: AppText.h3),
                    const SizedBox(height: 8),
                    Text(
                      'Лам нараас цаг захиалж\nоюун санааны замаа эхлүүлээрэй',
                      style: AppText.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: AppGradients.sun,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Лам хайх',
                          style: AppText.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
          child: CircularProgressIndicator(color: AppColors.earthBrown),
        ),
        error: (e, _) => ErrorState(
          error: e,
          fallback: 'Захиалга ачаалахад алдаа гарлаа.',
          onRetry: () => ref.invalidate(myBookingsProvider),
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

class _BookingCard extends ConsumerWidget {
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

  String? get _statusHint {
    if (booking.status == 'pending' && !booking.paid) {
      return 'Төлбөр төлж захиалгаа илгээнэ үү';
    }
    if (booking.status == 'pending' && booking.paid) {
      return 'Төлбөр төлсөн — лам баталгаажуулах хүлээнэ үү';
    }
    if (booking.status == 'approved' && !booking.paid) {
      if (booking.bankTransferPending) {
        return 'Банкны шилжүүлэг баталгаажихыг хүлээж байна';
      }
      return 'Төлбөр төлж захиалгаа баталгаажуулна уу';
    }
    if (booking.canJoinCall) {
      return 'Захиалга баталгаажсан — видео дуудлага эхлүүлж болно';
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsPay = !booking.paid &&
        (booking.status == 'pending' || booking.status == 'approved');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MinimalStyle.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: MinimalStyle.avatarBox(radius: 22),
                alignment: Alignment.center,
                child: Text(
                  booking.monkName.isNotEmpty
                      ? booking.monkName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: AppColors.earthBrown.withOpacity(0.75),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${booking.serviceName} · ${booking.slot}',
                      style: AppText.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
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
          if (_statusHint != null) ...[
            const SizedBox(height: 8),
            Text(
              _statusHint!,
              style: AppText.caption.copyWith(color: AppColors.textSec),
            ),
          ],
          if (needsPay && !booking.bankTransferPending) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: onPay,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.payment_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Төлбөр төлөх',
                        style: AppText.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else if (booking.canJoinCall) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCall,
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Оруулах'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.earthBrown,
                  side: const BorderSide(
                    color: AppColors.earthBrown,
                    width: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
          if (booking.status == 'completed' && !booking.reviewed) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: booking.monkId.isEmpty
                    ? null
                    : () async {
                        final result = await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.surface,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (_) => ReviewSheet(
                            monkId: booking.monkId,
                            bookingId: booking.id,
                            monkName: booking.monkName,
                          ),
                        );
                        if (result == true) {
                          ref.invalidate(myBookingsProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Сэтгэгдэл илгээгдлээ. Баярлалаа!',
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        }
                      },
                icon: const Icon(Icons.star_outline_rounded, size: 18),
                label: const Text('Сэтгэгдэл бичих'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.earthBrown,
                  side: const BorderSide(
                    color: AppColors.earthBrown,
                    width: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ] else if (booking.status == 'completed' && booking.reviewed) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'Сэтгэгдэл илгээсэн',
                  style: AppText.caption.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
