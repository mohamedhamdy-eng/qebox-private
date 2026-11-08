import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qebox_private/features/account/models/customer.dart';
import 'package:qebox_private/features/account/repositories/customer_repository.dart';
import 'package:qebox_private/features/account/repositories/phone_auth_repository.dart';
import 'package:qebox_private/features/account/viewmodels/customer_view_model.dart';
import 'package:qebox_private/features/account/views/account_screen.dart';
import 'package:qebox_private/features/addresses/models/address.dart';
import 'package:qebox_private/features/addresses/repositories/address_repository.dart';
import 'package:qebox_private/features/addresses/viewmodels/address_view_model.dart';
import 'package:qebox_private/features/addresses/views/add_address_screen.dart';
import 'package:qebox_private/features/addresses/views/address_selection_screen.dart';
import 'package:qebox_private/features/cart/repositories/cart_repository.dart';
import 'package:qebox_private/features/cart/viewmodels/cart_view_model.dart';
import 'package:qebox_private/features/cart/views/cart_screen.dart';
import 'package:qebox_private/features/chat/views/q_bot_screen.dart';
import 'package:qebox_private/features/checkout/repositories/coupon_repository.dart';
import 'package:qebox_private/features/checkout/viewmodels/checkout_view_model.dart';
import 'package:qebox_private/features/checkout/views/checkout_screen.dart';
import 'package:qebox_private/features/checkout/views/delivery_schedule_screen.dart';
import 'package:qebox_private/features/favorites/repositories/favorites_repository.dart';
import 'package:qebox_private/features/favorites/viewmodels/favorites_view_model.dart';
import 'package:qebox_private/features/favorites/views/favorites_screen.dart';
import 'package:qebox_private/features/home/views/home_screen.dart';
import 'package:qebox_private/features/onboarding/repositories/onboarding_repository.dart';
import 'package:qebox_private/features/onboarding/viewmodels/onboarding_view_model.dart';
import 'package:qebox_private/features/orders/models/order.dart';
import 'package:qebox_private/features/orders/repositories/orders_repository.dart';
import 'package:qebox_private/features/orders/viewmodels/orders_view_model.dart';
import 'package:qebox_private/features/orders/views/order_confirmed_screen.dart';
import 'package:qebox_private/features/orders/views/order_details_screen.dart';
import 'package:qebox_private/features/orders/views/orders_screen.dart';
import 'package:qebox_private/features/products/models/banner.dart';
import 'package:qebox_private/features/products/models/bundle.dart';
import 'package:qebox_private/features/products/models/category.dart';
import 'package:qebox_private/features/products/models/product.dart';
import 'package:qebox_private/features/products/repositories/catalog_repository.dart';
import 'package:qebox_private/features/products/viewmodels/catalog_view_model.dart';
import 'package:qebox_private/features/products/views/categories_screen.dart';
import 'package:qebox_private/features/products/views/product_details_screen.dart';
import 'package:qebox_private/features/rewards/views/rewards_screen.dart';
import 'package:qebox_private/views/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pixel =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

const _milk = Product(
  id: 'milk',
  name: 'Fresh Milk',
  nameAr: 'لبن طازج',
  description: 'Fresh dairy milk for your family',
  price: 65,
  oldPrice: 70,
  categoryId: 'dairy',
  stockQuantity: 25,
  isFeatured: true,
);
const _bread = Product(
  id: 'bread',
  name: 'Baladi Bread',
  price: 10,
  categoryId: 'bakery',
  stockQuantity: 10,
  isNew: true,
);
const _rice = Product(
  id: 'rice',
  name: 'Egyptian Rice 1kg',
  price: 45,
  categoryId: 'pantry',
  stockQuantity: 8,
);

final _order = CustomerOrder(
  id: 'QB-1700000000000-A3F9',
  customerId: 'customer-a',
  customerName: 'Mohamed',
  customerPhone: '01000000000',
  items: const [
    OrderItem(
      productId: 'milk',
      productName: 'Fresh Milk',
      price: 65,
      quantity: 2,
    ),
  ],
  addressLabel: 'Home',
  addressLine: 'Smouha, Alexandria',
  building: '12',
  floor: '3',
  apartment: '8',
  landmark: 'Near the park',
  deliveryStart: DateTime(2026, 11, 9, 12),
  deliveryEnd: DateTime(2026, 11, 9, 14),
  paymentMethod: OrderPaymentMethod.cash,
  orderNote: 'Please call before delivery',
  promoCode: 'SAVE20',
  subtotal: 130,
  discount: 10,
  deliveryFee: 20,
  total: 140,
  status: OrderStatus.scheduled,
  createdAt: DateTime(2026, 11, 8, 10),
);

class _PhoneAuth implements PhoneAuthRepository {
  @override
  Future<PhoneVerificationSession> sendCode(String phoneNumber) async =>
      const PhoneVerificationSession(verificationId: 'id');

  @override
  Future<String> verifyCode({
    required String verificationId,
    required String smsCode,
  }) async => 'uid';

  @override
  Future<void> signOut() async {}

  @override
  Future<void> ensureDevelopmentSession() async {}
}

class _Coupons implements CouponRepository {
  @override
  Future<Coupon?> findByCode(String code) async => null;
}

class _Catalog implements FirestoreCatalogRepository {
  @override
  Stream<CatalogUpdate<Product>> watchProducts() =>
      Stream.value((items: const [_milk, _bread, _rice], fromServer: true));

  @override
  Stream<CatalogUpdate<StoreBundle>> watchBundles() => Stream.value((
    items: const [
      StoreBundle(
        id: 'b1',
        name: 'Breakfast',
        price: 70,
        productIds: ['milk', 'bread'],
      ),
    ],
    fromServer: true,
  ));

  @override
  Stream<List<Category>> watchCategories() => Stream.value(const [
    Category(id: 'dairy', name: 'Dairy', isActive: true, sortOrder: 0),
  ]);

  @override
  Stream<List<StoreBanner>> watchBanners() => Stream.value(const [
    StoreBanner(id: 'b', title: 'Offer', imageUrl: _pixel),
  ]);
}

Future<ProviderContainer> _container({bool signedIn = true}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      customerProvider.overrideWith(
        (ref) => CustomerViewModel(LocalCustomerRepository(preferences)),
      ),
      phoneAuthRepositoryProvider.overrideWithValue(_PhoneAuth()),
      cartProvider.overrideWith(
        (ref) => CartViewModel(LocalCartRepository(preferences)),
      ),
      addressProvider.overrideWith(
        (ref) =>
            AddressViewModel(LocalAddressRepository(preferences), 'customer-a'),
      ),
      favoritesProvider.overrideWith(
        (ref) => FavoritesViewModel(LocalFavoritesRepository(preferences)),
      ),
      onboardingProvider.overrideWith(
        (ref) => OnboardingViewModel(LocalOnboardingRepository(preferences)),
      ),
      ordersProvider.overrideWith(
        (ref) =>
            OrdersViewModel(LocalOrdersRepository(preferences), 'customer-a'),
      ),
      catalogProvider.overrideWith((ref) => CatalogViewModel(_Catalog())),
      couponRepositoryProvider.overrideWithValue(_Coupons()),
    ],
  );
  if (signedIn) {
    container
        .read(customerProvider.notifier)
        .setCustomer(
          const Customer(
            id: 'customer-a',
            name: 'Mohamed',
            phone: '01000000000',
          ),
        );
  }
  container.read(cartProvider.notifier)
    ..addProduct(_milk)
    ..addProduct(_bread);
  container
      .read(addressProvider.notifier)
      .addAddress(
        const Address(
          id: 'a1',
          label: 'Home',
          addressLine: 'Smouha, Alexandria',
          building: '12',
          floor: '3',
          apartment: '8',
          isDefault: true,
        ),
      );
  container
      .read(favoritesProvider.notifier)
      .addFavorite(customerId: 'customer-a', product: _milk);
  await container.read(ordersProvider.notifier).createOrder(_order);
  container.read(catalogProvider);
  return container;
}

Future<void> _render(
  WidgetTester tester,
  Widget screen, {
  bool signedIn = true,
  ProviderContainer? existing,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final container = existing ?? await _container(signedIn: signedIn);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _finish(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final screens = <String, (Widget, String, bool)>{
    'home': (const HomeScreen(), 'Popular products', true),
    'categories': (const CategoriesScreen(), 'Categories', true),
    'cart': (const CartScreen(), 'Proceed to Checkout', true),
    'checkout': (const CheckoutScreen(), 'Checkout', true),
    'delivery schedule': (
      const DeliveryScheduleScreen(),
      'Choose your delivery time',
      true,
    ),
    'orders': (const OrdersScreen(), 'Active orders', true),
    'order details': (OrderDetailsScreen(order: _order), 'Order details', true),
    'order confirmed': (
      OrderConfirmedScreen(order: _order),
      'Order confirmed!',
      true,
    ),
    'account signed in': (const AccountScreen(), 'My Account', true),
    'account guest': (const AccountScreen(), 'Welcome to Qebox', false),
    'addresses': (const AddressSelectionScreen(), 'Delivery Address', true),
    'add address': (const AddAddressScreen(), 'Add Address', true),
    'favorites': (const FavoritesScreen(), 'My Favorites', true),
    'product details': (
      const ProductDetailsScreen(product: _milk),
      'Product details',
      true,
    ),
    'rewards': (const RewardsScreen(), 'Q Rewards', true),
    'onboarding': (const OnboardingScreen(), 'Fast delivery', true),
    'q bot': (const QBotScreen(), 'Q Bot', true),
  };

  for (final MapEntry(key: name, value: (screen, expected, signedIn))
      in screens.entries) {
    testWidgets('$name renders without errors', (tester) async {
      await _render(tester, screen, signedIn: signedIn);

      expect(find.text(expected), findsWidgets);
      await _finish(tester);
    });
  }

  testWidgets('cart shows the empty state', (tester) async {
    final container = await _container();
    container.read(cartProvider.notifier).clearCart();

    await _render(tester, const CartScreen(), existing: container);

    expect(find.text('Your cart is empty'), findsOneWidget);
    await _finish(tester);
  });

  testWidgets('checkout offers only cash on delivery', (tester) async {
    await _render(tester, const CheckoutScreen());

    await tester.scrollUntilVisible(
      find.text('Cash on delivery'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cash on delivery'), findsOneWidget);
    expect(find.text('Qebox Wallet'), findsNothing);
    expect(find.text('Credit / Debit Card'), findsNothing);
    await _finish(tester);
  });
}
