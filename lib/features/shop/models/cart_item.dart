import 'package:sacred_app/features/shop/models/product.dart';

class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final Product product;
  int quantity;

  int get subtotal => product.price * quantity;
}
