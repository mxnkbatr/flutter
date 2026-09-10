import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/notifications/call_launch_service.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/app_timezone.dart';
import 'package:sacred_app/features/monk_dash/models/monk_booking_item.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';
import 'package:sacred_app/features/monk_dash/utils/monk_booking_filters.dart';
import 'package:sacred_app/features/monk_dash/widgets/availability_toggle.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_booking_card.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_call_hero_card.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_dash_header.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_section_card.dart';
import 'package:sacred_app/features/video_call/providers/incoming_call_provider.dart';
import 'package:sacred_app/shared/widgets/monk_card_shimmer.dart';

/// Ламын баталгаажсан видео дуудлагууд — нэвтрэхэд шууд энэ хуудас нээгдэнэ.
class MonkCallsScreen extends ConsumerWidget {
  const MonkCallsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(monkBookingsProvider);
    final incoming = ref.watch(incomingCallProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 88;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: MonkDashHeader(
              trailing: const AvailabilityToggle(compact: true),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Ажил',
              style: AppText.h2.copyWith(
                color: AppColors.inkDeep,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Consumer(
              builder: (context, ref, _) {
                final isSpecial = ref
                        .watch(monkDashboardProvider)
                        .valueOrNull
                        ?.isSpecial ??
                    false;
                final links = <Widget>[
                  Expanded(
                    child: _QuickLink(
                      icon: Icons.calendar_month_outlined,
                      label: 'Хуваарь',
                      onTap: () => context.go('/monk/dashboard?tab=1'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickLink(
                      icon: Icons.list_alt_rounded,
                      label: 'Захиалга',
                      onTap: () => context.go('/monk/dashboard?tab=2'),
                    ),
                  ),
                ];
                if (!isSpecial) {
                  links.addAll([
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickLink(
                        icon: Icons.payments_outlined,
                        label: 'Орлого',
                        onTap: () => context.go('/monk/dashboard?tab=3'),
                      ),
                    ),
                  ]);
                }
                return Row(children: links);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Өнөөдрийн дуудлага',
              style: AppText.h3.copyWith(color: AppColors.inkDeep),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              '30 минутын цагийн интервал',
              style: AppText.caption.copyWith(color: AppColors.textSec),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.danger, size: 40),
                          const SizedBox(height: 8),
                          Text('Алдаа гарлаа', style: AppText.body),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                ref.invalidate(monkBookingsProvider),
                            child: const Text('Дахин оролдох'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                data: (bookings) {
                  final sorted = MonkBookingFilters.sortBookings(bookings);
                  // Бүх confirmed+paid — шүүлтүүргүй (онцгой/энгийн ижил код).
                  final confirmed =
                      MonkBookingFilters.allConfirmedPaid(sorted);
                  final joinable = confirmed
                      .where(MonkBookingFilters.canJoinTodayCall)
                      .toList();
                  final otherConfirmed = confirmed
                      .where((b) => !MonkBookingFilters.canJoinTodayCall(b))
                      .toList();
                  final approved =
                      MonkBookingFilters.approvedAwaitingPayment(sorted);

                  final hasCalls = incoming != null ||
                      confirmed.isNotEmpty ||
                      approved.isNotEmpty;

                  if (!hasCalls) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: bottomPad),
                      children: [
                        const SizedBox(height: 72),
                        Icon(Icons.videocam_off_outlined,
                            size: 52, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Одоогоор баталгаажсан дуудлага байхгүй',
                            style: AppText.h3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            'Шинэ захиалга ирвэл энд харагдана',
                            style: AppText.bodySmall,
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.only(bottom: bottomPad),
                    children: [
                      if (incoming != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: MonkCallHeroCard(
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
                                onPressed: () => CallLaunchService.declineCall(
                                    ref, incoming),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                  side: const BorderSide(
                                      color: AppColors.danger),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Татгалзах'),
                              ),
                              ElevatedButton(
                                onPressed: () => CallLaunchService.acceptCall(
                                    ref, incoming),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Хариулах'),
                              ),
                            ],
                          ),
                        ),
                      if (joinable.isNotEmpty)
                        MonkSectionCard(
                          icon: Icons.videocam_rounded,
                          title: 'Одоо орох боломжтой',
                          subtitle: '${joinable.length} дуудлага',
                          accent: AppColors.success,
                          children: joinable
                              .map((b) => _ActiveCallCard(booking: b))
                              .toList(),
                        ),
                      if (otherConfirmed.isNotEmpty)
                        MonkSectionCard(
                          icon: Icons.event_available_rounded,
                          title: 'Баталгаажсан дуудлага',
                          subtitle: 'Бүх confirmed · ${otherConfirmed.length}',
                          accent: AppColors.orange,
                          children: otherConfirmed
                              .map(
                                (b) => _UpcomingCallRow(
                                  booking: b,
                                  dateLabel:
                                      MonkBookingFilters.formatBookingDate(
                                          b.date),
                                  eta: MonkBookingFilters.minutesUntil(b),
                                ),
                              )
                              .toList(),
                        ),
                      if (approved.isNotEmpty)
                        MonkSectionCard(
                          icon: Icons.verified_rounded,
                          title: 'Төлбөр хүлээгдэж буй',
                          subtitle:
                              '${approved.length} захиалга — төлөгдсөн бол автоматаар баталгаажна',
                          accent: AppColors.warning,
                          children: approved
                              .map((b) => MonkBookingCard(booking: b))
                              .toList(),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveCallCard extends StatelessWidget {
  const _ActiveCallCard({required this.booking});

  final MonkBookingItem booking;

  @override
  Widget build(BuildContext context) {
    final clientName = booking.clientName.isNotEmpty
        ? booking.clientName
        : 'Хэрэглэгч';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonkBookingCard(booking: booking),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$clientName · ${booking.slot}',
                  style: AppText.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    context.go('/call/${booking.id}?role=monk'),
                icon: const Icon(Icons.videocam_rounded, size: 18),
                label: const Text('Орох'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingCallRow extends StatelessWidget {
  const _UpcomingCallRow({
    required this.booking,
    required this.eta,
    required this.dateLabel,
  });

  final MonkBookingItem booking;
  final String eta;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final canJoin = MonkBookingFilters.canJoinTodayCall(booking);
    final clientName = booking.clientName.isNotEmpty
        ? booking.clientName
        : 'Хэрэглэгч';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: canJoin
              ? AppColors.success.withOpacity(0.45)
              : AppColors.borderSub,
          width: canJoin ? 1.2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  booking.slot,
                  style: AppText.h3.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: AppText.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.orangeDeep,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientName,
                  style: AppText.body.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  booking.serviceName,
                  style: AppText.bodySmall.copyWith(color: AppColors.textSec),
                ),
                const SizedBox(height: 4),
                Text(
                  eta,
                  style: AppText.caption.copyWith(
                    color: AppColors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (canJoin)
            TextButton.icon(
              onPressed: () =>
                  context.go('/call/${booking.id}?role=monk'),
              icon: const Icon(Icons.videocam_rounded, size: 18),
              label: const Text('Орох'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.success,
              ),
            )
          else
            Icon(
              Icons.notifications_active_outlined,
              size: 20,
              color: AppColors.orange.withOpacity(0.7),
            ),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceEl,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, size: 20, color: AppColors.orange),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppText.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkDeep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
