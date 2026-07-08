import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/features/shop/models/cart_item.dart';
import 'package:sacred_app/features/shop/models/product.dart';
import 'package:sacred_app/features/shop/models/shop_order.dart';

final shopCategoryProvider = StateProvider<String>((ref) => 'Бүгд');

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final category = ref.watch(shopCategoryProvider);
  final res = await ref.read(apiClientProvider).get(
        '/shop/products',
        queryParameters: category != 'Бүгд' ? {'category': category} : null,
      );
  final list = res.data is List
      ? res.data as List
      : (res.data as Map<String, dynamic>)['products'] as List? ?? [];
  return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
});

final productDetailProvider =
    FutureProvider.family<Product, String>((ref, productId) async {
  final res = await ref.read(apiClientProvider).get('/shop/products/$productId');
  return Product.fromJson(res.data as Map<String, dynamic>);
});

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(Product product) {
    final idx = state.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      state = [
        ...state.sublist(0, idx),
        CartItem(product: product, quantity: state[idx].quantity + 1),
        ...state.sublist(idx + 1),
      ];
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeItem(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void increment(String productId) {
    state = state
        .map(
          (i) => i.product.id == productId
              ? CartItem(product: i.product, quantity: i.quantity + 1)
              : i,
        )
        .toList();
  }

  void decrement(String productId) {
    state = state.map((i) {
      if (i.product.id != productId) return i;
      if (i.quantity <= 1) return i;
      return CartItem(product: i.product, quantity: i.quantity - 1);
    }).toList();
  }

  void clear() => state = [];
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

final cartTotalProvider = Provider<int>((ref) {
  return ref
      .watch(cartProvider)
      .fold(0, (sum, item) => sum + item.subtotal);
});

final cartCountProvider = Provider<int>((ref) {
  return ref
      .watch(cartProvider)
      .fold(0, (sum, item) => sum + item.quantity);
});

final myOrdersProvider = FutureProvider<List<ShopOrder>>((ref) async {
  final res = await ref.read(apiClientProvider).get('/shop/orders');
  final list = res.data is List
      ? res.data as List
      : (res.data as Map<String, dynamic>)['orders'] as List? ?? [];
  return list.map((e) => ShopOrder.fromJson(e as Map<String, dynamic>)).toList();
});

final adminProductsProvider = FutureProvider<List<Product>>((ref) async {
  final res = await ref.read(apiClientProvider).get('/admin/products');
  final list = res.data is List ? res.data as List : [];
  return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
});

Future<void> adminCreateProduct(WidgetRef ref, Map<String, dynamic> data) async {
  await ref.read(apiClientProvider).post('/admin/products', data: data);
  ref.invalidate(adminProductsProvider);
  ref.invalidate(productsProvider);
}

Future<void> adminUpdateProduct(
  WidgetRef ref,
  String id,
  Map<String, dynamic> data,
) async {
  await ref.read(apiClientProvider).put('/admin/products/$id', data: data);
  ref.invalidate(adminProductsProvider);
  ref.invalidate(productsProvider);
}

Future<void> adminDeleteProduct(
  WidgetRef ref,
  String id, {
  bool force = true,
}) async {
  await ref.read(apiClientProvider).delete(
        '/admin/products/$id',
        queryParameters: force ? {'force': '1'} : null,
      );
  ref.invalidate(adminProductsProvider);
  ref.invalidate(productsProvider);
}

final adminShopOrderFilterProvider = StateProvider<String>((ref) => 'all');

final adminOrdersProvider = FutureProvider<List<ShopOrder>>((ref) async {
  final res = await ref.read(apiClientProvider).get('/admin/orders');
  final list = res.data is List ? res.data as List : [];
  return list.map((e) => ShopOrder.fromJson(e as Map<String, dynamic>)).toList();
});

Future<void> adminUpdateOrderStatus(
  WidgetRef ref,
  String orderId,
  String status,
) async {
  await ref.read(apiClientProvider).put(
        '/admin/orders/$orderId/status',
        data: {'status': status},
      );
  ref.invalidate(adminOrdersProvider);
}
