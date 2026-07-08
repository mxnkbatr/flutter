import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/providers/admin_providers.dart';
import 'package:sacred_app/features/admin/widgets/admin_booking_row.dart';
import 'package:sacred_app/features/admin/widgets/admin_page_scaffold.dart';

class AdminBookingsScreen extends ConsumerStatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  ConsumerState<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends ConsumerState<AdminBookingsScreen> {
  static const _filters = [
    ('all', 'Бүгд'),
    ('pending', 'Хүлээгдэж буй'),
    ('approved', 'Төлбөр хүлээж'),
    ('confirmed', 'Батлагдсан'),
    ('completed', 'Дууссан'),
    ('cancelled', 'Цуцлагдсан'),
  ];

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(adminBookingFilterProvider);
    final bookingsAsync = ref.watch(adminBookingsProvider(filter));

    return AdminPageScaffold(
      title: 'Захиалгууд',
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final (value, label) = _filters[index];
                final selected = filter == value;
                return FilterChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(adminBookingFilterProvider.notifier)
                      .state = value,
                  selectedColor: AppColors.goldLight,
                );
              },
            ),
          ),
          Expanded(
            child: bookingsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.goldPrime),
              ),
              error: (e, _) => Center(child: Text(formatUserError(e))),
              data: (bookings) => RefreshIndicator(
                color: AppColors.goldPrime,
                onRefresh: () =>
                    ref.refresh(adminBookingsProvider(filter).future),
                child: bookings.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(
                            child: Text(
                              'Захиалга байхгүй',
                              style: AppText.bodySmall,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookings.length,
                        itemBuilder: (_, i) =>
                            AdminBookingRow(booking: bookings[i]),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
