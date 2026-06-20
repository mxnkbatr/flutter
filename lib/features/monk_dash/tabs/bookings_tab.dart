import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/models/monk_booking_item.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_booking_card.dart';
import 'package:sacred_app/shared/widgets/monk_card_shimmer.dart';

class BookingsTab extends ConsumerWidget {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(monkBookingsProvider);

    return RefreshIndicator(
      color: AppColors.goldPrime,
      onRefresh: () => ref.refresh(monkBookingsProvider.future),
      child: bookingsAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: List.generate(3, (_) => const MonkCardShimmer()),
        ),
        error: (e, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
                  const SizedBox(height: 8),
                  Text('Алдаа гарлаа', style: AppText.body),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(monkBookingsProvider),
                    child: const Text('Дахин оролдох'),
                  ),
                ],
              ),
            ),
          ],
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 48, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text('Захиалга байхгүй', style: AppText.h3),
                    ],
                  ),
                ),
              ],
            );
          }

          final sorted = [...bookings]..sort((a, b) {
              const order = ['pending', 'approved', 'confirmed', 'completed', 'cancelled'];
              return order.indexOf(a.status).compareTo(order.indexOf(b.status));
            });

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 100,
            ),
            itemCount: sorted.length,
            itemBuilder: (_, i) => _BookingCardWithActions(
              booking: sorted[i],
            ),
          );
        },
      ),
    );
  }
}

class _BookingCardWithActions extends ConsumerStatefulWidget {
  const _BookingCardWithActions({required this.booking});
  final MonkBookingItem booking;

  @override
  ConsumerState<_BookingCardWithActions> createState() =>
      _BookingCardWithActionsState();
}

class _BookingCardWithActionsState
    extends ConsumerState<_BookingCardWithActions> {
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      await confirmBooking(ref, widget.booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Захиалга хүлээн авлаа. Хэрэглэгч төлбөр төлнө.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatUserError(e)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Захиалга цуцлах уу?'),
        content: Text(
            '${widget.booking.clientName}-н захиалгыг цуцлах уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Үгүй'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Тийм'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _loading = true);
    try {
      await cancelBooking(ref, widget.booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Захиалга цуцлагдлаа'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatUserError(e)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _complete() async {
    setState(() => _loading = true);
    try {
      await completeBooking(ref, widget.booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Захиалга дууссан'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatUserError(e)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final isPending = booking.status == 'pending';
    final canComplete = booking.status == 'confirmed' && booking.paid;

    return Column(
      children: [
        MonkBookingCard(booking: booking),
        if (isPending)
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: _loading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.goldPrime,
                            ),
                          ),
                        )
                      : Row(children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _confirm,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Батлах',
                                    style: AppText.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: _cancel,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceEl,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.danger,
                                      width: 0.5),
                                ),
                                child: Center(
                                  child: Text(
                                    'Цуцлах',
                                    style: AppText.bodySmall.copyWith(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                ),
              ],
            ),
          ),
        if (canComplete)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: _loading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.goldPrime,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: _complete,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrime,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Дуусгах',
                          style: AppText.bodySmall.copyWith(
                            color: AppColors.inkDeep,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
}
