import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/models/product.dart';
import '../models/cart_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(Product product) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex == -1) {
      state = [
        ...state,
        CartItem(
          product: product,
          quantity: 1,
        ),
      ];
      return;
    }

    final existingItem = state[existingIndex];

    if (product.maxQuantityPerOrder != null &&
        existingItem.quantity >= product.maxQuantityPerOrder!) {
      return;
    }

    final updatedItems = [...state];

    updatedItems[existingIndex] = existingItem.copyWith(
      quantity: existingItem.quantity + 1,
    );

    state = updatedItems;
  }

  void increaseQuantity(String productId) {
    final index = state.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index == -1) return;

    final item = state[index];

    if (item.product.maxQuantityPerOrder != null &&
        item.quantity >= item.product.maxQuantityPerOrder!) {
      return;
    }

    final updatedItems = [...state];

    updatedItems[index] = item.copyWith(
      quantity: item.quantity + 1,
    );

    state = updatedItems;
  }

  void decreaseQuantity(String productId) {
    final index = state.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index == -1) return;

    final item = state[index];

    if (item.quantity <= 1) {
      removeProduct(productId);
      return;
    }

    final updatedItems = [...state];

    updatedItems[index] = item.copyWith(
      quantity: item.quantity - 1,
    );

    state = updatedItems;
  }

  void removeProduct(String productId) {
    state = state
        .where(
          (item) => item.product.id != productId,
        )
        .toList();
  }

  void clearCart() {
    state = [];
  }

  int get totalItems {
    return state.fold(
      0,
      (total, item) => total + item.quantity,
    );
  }

  double get subtotal {
    return state.fold(
      0,
      (total, item) => total + item.totalPrice,
    );
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) {
    return CartNotifier();
  },
);