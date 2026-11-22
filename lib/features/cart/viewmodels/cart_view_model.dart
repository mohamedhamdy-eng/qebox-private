import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/models/product.dart';
import '../../products/models/bundle.dart';
import '../models/cart_item.dart';
import '../repositories/cart_repository.dart';

class CartViewModel extends StateNotifier<List<CartItem>> {
  CartViewModel(this._repository) : super(_repository.loadCart());

  final CartRepository _repository;

  void _setItems(List<CartItem> items) {
    state = items;
    _repository.saveCart(items);
  }

  void addProduct(Product product) {
    if (!product.isActive || !product.inStock) return;

    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex == -1) {
      _setItems([...state, CartItem(product: product, quantity: 1)]);
      return;
    }

    final existingItem = state[existingIndex];

    if (product.maxQuantityPerOrder != null &&
        existingItem.quantity >= product.maxQuantityPerOrder!) {
      return;
    }
    if (existingItem.quantity >= product.stockQuantity) return;

    final updatedItems = [...state];

    updatedItems[existingIndex] = existingItem.copyWith(
      quantity: existingItem.quantity + 1,
    );

    _setItems(updatedItems);
  }

  static const _bundlePrefix = 'bundle:';

  static Product _bundleAsProduct(StoreBundle bundle) => Product(
    id: '$_bundlePrefix${bundle.id}',
    name: bundle.name,
    description: '${bundle.productIds.length} products bundle',
    price: bundle.price,
    categoryId: 'bundle',
    stockQuantity: 999,
  );

  void addBundle(StoreBundle bundle) {
    addProduct(_bundleAsProduct(bundle));
  }

  /// Applies current prices and limits, and removes items that the store no
  /// longer sells. Call this only with data confirmed by the server.
  void syncWithCatalog({
    required List<Product> products,
    required List<StoreBundle> bundles,
  }) {
    final currentProducts = {
      for (final product in products) product.id: product,
      for (final bundle in bundles)
        '$_bundlePrefix${bundle.id}': _bundleAsProduct(bundle),
    };
    final synced = <CartItem>[];
    for (final item in state) {
      final current = currentProducts[item.product.id];
      if (current == null || !current.isActive || !current.inStock) continue;
      final limit = current.maxQuantityPerOrder == null
          ? current.stockQuantity
          : min(current.maxQuantityPerOrder!, current.stockQuantity);
      if (limit < 1) continue;
      synced.add(
        item.copyWith(product: current, quantity: min(item.quantity, limit)),
      );
    }
    _setItems(synced);
  }

  void increaseQuantity(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);

    if (index == -1) return;

    final item = state[index];

    if (item.product.maxQuantityPerOrder != null &&
        item.quantity >= item.product.maxQuantityPerOrder!) {
      return;
    }
    if (item.quantity >= item.product.stockQuantity) return;

    final updatedItems = [...state];

    updatedItems[index] = item.copyWith(quantity: item.quantity + 1);

    _setItems(updatedItems);
  }

  void decreaseQuantity(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);

    if (index == -1) return;

    final item = state[index];

    if (item.quantity <= 1) {
      removeProduct(productId);
      return;
    }

    final updatedItems = [...state];

    updatedItems[index] = item.copyWith(quantity: item.quantity - 1);

    _setItems(updatedItems);
  }

  void removeProduct(String productId) {
    _setItems(state.where((item) => item.product.id != productId).toList());
  }

  void clearCart() {
    _setItems([]);
  }

  int get totalItems {
    return state.fold(0, (total, item) => total + item.quantity);
  }

  double get subtotal {
    return state.fold(0, (total, item) => total + item.totalPrice);
  }
}

final cartProvider = StateNotifierProvider<CartViewModel, List<CartItem>>((
  ref,
) {
  throw UnimplementedError(
    'cartProvider must be overridden with a repository in main.',
  );
});
