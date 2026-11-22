import 'package:flutter_test/flutter_test.dart';
import 'package:qebox_private/features/cart/repositories/cart_repository.dart';
import 'package:qebox_private/features/cart/viewmodels/cart_view_model.dart';
import 'package:qebox_private/features/products/models/bundle.dart';
import 'package:qebox_private/features/products/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restores cart products and quantities after an app restart', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const product = Product(
      id: 'milk',
      name: 'Fresh Milk',
      price: 65,
      categoryId: 'dairy',
      stockQuantity: 10,
    );

    final firstViewModel = CartViewModel(LocalCartRepository(preferences));
    firstViewModel.addProduct(product);
    firstViewModel.increaseQuantity(product.id);

    final restoredViewModel = CartViewModel(LocalCartRepository(preferences));

    expect(restoredViewModel.state, hasLength(1));
    expect(restoredViewModel.state.single.product.id, product.id);
    expect(restoredViewModel.state.single.quantity, 2);
  });

  test(
    'does not add inactive, out-of-stock, or excessive quantities',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final viewModel = CartViewModel(LocalCartRepository(preferences));
      const unavailable = Product(
        id: 'unavailable',
        name: 'Unavailable',
        price: 10,
        categoryId: 'test',
      );
      const limited = Product(
        id: 'limited',
        name: 'Limited',
        price: 10,
        categoryId: 'test',
        stockQuantity: 2,
      );

      viewModel.addProduct(unavailable);
      viewModel.addProduct(limited);
      viewModel.increaseQuantity(limited.id);
      viewModel.increaseQuantity(limited.id);

      expect(viewModel.state, hasLength(1));
      expect(viewModel.state.single.quantity, 2);
    },
  );

  test('applies current catalog prices, limits, and availability', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final viewModel = CartViewModel(LocalCartRepository(preferences));
    const milk = Product(
      id: 'milk',
      name: 'Milk',
      price: 65,
      categoryId: 'dairy',
      stockQuantity: 10,
    );
    const discontinued = Product(
      id: 'old',
      name: 'Old',
      price: 10,
      categoryId: 'test',
      stockQuantity: 10,
    );
    const bundle = StoreBundle(
      id: 'b1',
      name: 'Breakfast',
      price: 70,
      productIds: ['milk'],
    );
    viewModel.addProduct(milk);
    viewModel.increaseQuantity(milk.id);
    viewModel.increaseQuantity(milk.id);
    viewModel.addProduct(discontinued);
    viewModel.addBundle(bundle);

    viewModel.syncWithCatalog(
      products: const [
        Product(
          id: 'milk',
          name: 'Milk',
          price: 80,
          categoryId: 'dairy',
          stockQuantity: 2,
        ),
      ],
      bundles: const [
        StoreBundle(
          id: 'b1',
          name: 'Breakfast',
          price: 75,
          productIds: ['milk'],
        ),
      ],
    );

    expect(viewModel.state.map((item) => item.product.id), [
      'milk',
      'bundle:b1',
    ]);
    expect(viewModel.state.first.product.price, 80);
    expect(viewModel.state.first.quantity, 2);
    expect(viewModel.state.last.product.price, 75);
  });
}
