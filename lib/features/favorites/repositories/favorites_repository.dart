import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../products/models/product.dart';

abstract interface class FavoritesRepository {
  Map<String, Map<String, Product>> loadAll();

  void saveAll(Map<String, Map<String, Product>> favorites);

  /// Returns the favorites of the account, or null if it has none saved.
  Future<Map<String, Product>?> fetchRemote();

  void saveRemote(Map<String, Product> favorites);
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
    unawaited(_preferences.setString(_favoritesKey, jsonEncode(encoded)));
  }

  @override
  Future<Map<String, Product>?> fetchRemote() async => null;

  @override
  void saveRemote(Map<String, Product> favorites) {}
}

class FirestoreFavoritesRepository implements FavoritesRepository {
  FirestoreFavoritesRepository({
    required LocalFavoritesRepository local,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _local = local,
       _firestore = firestore,
       _auth = auth;

  final LocalFavoritesRepository _local;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Map<String, Map<String, Product>> loadAll() => _local.loadAll();

  @override
  void saveAll(Map<String, Map<String, Product>> favorites) =>
      _local.saveAll(favorites);

  @override
  Future<Map<String, Product>?> fetchRemote() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final snapshot = await _firestore.collection('customers').doc(uid).get();
    final favorites = snapshot.data()?['favorites'];
    if (favorites is! Map<String, dynamic>) return null;
    return favorites.map(
      (id, product) =>
          MapEntry(id, Product.fromJson(product as Map<String, dynamic>)),
    );
  }

  @override
  void saveRemote(Map<String, Product> favorites) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    unawaited(
      _firestore
          .collection('customers')
          .doc(uid)
          .set(
            {
              'favorites': favorites.map(
                (id, product) => MapEntry(id, product.toJson()),
              ),
            },
            // Merge options would keep a removed favorite inside the map.
            SetOptions(mergeFields: const ['favorites']),
          )
          .catchError(
            (Object error) => debugPrint('Favorites sync failed: $error'),
          ),
    );
  }
}
