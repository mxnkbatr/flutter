class MonkService {
  const MonkService({
    required this.id,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.price,
    required this.category,
  });

  final String id;
  final Map<String, String> name;
  final String? description;
  final int durationMinutes;
  final int price;
  final String category;

  String get displayName => name['mn'] ?? name['en'] ?? name.values.first;

  String get durationLabel => '$durationMinutes мин';

  factory MonkService.fromJson(Map<String, dynamic> json) {
    return MonkService(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: _localizedMap(json['name']),
      description: json['description'] as String?,
      durationMinutes:
          json['durationMinutes'] as int? ?? json['duration'] as int? ?? 30,
      price: (json['price'] as num?)?.toInt() ?? 0,
      category: json['category'] as String? ?? '',
    );
  }

  static Map<String, String> _localizedMap(dynamic value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    if (value is String) return {'mn': value};
    return {'mn': ''};
  }
}
