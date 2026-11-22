import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/bundle.dart';
import '../models/banner.dart';
import '../models/product.dart';
import '../repositories/catalog_repository.dart';

class CatalogState {
  const CatalogState({
    this.products = const [],
    this.categories = const [],
    this.banners = const [],
    this.bundles = const [],
    this.loading = true,
    this.productsConfirmed = false,
    this.bundlesConfirmed = false,
  });
  final List<Product> products;
  final List<Category> categories;
  final List<StoreBanner> banners;
  final List<StoreBundle> bundles;
  final bool loading;

  /// True after the server, not the cache, supplied the products.
  final bool productsConfirmed;

  /// True after the server, not the cache, supplied the bundles.
  final bool bundlesConfirmed;

  CatalogState copyWith({
    List<Product>? products,
    List<Category>? categories,
    List<StoreBanner>? banners,
    List<StoreBundle>? bundles,
    bool? loading,
    bool? productsConfirmed,
    bool? bundlesConfirmed,
  }) => CatalogState(
    products: products ?? this.products,
    categories: categories ?? this.categories,
    banners: banners ?? this.banners,
    bundles: bundles ?? this.bundles,
    loading: loading ?? this.loading,
    productsConfirmed: productsConfirmed ?? this.productsConfirmed,
    bundlesConfirmed: bundlesConfirmed ?? this.bundlesConfirmed,
  );
}

class CatalogViewModel extends StateNotifier<CatalogState> {
  CatalogViewModel(FirestoreCatalogRepository repository)
    : super(const CatalogState()) {
    _products = repository.watchProducts().listen(
      (update) => state = state.copyWith(
        products: update.items,
        loading: false,
        productsConfirmed: update.fromServer,
      ),
      onError: _stopLoading,
    );
    _categories = repository.watchCategories().listen(
      (items) => state = state.copyWith(categories: items),
      onError: _stopLoading,
    );
    _banners = repository.watchBanners().listen(
      (items) => state = state.copyWith(banners: items),
      onError: _stopLoading,
    );
    _bundles = repository.watchBundles().listen(
      (update) => state = state.copyWith(
        bundles: update.items,
        bundlesConfirmed: update.fromServer,
      ),
      onError: _stopLoading,
    );
  }

  void _stopLoading(Object _) => state = state.copyWith(loading: false);

  late final StreamSubscription<CatalogUpdate<Product>> _products;
  late final StreamSubscription<List<Category>> _categories;
  late final StreamSubscription<List<StoreBanner>> _banners;
  late final StreamSubscription<CatalogUpdate<StoreBundle>> _bundles;
  @override
  void dispose() {
    _products.cancel();
    _categories.cancel();
    _banners.cancel();
    _bundles.cancel();
    super.dispose();
  }
}

final catalogProvider = StateNotifierProvider<CatalogViewModel, CatalogState>(
  (ref) => throw UnimplementedError(
    'Catalog provider must be overridden at startup.',
  ),
);
