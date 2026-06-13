import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_booking_card.dart';

class BookingsTab extends ConsumerWidget {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(monkBookingsListProvider);

    return bookingsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.goldPrime),
      ),
      error: (e, _) => Center(child: Text('Алдаа: $e', style: AppText.bodySmall)),
      data: (bookings) => RefreshIndicator(
        color: AppColors.goldPrime,
        onRefresh: () => ref.refresh(monkBookingsListProvider.future),
        child: bookings.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.sunLight,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            size: 40,
                            color: AppColors.saffronDeep,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Захиалга байхгүй',
                          style: AppText.h3.copyWith(
                            fontSize: 18,
                            color: AppColors.inkDeep,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Хэрэглэгчийн хүсэлт ирмэгц\nэнд харагдана',
                          style: AppText.bodySmall.copyWith(
                            color: AppColors.textSec,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: AppGradients.cardShadow(radius: 16),
                    child: MonkBookingCard(booking: booking),
                  );
                },
              ),
      ),
    );
  }
}
