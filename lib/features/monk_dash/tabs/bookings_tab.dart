import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/notifications/call_launch_service.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/app_timezone.dart';
import 'package:sacred_app/features/monk_dash/models/monk_booking_item.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_booking_card.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_call_hero_card.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_section_card.dart';
import 'package:sacred_app/features/video_call/providers/incoming_call_provider.dart';
import 'package:sacred_app/shared/widgets/monk_card_shimmer.dart';

class BookingsTab extends ConsumerWidget {
  const BookingsTab({super.key});

  List<MonkBookingItem> _sortBookings(List<MonkBookingItem> bookings) {
    int statusRank(String s) {
      const order = ['pending', 'approved', 'confirmed', 'completed', 'cancelled'];
      final i = order.indexOf(s);
      return i == -1 ? 99 : i;
    }

    int startMinutes(MonkBookingItem b) {
      if (b.date == null || b.date!.isEmpty || b.slot.isEmpty) return 1 << 30;
      final today = AppTimezone.todayDateStr();
      final ymd = b.date!.length >= 10 ? b.date!.substring(0, 10) : b.date!;
      // Today first.
      if (ymd != today) return 1 << 29;
      return AppTimezone.slotToMinutes(b.slot);
    }

    final sorted = [...bookings]
      ..sort((a, b) {
        final s = statusRank(a.status).compareTo(statusRank(b.status));
        if (s != 0) return s;
        return startMinutes(a).compareTo(startMinutes(b));
      });
    return sorted;
  }

  List<MonkBookingItem> _todayConfirmedPaid(List<MonkBookingItem> bookings) {
    final today = AppTimezone.todayDateStr();
    return bookings.where((b) {
      if (b.status != 'confirmed' || b.paid != true) return false;
      final d = b.date;
      if (d == null || d.isEmpty) return false;
      final ymd = d.length >= 10 ? d.substring(0, 10) : d;
      return ymd == today;
    }).toList();
  }

  bool _isUpcomingSoon(MonkBookingItem b, {int withinMinutes = 60}) {
    final d = b.date;
    if (d == null || d.isEmpty || b.slot.isEmpty) return false;
    final ymd = d.length >= 10 ? d.substring(0, 10) : d;
    if (ymd != AppTimezone.todayDateStr()) return false;
    final start = AppTimezone.slotToMinutes(b.slot);
    final nowMin = AppTimezone.currentTimeMinutes;
    final diff = start - nowMin;
    return diff > 0 && diff <= withinMinutes;
  }

  String _minutesUntil(MonkBookingItem b) {
    final start = AppTimezone.slotToMinutes(b.slot);
    final diff = start - AppTimezone.currentTimeMinutes;
    if (diff <= 0) return 'Одоо';
    if (diff < 60) return '$diff минутын дараа';
    final h = diff ~/ 60;
    final m = diff % 60;
    return m == 0 ? '$h цагийн дараа' : '$h ц $m мин дараа';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(monkBookingsProvider);
    final incoming = ref.watch(incomingCallProvider);

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

          final sorted = _sortBookings(bookings);
          final confirmedToday = _todayConfirmedPaid(sorted);
          final activeNow =
              confirmedToday.where((b) => AppTimezone.isInCallWindow(b.date, b.slot)).toList();
          final upcomingSoon =
              confirmedToday.where((b) => _isUpcomingSoon(b, withinMinutes: 60)).toList();
          final pending = sorted.where((b) => b.status == 'pending').toList();
          final other = sorted
              .where(
                (b) => b.status != 'pending' && !activeNow.contains(b) && !upcomingSoon.contains(b),
              )
              .toList();

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.only(
              top: 4,
              bottom: MediaQuery.of(context).padding.bottom + 100,
            ),
            children: [
              if (incoming != null)
                MonkCallHeroCard(
                  pulsing: true,
                  title: incoming.isScheduledStart
                      ? 'Дуудлага эхлэх цаг боллоо'
                      : 'Дуудлага ирж байна',
                  subtitle: incoming.callerName.isNotEmpty
                      ? incoming.callerName
                      : 'Хэрэглэгч',
                  icon: Icons.phone_in_talk_rounded,
                  accent: AppColors.success,
                  actions: [
                    OutlinedButton(
                      onPressed: () =>
                          CallLaunchService.declineCall(ref, incoming),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Татгалзах'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          CallLaunchService.acceptCall(ref, incoming),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Хариулах'),
                    ),
                  ],
                ),
              if (activeNow.isNotEmpty)
                MonkSectionCard(
                  icon: Icons.videocam_rounded,
                  title: 'Одоо болох дуудлага',
                  subtitle: '${activeNow.length} идэвхтэй',
                  accent: AppColors.success,
                  children: activeNow
                      .map((b) => _BookingCardWithActions(
                            booking: b,
                            highlight: true,
                          ))
                      .toList(),
                ),
              if (upcomingSoon.isNotEmpty)
                MonkSectionCard(
                  icon: Icons.schedule_rounded,
                  title: 'Удахгүй болох дуудлага',
                  subtitle: 'Дараагийн ${upcomingSoon.length} дуудлага',
                  accent: AppColors.orange,
                  children: upcomingSoon
                      .map(
                        (b) => _UpcomingCallRow(
                          booking: b,
                          eta: _minutesUntil(b),
                        ),
                      )
                      .toList(),
                ),
              if (pending.isNotEmpty)
                MonkSectionCard(
                  icon: Icons.pending_actions_rounded,
                  title: 'Хүлээгдэж буй захиалга',
                  subtitle: '${pending.length} шинэ хүсэлт',
                  accent: AppColors.warning,
                  children: pending
                      .map((b) => _BookingCardWithActions(booking: b))
                      .toList(),
                ),
              if (other.isNotEmpty)
                MonkSectionCard(
                  icon: Icons.history_rounded,
                  title: 'Бусад захиалга',
                  accent: AppColors.textSec,
                  children: other
                      .map((b) => _BookingCardWithActions(booking: b))
                      .toList(),
                ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

/// Compact row for upcoming calls — time left + join when window opens.
class _UpcomingCallRow extends StatelessWidget {
  const _UpcomingCallRow({required this.booking, required this.eta});

  final MonkBookingItem booking;
  final String eta;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.creamBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSub),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                booking.slot,
                style: AppText.h3.copyWith(fontSize: 18),
              ),
              Text(eta, style: AppText.caption.copyWith(color: AppColors.orange)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.clientName,
                  style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(booking.serviceName, style: AppText.bodySmall),
              ],
            ),
          ),
          Icon(Icons.notifications_active_outlined,
              size: 20, color: AppColors.orange.withOpacity(0.7)),
        ],
      ),
    );
  }
}

class _BookingCardWithActions extends ConsumerStatefulWidget {
  const _BookingCardWithActions({
    required this.booking,
    this.highlight = false,
  });
  final MonkBookingItem booking;
  final bool highlight;

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
        if (widget.highlight)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text(
                    'Дуудлагын цаг идэвхтэй',
                    style: AppText.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        MonkBookingCard(booking: booking),
        if (isPending)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
            padding: const EdgeInsets.only(bottom: 8),
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
