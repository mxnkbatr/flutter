class MonkScheduleDay {
  const MonkScheduleDay({
    required this.name,
    required this.active,
    required this.start,
    required this.end,
  });

  final String name;
  final bool active;
  final String start;
  final String end;

  MonkScheduleDay copyWith({
    String? name,
    bool? active,
    String? start,
    String? end,
  }) {
    return MonkScheduleDay(
      name: name ?? this.name,
      active: active ?? this.active,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  factory MonkScheduleDay.fromJson(Map<String, dynamic> json) {
    return MonkScheduleDay(
      name: json['name'] as String? ?? json['day'] as String? ?? '',
      active: json['active'] as bool? ?? json['isActive'] as bool? ?? false,
      start: json['start'] as String? ?? '09:00',
      end: json['end'] as String? ?? '18:00',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'active': active,
        'start': start,
        'end': end,
      };
}

class MonkWeeklySchedule {
  const MonkWeeklySchedule({required this.days});

  final List<MonkScheduleDay> days;

  factory MonkWeeklySchedule.fromJson(dynamic json) {
    final list = json is List
        ? json
        : (json as Map<String, dynamic>)['days'] as List<dynamic>? ??
            (json)['schedule'] as List<dynamic>? ??
            [];
    if (list.isEmpty) {
      return MonkWeeklySchedule.defaults();
    }
    return MonkWeeklySchedule(
      days: list
          .map((e) => MonkScheduleDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'days': days.map((d) => d.toJson()).toList(),
      };

  factory MonkWeeklySchedule.defaults() =>
      MonkWeeklySchedule(days: defaultDays);

  static List<MonkScheduleDay> defaultDays = const [
        MonkScheduleDay(name: 'Даваа', active: true, start: '09:00', end: '18:00'),
        MonkScheduleDay(name: 'Мягмар', active: true, start: '09:00', end: '18:00'),
        MonkScheduleDay(name: 'Лхагва', active: true, start: '09:00', end: '18:00'),
        MonkScheduleDay(name: 'Пүрэв', active: true, start: '09:00', end: '18:00'),
        MonkScheduleDay(name: 'Баасан', active: true, start: '09:00', end: '18:00'),
        MonkScheduleDay(name: 'Бямба', active: false, start: '09:00', end: '18:00'),
        MonkScheduleDay(name: 'Ням', active: false, start: '09:00', end: '18:00'),
      ];
}
