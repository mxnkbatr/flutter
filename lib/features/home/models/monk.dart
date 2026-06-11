class Monk {
  const Monk({
    required this.id,
    required this.name,
    this.title,
    this.image,
    this.isAvailable = true,
    this.isSpecial = false,
    this.isVip = false,
    this.rating = 0,
    this.reviewCount = 0,
    this.categories = const [],
    this.startingPrice,
    this.bio,
    this.bioLocalized,
    this.completedBookings = 0,
    this.isOnline = false,
  });

  final String id;
  final Map<String, String> name;
  final Map<String, String>? title;
  final String? image;
  final bool isAvailable;
  final bool isSpecial;
  final bool isVip;
  final double rating;
  final int reviewCount;
  final List<String> categories;
  final int? startingPrice;
  final String? bio;
  final Map<String, String>? bioLocalized;
  final int completedBookings;
  final bool isOnline;

  String get displayName => name['mn'] ?? name['en'] ?? name.values.first;

  String? get displayTitle => title?['mn'] ?? title?['en'];

  /// Temple / monastery label (alias for displayTitle).
  String? get temple => displayTitle;

  static String heroTag(String id) => 'monk_$id';

  String? get bioText =>
      bioLocalized?['mn'] ?? bioLocalized?['en'] ?? bio;

  factory Monk.fromJson(Map<String, dynamic> json) {
    return Monk(
      id: json['id'] as String? ?? json['_id'] as String,
      name: _localizedMap(json['name']),
      title: json['title'] != null ? _localizedMap(json['title']) : null,
      image: json['image'] as String? ?? json['avatarUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      isSpecial: json['isSpecial'] as bool? ?? false,
      isVip: json['isVip'] as bool? ?? json['is_vip'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      startingPrice: json['startingPrice'] as int? ??
          (json['minPrice'] as num?)?.toInt(),
      bio: json['bio'] is String
          ? json['bio'] as String
          : json['description'] as String?,
      bioLocalized: json['bio'] is Map
          ? _localizedMap(json['bio'])
          : null,
      completedBookings: json['completedBookings'] as int? ??
          json['bookingCount'] as int? ??
          0,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (title != null) 'title': title,
        if (image != null) 'image': image,
        'isAvailable': isAvailable,
        'isSpecial': isSpecial,
        'isVip': isVip,
        'rating': rating,
        'reviewCount': reviewCount,
        'categories': categories,
        if (startingPrice != null) 'startingPrice': startingPrice,
        if (bio != null) 'bio': bio,
        if (bioLocalized != null) 'bioLocalized': bioLocalized,
        'completedBookings': completedBookings,
        'isOnline': isOnline,
      };

  static Map<String, String> _localizedMap(dynamic value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    if (value is String) return {'mn': value};
    return {'mn': ''};
  }
}
