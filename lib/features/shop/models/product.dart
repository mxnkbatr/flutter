import 'package:sacred_app/core/utils/media_url.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.stock,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final String image;
  final String category;
  final int stock;
  final bool isActive;

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String? ?? j['_id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        description: j['description'] as String? ?? '',
        price: (j['price'] as num?)?.toInt() ?? 0,
        image: resolveMediaUrl(j['image'] as String? ?? ''),
        category: j['category'] as String? ?? 'Бусад',
        stock: (j['stock'] as num?)?.toInt() ?? 0,
        isActive: j['isActive'] as bool? ?? true,
      );
}
