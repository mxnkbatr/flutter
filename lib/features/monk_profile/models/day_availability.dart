class DayAvailability {
  const DayAvailability({
    required this.date,
    required this.isAvailable,
    required this.isBooked,
  });

  final DateTime date;
  final bool isAvailable;
  final bool isBooked;

  factory DayAvailability.fromJson(Map<String, dynamic> json) {
    return DayAvailability(
      date: DateTime.parse(json['date'] as String),
      isAvailable: json['isAvailable'] as bool? ?? false,
      isBooked: json['isBooked'] as bool? ?? false,
    );
  }
}
