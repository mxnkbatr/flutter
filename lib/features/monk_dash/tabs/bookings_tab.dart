import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
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
                children: const [
                  SizedBox(height: 80),
                  Center(
                    child: Text('Захиалга байхгүй', style: AppText.bodySmall),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: bookings.length,
                itemBuilder: (context, index) =>
                    MonkBookingCard(booking: bookings[index]),
              ),
      ),
    );
  }
}
