import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';

abstract interface class CartRepository {
  List<CartItem> loadCart();

  void saveCart(List<CartItem> items);
}

class LocalCartRepository implements CartRepository {
  LocalCartRepository(this._preferences);

  static const _cartKey = 'shopping_cart';

  final SharedPreferences _preferences;

  @override
  List<CartItem> loadCart() {
    final value = _preferences.getString(_cartKey);
    if (value == null) return [];

    try {
      final decoded = jsonDecode(value) as List<dynamic>;
      return decoded
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  @override
  void saveCart(List<CartItem> items) {
    unawaited(
      _preferences.setString(
        _cartKey,
        jsonEncode(items.map((item) => item.toJson()).toList()),
      ),
    );
  }
}
