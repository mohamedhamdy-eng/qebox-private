import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/models/product.dart';

class FavoritesState {
  final Map<String, Map<String, Product>> favoritesByCustomer;

  const FavoritesState({
    this.favoritesByCustomer = const {},
  });

  // =====================================================
  // GET CUSTOMER FAVORITES
  // =====================================================

  List<Product> favoritesForCustomer(
    String customerId,
  ) {
    final customerFavorites =
        favoritesByCustomer[customerId];

    if (customerFavorites == null) {
      return [];
    }

    return customerFavorites.values.toList();
  }

  // =====================================================
  // CHECK FAVORITE
  // =====================================================

  bool isFavorite({
    required String customerId,
    required String productId,
  }) {
    return favoritesByCustomer[customerId]
            ?.containsKey(productId) ??
        false;
  }
}

class FavoritesNotifier
    extends StateNotifier<FavoritesState> {
  FavoritesNotifier()
      : super(
          const FavoritesState(),
        );

  // =====================================================
  // ADD FAVORITE
  // =====================================================

  void addFavorite({
    required String customerId,
    required Product product,
  }) {
    final updatedFavorites =
        _copyFavorites();

    final customerFavorites =
        Map<String, Product>.from(
      updatedFavorites[customerId] ?? {},
    );

    customerFavorites[product.id] =
        product;

    updatedFavorites[customerId] =
        customerFavorites;

    state = FavoritesState(
      favoritesByCustomer:
          updatedFavorites,
    );
  }

  // =====================================================
  // REMOVE FAVORITE
  // =====================================================

  void removeFavorite({
    required String customerId,
    required String productId,
  }) {
    final updatedFavorites =
        _copyFavorites();

    final customerFavorites =
        Map<String, Product>.from(
      updatedFavorites[customerId] ?? {},
    );

    customerFavorites.remove(
      productId,
    );

    updatedFavorites[customerId] =
        customerFavorites;

    state = FavoritesState(
      favoritesByCustomer:
          updatedFavorites,
    );
  }

  // =====================================================
  // TOGGLE FAVORITE
  // =====================================================

  void toggleFavorite({
    required String customerId,
    required Product product,
  }) {
    final alreadyFavorite =
        state.isFavorite(
      customerId: customerId,
      productId: product.id,
    );

    if (alreadyFavorite) {
      removeFavorite(
        customerId: customerId,
        productId: product.id,
      );

      return;
    }

    addFavorite(
      customerId: customerId,
      product: product,
    );
  }

  // =====================================================
  // CLEAR CUSTOMER FAVORITES
  // =====================================================

  void clearCustomerFavorites(
    String customerId,
  ) {
    final updatedFavorites =
        _copyFavorites();

    updatedFavorites.remove(
      customerId,
    );

    state = FavoritesState(
      favoritesByCustomer:
          updatedFavorites,
    );
  }

  // =====================================================
  // COPY DATA
  // =====================================================

  Map<String, Map<String, Product>>
      _copyFavorites() {
    return state
        .favoritesByCustomer
        .map(
      (customerId, products) {
        return MapEntry(
          customerId,
          Map<String, Product>.from(
            products,
          ),
        );
      },
    );
  }
}

final favoritesProvider =
    StateNotifierProvider<
        FavoritesNotifier,
        FavoritesState>(
  (ref) {
    return FavoritesNotifier();
  },
);