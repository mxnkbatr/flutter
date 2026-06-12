class AdminMonkServiceItem {
  AdminMonkServiceItem({
    this.name = '',
    this.description = '',
    this.durationMinutes = 30,
    this.price = 0,
    this.category = '',
  });

  String name;
  String description;
  int durationMinutes;
  int price;
  String category;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'durationMinutes': durationMinutes,
        'price': price,
        'category': category,
      };
}

class AdminMonkDetail {
  const AdminMonkDetail({
    required this.id,
    required this.name,
    required this.title,
    required this.temple,
    required this.bio,
    required this.categories,
    required this.services,
    required this.status,
    this.image,
    this.email = '',
  });

  final String id;
  final String name;
  final String title;
  final String? image;
  final String temple;
  final String bio;
  final List<String> categories;
  final List<AdminMonkServiceItem> services;
  final String status;
  final String email;

  factory AdminMonkDetail.fromJson(Map<String, dynamic> json) {
    final nameVal = json['name'];
    String name;
    if (nameVal is Map) {
      name = nameVal['mn']?.toString() ?? nameVal['en']?.toString() ?? '';
    } else {
      name = nameVal?.toString() ?? '';
    }

    final titleVal = json['title'];
    String title;
    if (titleVal is Map) {
      title = titleVal['mn']?.toString() ?? titleVal['en']?.toString() ?? '';
    } else {
      title = titleVal?.toString() ?? '';
    }

    final servicesRaw = json['services'] as List<dynamic>? ?? [];
    return AdminMonkDetail(
      id: json['id'] as String? ?? json['_id'] as String,
      name: name,
      title: title,
      image: json['image'] as String?,
      temple: json['temple'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      services: servicesRaw.map((e) {
        final map = e as Map<String, dynamic>;
        final nameField = map['name'];
        String serviceName;
        if (nameField is Map) {
          serviceName =
              nameField['mn']?.toString() ?? nameField['en']?.toString() ?? '';
        } else {
          serviceName = nameField?.toString() ?? '';
        }
        return AdminMonkServiceItem(
          name: serviceName,
          description: map['description'] as String? ?? '',
          durationMinutes: map['durationMinutes'] as int? ?? 30,
          price: (map['price'] as num?)?.toInt() ?? 0,
          category: map['category'] as String? ?? '',
        );
      }).toList(),
      status: json['status'] as String? ?? 'active',
      email: json['email'] as String? ?? '',
    );
  }
}
