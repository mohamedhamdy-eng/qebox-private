import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/models/product.dart';
import '../repositories/favorites_repository.dart';

class FavoritesState {
  final Map<String, Map<String, Product>> favoritesByCustomer;

  const FavoritesState({this.favoritesByCustomer = const {}});

  // =====================================================
  // GET CUSTOMER FAVORITES
  // =====================================================

  List<Product> favoritesForCustomer(String customerId) {
    final customerFavorites = favoritesByCustomer[customerId];

    if (customerFavorites == null) {
      return [];
    }

    return customerFavorites.values.toList();
  }

  // =====================================================
  // CHECK FAVORITE
  // =====================================================

  bool isFavorite({required String customerId, required String productId}) {
    return favoritesByCustomer[customerId]?.containsKey(productId) ?? false;
  }
}

class FavoritesViewModel extends StateNotifier<FavoritesState> {
  FavoritesViewModel(this._repository)
    : super(FavoritesState(favoritesByCustomer: _repository.loadAll()));

  final FavoritesRepository _repository;

  void _saveState() {
    _repository.saveAll(state.favoritesByCustomer);
  }

  void _saveCustomer(String customerId) {
    _saveState();
    _repository.saveRemote(state.favoritesByCustomer[customerId] ?? const {});
  }

  String? _syncedCustomerId;

  /// Loads the favorites of the account, or uploads the device favorites if
  /// the account has none.
  Future<void> syncCustomer(String? customerId) async {
    if (customerId == _syncedCustomerId) return;
    _syncedCustomerId = customerId;
    if (customerId == null) return;
    try {
      final remote = await _repository.fetchRemote();
      if (!mounted || customerId != _syncedCustomerId) return;
      if (remote == null) {
        final local = state.favoritesByCustomer[customerId];
        if (local != null && local.isNotEmpty) _repository.saveRemote(local);
        return;
      }
      state = FavoritesState(
        favoritesByCustomer: {..._copyFavorites(), customerId: remote},
      );
      _saveState();
    } catch (error) {
      debugPrint('Favorites restore failed: $error');
    }
  }

  // =====================================================
  // ADD FAVORITE
  // =====================================================

  void addFavorite({required String customerId, required Product product}) {
    final updatedFavorites = _copyFavorites();

    final customerFavorites = Map<String, Product>.from(
      updatedFavorites[customerId] ?? {},
    );

    customerFavorites[product.id] = product;

    updatedFavorites[customerId] = customerFavorites;

    state = FavoritesState(favoritesByCustomer: updatedFavorites);
    _saveCustomer(customerId);
  }

  // =====================================================
  // REMOVE FAVORITE
  // =====================================================

  void removeFavorite({required String customerId, required String productId}) {
    final updatedFavorites = _copyFavorites();

    final customerFavorites = Map<String, Product>.from(
      updatedFavorites[customerId] ?? {},
    );

    customerFavorites.remove(productId);

    updatedFavorites[customerId] = customerFavorites;

    state = FavoritesState(favoritesByCustomer: updatedFavorites);
    _saveCustomer(customerId);
  }

  // =====================================================
  // TOGGLE FAVORITE
  // =====================================================

  void toggleFavorite({required String customerId, required Product product}) {
    final alreadyFavorite = state.isFavorite(
      customerId: customerId,
      productId: product.id,
    );

    if (alreadyFavorite) {
      removeFavorite(customerId: customerId, productId: product.id);

      return;
    }

    addFavorite(customerId: customerId, product: product);
  }

  // =====================================================
  // CLEAR CUSTOMER FAVORITES
  // =====================================================

  void clearCustomerFavorites(String customerId) {
    final updatedFavorites = _copyFavorites();

    updatedFavorites.remove(customerId);

    state = FavoritesState(favoritesByCustomer: updatedFavorites);
    _saveCustomer(customerId);
  }

  // =====================================================
  // COPY DATA
  // =====================================================

  Map<String, Map<String, Product>> _copyFavorites() {
    return state.favoritesByCustomer.map((customerId, products) {
      return MapEntry(customerId, Map<String, Product>.from(products));
    });
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesViewModel, FavoritesState>((ref) {
      throw UnimplementedError(
        'favoritesProvider must be overridden with a repository in main.',
      );
    });
