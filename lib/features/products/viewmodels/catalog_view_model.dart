import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/bundle.dart';
import '../models/banner.dart';
import '../models/product.dart';
import '../repositories/catalog_repository.dart';

class CatalogState {
  const CatalogState(
      {this.products = const [],
      this.categories = const [],
      this.banners = const [],
      this.bundles = const [],
      this.loading = true});
  final List<Product> products;
  final List<Category> categories;
  final List<StoreBanner> banners;
  final List<StoreBundle> bundles;
  final bool loading;
  CatalogState copyWith(
          {List<Product>? products,
          List<Category>? categories,
          List<StoreBanner>? banners,
          List<StoreBundle>? bundles,
          bool? loading}) =>
      CatalogState(
          products: products ?? this.products,
          categories: categories ?? this.categories,
          banners: banners ?? this.banners,
          bundles: bundles ?? this.bundles,
          loading: loading ?? this.loading);
}

class CatalogViewModel extends StateNotifier<CatalogState> {
  CatalogViewModel(FirestoreCatalogRepository repository)
      : super(const CatalogState()) {
    _products = repository.watchProducts().listen(
        (items) => state = state.copyWith(products: items, loading: false));
    _categories = repository.watchCategories().listen(
        (items) => state = state.copyWith(categories: items, loading: false));
    _banners = repository.watchBanners().listen(
        (items) => state = state.copyWith(banners: items, loading: false));
    _bundles = repository.watchBundles().listen(
        (items) => state = state.copyWith(bundles: items, loading: false));
  }
  late final StreamSubscription<List<Product>> _products;
  late final StreamSubscription<List<Category>> _categories;
  late final StreamSubscription<List<StoreBanner>> _banners;
  late final StreamSubscription<List<StoreBundle>> _bundles;
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
        'Catalog provider must be overridden at startup.'));
