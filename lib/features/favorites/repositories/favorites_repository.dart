import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../products/models/product.dart';

abstract interface class FavoritesRepository {
  Map<String, Map<String, Product>> loadAll();

  void saveAll(Map<String, Map<String, Product>> favorites);
}

class LocalFavoritesRepository implements FavoritesRepository {
  LocalFavoritesRepository(this._preferences);

  static const _favoritesKey = 'favorites_by_customer';
  final SharedPreferences _preferences;

  @override
  Map<String, Map<String, Product>> loadAll() {
    final value = _preferences.getString(_favoritesKey);
    if (value == null) return {};

    try {
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      return decoded.map((customerId, products) {
        final productMap = products as Map<String, dynamic>;
        return MapEntry(
          customerId,
          productMap.map(
            (productId, product) => MapEntry(
              productId,
              Product.fromJson(product as Map<String, dynamic>),
            ),
          ),
        );
      });
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  @override
  void saveAll(Map<String, Map<String, Product>> favorites) {
    final encoded = favorites.map(
      (customerId, products) => MapEntry(
        customerId,
        products.map(
          (productId, product) => MapEntry(productId, product.toJson()),
        ),
      ),
    );
    unawaited(
      _preferences.setString(_favoritesKey, jsonEncode(encoded)),
    );
  }
}
