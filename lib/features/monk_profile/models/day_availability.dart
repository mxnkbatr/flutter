import 'package:sacred_app/core/utils/app_timezone.dart';

class DayAvailability {
  const DayAvailability({
    required this.date,
    required this.isAvailable,
    required this.isBooked,
    this.slotCount = 0,
  });

  final DateTime date;
  final bool isAvailable;
  final bool isBooked;
  final int slotCount;

  factory DayAvailability.fromJson(Map<String, dynamic> json) {
    final slots = json['slots'] as List?;
    final hasSlots = slots != null && slots.isNotEmpty;
    return DayAvailability(
      date: AppTimezone.parseDateOnly(json['date'] as String),
      isAvailable: json['isAvailable'] as bool? ?? hasSlots,
      isBooked: json['isBooked'] as bool? ?? false,
      slotCount: slots?.length ?? json['slotCount'] as int? ?? 0,
    );
  }
}
