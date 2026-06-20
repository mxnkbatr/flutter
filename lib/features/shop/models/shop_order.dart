class ShopOrderItem {
  const ShopOrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });

  final String productId;
  final String name;
  final int price;
  final int quantity;
  final String image;

  factory ShopOrderItem.fromJson(Map<String, dynamic> j) => ShopOrderItem(
        productId: j['productId'] as String? ?? '',
        name: j['name'] as String? ?? '',
        price: (j['price'] as num?)?.toInt() ?? 0,
        quantity: (j['quantity'] as num?)?.toInt() ?? 1,
        image: j['image'] as String? ?? '',
      );
}

class ShopOrder {
  const ShopOrder({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paid,
    required this.createdAt,
    this.invoiceId = '',
    this.userName = '',
    this.address = '',
    this.phone = '',
  });

  final String id;
  final List<ShopOrderItem> items;
  final int totalAmount;
  final String status;
  final bool paid;
  final String createdAt;
  final String invoiceId;
  final String userName;
  final String address;
  final String phone;

  String get statusLabel => switch (status) {
        'paid' => 'Төлөгдсөн',
        'shipped' => 'Хүргэлтэд гарсан',
        'delivered' => 'Хүргэгдсэн',
        'cancelled' => 'Цуцлагдсан',
        _ => 'Хүлээгдэж буй',
      };

  factory ShopOrder.fromJson(Map<String, dynamic> j) => ShopOrder(
        id: j['id'] as String? ?? '',
        items: (j['items'] as List<dynamic>? ?? [])
            .map((e) => ShopOrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalAmount: (j['totalAmount'] as num?)?.toInt() ?? 0,
        status: j['status'] as String? ?? 'pending',
        paid: j['paid'] as bool? ?? false,
        createdAt: j['createdAt'] as String? ?? '',
        invoiceId: j['invoiceId'] as String? ?? '',
        userName: j['userName'] as String? ?? '',
        address: j['address'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
      );
}
