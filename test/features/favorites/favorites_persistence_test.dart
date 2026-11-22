import 'package:flutter_test/flutter_test.dart';
import 'package:qebox_private/features/favorites/repositories/favorites_repository.dart';
import 'package:qebox_private/features/favorites/viewmodels/favorites_view_model.dart';
import 'package:qebox_private/features/products/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restores favorites for the correct customer', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const product = Product(
      id: 'eggs',
      name: 'Fresh Eggs',
      price: 120,
      categoryId: 'dairy',
      stockQuantity: 20,
    );

    final firstViewModel = FavoritesViewModel(
      LocalFavoritesRepository(preferences),
    );
    firstViewModel.addFavorite(customerId: 'customer-a', product: product);

    final restoredViewModel = FavoritesViewModel(
      LocalFavoritesRepository(preferences),
    );

    expect(
      restoredViewModel.state.favoritesForCustomer('customer-a'),
      hasLength(1),
    );
    expect(restoredViewModel.state.favoritesForCustomer('customer-b'), isEmpty);
  });
}
