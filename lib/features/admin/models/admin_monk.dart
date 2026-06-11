class AdminMonk {
  const AdminMonk({
    required this.id,
    required this.name,
    this.temple,
    this.image,
    required this.status,
    this.rating = 0,
    this.createdAt,
  });

  final String id;
  final Map<String, String> name;
  final String? temple;
  final String? image;
  final String status;
  final double rating;
  final String? createdAt;

  String get displayName => name['mn'] ?? name['en'] ?? name.values.first;

  factory AdminMonk.fromJson(Map<String, dynamic> json) {
    final nameVal = json['name'];
    Map<String, String> nameMap;
    if (nameVal is Map) {
      nameMap = nameVal.map((k, v) => MapEntry(k.toString(), v.toString()));
    } else {
      nameMap = {'mn': nameVal?.toString() ?? ''};
    }

    return AdminMonk(
      id: json['id'] as String? ?? json['_id'] as String,
      name: nameMap,
      temple: json['temple'] as String? ?? json['monastery'] as String?,
      image: json['image'] as String? ?? json['avatarUrl'] as String?,
      status: json['status'] as String? ?? 'pending',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] as String?,
    );
  }
}
