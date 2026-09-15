import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/models/product.dart';

class HomeSearchViewModel extends StateNotifier<String> {
  HomeSearchViewModel() : super('');

  void updateQuery(String query) {
    state = query.trim().toLowerCase();
  }

  List<Product> filter(List<Product> products) {
    if (state.isEmpty) return products;

    return products.where((product) {
      final searchableText = [
        product.name,
        product.nameAr,
        product.description,
        product.categoryId.replaceAll('-', ' '),
        product.brandId,
        product.unit,
      ].whereType<String>().join(' ').toLowerCase();

      return searchableText.contains(state);
    }).toList();
  }
}

final homeSearchProvider = StateNotifierProvider<HomeSearchViewModel, String>(
  (ref) => HomeSearchViewModel(),
);
