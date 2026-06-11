import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/features/monk_profile/models/monk_service.dart';

class BookingDraft {
  const BookingDraft({
    required this.monkId,
    this.service,
    this.date,
    this.slot,
  });

  final String monkId;
  final MonkService? service;
  final DateTime? date;
  final String? slot;

  int get servicePrice => service?.price ?? 0;

  int discountedServicePrice(int discountPercent) {
    if (discountPercent <= 0) return servicePrice;
    return (servicePrice * (100 - discountPercent) / 100).round();
  }

  int platformFeeFor(int discountPercent) =>
      (discountedServicePrice(discountPercent) * 0.1).round();

  int totalAmountFor(int discountPercent) =>
      discountedServicePrice(discountPercent) + platformFeeFor(discountPercent);

  int get platformFee => platformFeeFor(0);
  int get totalAmount => totalAmountFor(0);

  bool get canProceedStep1 => service != null;
  bool get canProceedStep2 => date != null && slot != null;
  bool get isComplete => canProceedStep1 && canProceedStep2;

  BookingDraft copyWith({
    String? monkId,
    MonkService? service,
    DateTime? date,
    String? slot,
    bool clearService = false,
    bool clearDate = false,
    bool clearSlot = false,
  }) {
    return BookingDraft(
      monkId: monkId ?? this.monkId,
      service: clearService ? null : (service ?? this.service),
      date: clearDate ? null : (date ?? this.date),
      slot: clearSlot ? null : (slot ?? this.slot),
    );
  }
}

class BookingDraftNotifier extends Notifier<BookingDraft> {
  @override
  BookingDraft build() => const BookingDraft(monkId: '');

  void init(
    String monkId, {
    MonkService? service,
    DateTime? date,
  }) {
    state = BookingDraft(monkId: monkId, service: service, date: date);
  }

  void reset(String monkId) {
    state = BookingDraft(monkId: monkId);
  }

  void setService(MonkService service) =>
      state = state.copyWith(service: service);

  void setDate(DateTime date) =>
      state = state.copyWith(date: date, clearSlot: true);

  void setSlot(String slot) => state = state.copyWith(slot: slot);

  Future<String> createBooking({
    int? amount,
    int discountPercent = 0,
  }) async {
    if (!state.isComplete) {
      throw StateError('Booking draft is incomplete');
    }
    final total = amount ?? state.totalAmountFor(discountPercent);
    final res = await ref.read(apiClientProvider).post(
      '/bookings',
      data: {
        'monkId': state.monkId,
        'serviceId': state.service!.id,
        'date': DateTime(
          state.date!.year,
          state.date!.month,
          state.date!.day,
        ).toIso8601String(),
        'slot': state.slot,
        'amount': total,
        if (discountPercent > 0) 'discountPercent': discountPercent,
      },
    );
    final data = res.data as Map<String, dynamic>;
    return data['bookingId'] as String? ??
        data['id'] as String? ??
        data['_id'] as String;
  }
}

final bookingDraftProvider =
    NotifierProvider<BookingDraftNotifier, BookingDraft>(
  BookingDraftNotifier.new,
);

final bookingStepProvider = StateProvider<int>((ref) => 0);

final bookingSubmittingProvider = StateProvider<bool>((ref) => false);
