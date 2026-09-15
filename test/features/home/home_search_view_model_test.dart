import 'package:flutter_test/flutter_test.dart';
import 'package:qebox_private/features/home/viewmodels/home_search_view_model.dart';
import 'package:qebox_private/features/products/models/product.dart';

void main() {
  const products = [
    Product(
      id: 'milk',
      name: 'Fresh Milk',
      price: 65,
      categoryId: 'dairy',
      stockQuantity: 10,
    ),
    Product(
      id: 'coffee',
      name: 'Coffee Selection',
      description: 'Premium morning drink',
      price: 80,
      categoryId: 'hot-beverages',
      stockQuantity: 8,
    ),
  ];

  test('searches names, descriptions, and categories case-insensitively', () {
    final viewModel = HomeSearchViewModel();

    viewModel.updateQuery('MILK');
    expect(viewModel.filter(products).single.id, 'milk');

    viewModel.updateQuery('morning');
    expect(viewModel.filter(products).single.id, 'coffee');

    viewModel.updateQuery('hot beverages');
    expect(viewModel.filter(products).single.id, 'coffee');
  });

  test('returns no products for an unknown query', () {
    final viewModel = HomeSearchViewModel();
    viewModel.updateQuery('unknown item');

    expect(viewModel.filter(products), isEmpty);
  });
}
