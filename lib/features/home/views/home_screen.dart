import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/qebox_theme.dart';
import '../../account/viewmodels/customer_view_model.dart';
import '../../account/views/account_screen.dart';
import '../../addresses/viewmodels/address_view_model.dart';
import '../../addresses/views/address_selection_screen.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/viewmodels/cart_view_model.dart';
import '../../cart/views/cart_screen.dart';
import '../../favorites/viewmodels/favorites_view_model.dart';
import '../../orders/views/orders_screen.dart';
import '../../products/data/product_catalog.dart';
import '../../products/models/product.dart';
import '../../products/views/categories_screen.dart';
import '../../products/views/product_details_screen.dart';
import '../../products/widgets/product_card.dart';
import '../viewmodels/home_search_view_model.dart';
import '../widgets/category_item.dart';
import '../widgets/section_title.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  // =====================================================
  // TEMPORARY PRODUCT DATA
  // Later this will come from API / Backend / Dashboard
  // =====================================================

  static const List<Product> _popularProducts = ProductCatalog.popularProducts;
  static const List<Product> _newArrivalProducts =
      ProductCatalog.newArrivalProducts;
  static const List<Product> _recommendedProducts =
      ProductCatalog.recommendedProducts;

  static const List<String> _recommendedBadges = [
    'TOP PICK',
    'POPULAR',
    'FOR YOU',
  ];

  // =====================================================
  // ADDRESS
  // =====================================================

  void _openAddressSelection() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const AddressSelectionScreen();
        },
      ),
    );
  }

  void _openProductDetails(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }

  void _openCategory(String? categoryId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoriesScreen(
          initialCategory: categoryId,
          showBackButton: true,
        ),
      ),
    );
  }

  void _openAccount() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() => _selectedIndex = 4);
  }

  // =====================================================
  // FAVORITES
  // =====================================================

  Future<void> _handleFavoriteTap(
    Product product,
  ) async {
    var customer = ref.read(customerProvider).customer;

    // Guest -> Sign In / Sign Up first.
    if (customer == null) {
      final authenticated = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) {
            return const AccountScreen(
              closeAfterAuthentication: true,
            );
          },
        ),
      );

      if (!mounted || authenticated != true) {
        return;
      }

      customer = ref.read(customerProvider).customer;
    }

    if (customer == null) {
      return;
    }

    final wasFavorite = ref.read(favoritesProvider).isFavorite(
          customerId: customer.id,
          productId: product.id,
        );

    ref.read(favoritesProvider.notifier).toggleFavorite(
          customerId: customer.id,
          product: product,
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFavorite
              ? '${product.name} removed from favorites'
              : '${product.name} added to favorites',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =====================================================
  // CART HELPERS
  // =====================================================

  int _quantityForProduct(
    Product product,
    List<CartItem> cartItems,
  ) {
    for (final item in cartItems) {
      if (item.product.id == product.id) {
        return item.quantity;
      }
    }

    return 0;
  }

  void _openCart() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    setState(() {
      _selectedIndex = 2;
    });
  }

  void _addProductToCart(Product product) {
    final beforeItems = ref.read(cartProvider);

    final beforeQuantity = _quantityForProduct(
      product,
      beforeItems,
    );

    ref.read(cartProvider.notifier).addProduct(product);

    final afterItems = ref.read(cartProvider);

    final afterQuantity = _quantityForProduct(
      product,
      afterItems,
    );

    if (afterQuantity == beforeQuantity) {
      _showMaximumQuantityMessage(product);
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.name} added to cart',
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: _openCart,
        ),
      ),
    );
  }

  void _increaseProductQuantity(Product product) {
    final beforeItems = ref.read(cartProvider);

    final beforeQuantity = _quantityForProduct(
      product,
      beforeItems,
    );

    ref.read(cartProvider.notifier).increaseQuantity(product.id);

    final afterItems = ref.read(cartProvider);

    final afterQuantity = _quantityForProduct(
      product,
      afterItems,
    );

    if (afterQuantity == beforeQuantity) {
      _showMaximumQuantityMessage(product);
    }
  }

  void _decreaseProductQuantity(Product product) {
    ref.read(cartProvider.notifier).decreaseQuantity(product.id);
  }

  void _showMaximumQuantityMessage(Product product) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final limit = product.maxQuantityPerOrder;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          limit != null
              ? 'Maximum quantity allowed is $limit'
              : 'Unable to add more of this product',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      body: SafeArea(
        child: _selectedIndex == 0
            ? _buildHome()
            : _selectedIndex == 1
                ? const CategoriesScreen()
                : _selectedIndex == 2
                    ? const CartScreen()
                    : _selectedIndex == 3
                        ? const OrdersScreen()
                        : const AccountScreen(),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // =====================================================
  // HOME
  // =====================================================

  Widget _buildHome() {
    final cartItems = ref.watch(cartProvider);

    final addressState = ref.watch(addressProvider);

    final customerState = ref.watch(customerProvider);

    final favoritesState = ref.watch(favoritesProvider);

    final searchQuery = ref.watch(homeSearchProvider);
    final searchResults = ref.read(homeSearchProvider.notifier).filter([
      ..._popularProducts,
      ..._newArrivalProducts,
      ..._recommendedProducts,
    ]);

    final selectedAddress = addressState.selectedAddress;

    bool isFavorite(
      Product product,
    ) {
      final customer = customerState.customer;

      if (customer == null) {
        return false;
      }

      return favoritesState.isFavorite(
        customerId: customer.id,
        productId: product.id,
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // HEADER
            // =====================================================

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Qebox',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF171717),
                  ),
                ),
                InkWell(
                  onTap: _openAccount,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF171717),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // =====================================================
            // DELIVERY ADDRESS
            // =====================================================

            InkWell(
              onTap: _openAddressSelection,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE6D5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        selectedAddress?.label.toLowerCase() == 'work'
                            ? Icons.work_outline_rounded
                            : selectedAddress?.label.toLowerCase() == 'other'
                                ? Icons.place_outlined
                                : Icons.location_on_outlined,
                        color: const Color(0xFFEE7424),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Delivering to',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF777777)),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            selectedAddress?.label ?? 'Choose address',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF171717)),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            selectedAddress?.addressLine ??
                                'Add your delivery address',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF777777)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF171717),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // =====================================================
            // SEARCH
            // =====================================================

            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                onChanged: ref.read(homeSearchProvider.notifier).updateQuery,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search products, brands and categories',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF171717),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 17,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (searchQuery.isNotEmpty) ...[
              _buildSearchResults(
                searchResults,
                cartItems,
                isFavorite,
              ),
            ] else ...[
              const SectionTitle(title: 'Shop by category'),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CategoryItem(
                    icon: Icons.local_grocery_store_outlined,
                    title: 'Groceries',
                    onTap: () => _openCategory(null),
                  ),
                  CategoryItem(
                    icon: Icons.local_drink_outlined,
                    title: 'Beverages',
                    onTap: () => _openCategory('beverages'),
                  ),
                  CategoryItem(
                    icon: Icons.breakfast_dining_outlined,
                    title: 'Snacks',
                    onTap: () => _openCategory('snacks'),
                  ),
                  CategoryItem(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Home',
                    onTap: () => _openCategory('home-care'),
                  ),
                ],
              ),
              const SizedBox(height: 34),

              // =====================================================
              // DEALS
              // =====================================================

              const SectionTitle(title: 'Deals for you'),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                height: 190,
                decoration: BoxDecoration(
                  color: QeboxPalette.green,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -5,
                      child: Image.asset(
                        'assets/grocery-box.png',
                        width: 170,
                        height: 170,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: const Text(
                              'SPECIAL OFFER',
                              style: TextStyle(
                                color: QeboxPalette.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Fresh picks,\nbetter prices.',
                            style: TextStyle(
                              fontSize: 25,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Save up to 25%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: QeboxPalette.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              // =====================================================
              // POPULAR PRODUCTS
              // =====================================================

              const SectionTitle(
                title: 'Popular products',
              ),

              const SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _popularProducts.length,
                    (index) {
                      final product = _popularProducts[index];

                      final quantity = _quantityForProduct(
                        product,
                        cartItems,
                      );

                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == _popularProducts.length - 1 ? 0 : 14,
                        ),
                        child: ProductCard(
                          product: product,
                          quantity: quantity,
                          isFavorite: isFavorite(product),
                          onTap: () => _openProductDetails(product),
                          onFavoriteTap: () {
                            _handleFavoriteTap(
                              product,
                            );
                          },
                          onAddToCart: () {
                            _addProductToCart(product);
                          },
                          onIncrease: () {
                            _increaseProductQuantity(
                              product,
                            );
                          },
                          onDecrease: () {
                            _decreaseProductQuantity(
                              product,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 34),

              // =====================================================
              // NEW ARRIVALS
              // =====================================================

              const SectionTitle(
                title: 'New arrivals',
              ),

              const SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _newArrivalProducts.length,
                    (index) {
                      final product = _newArrivalProducts[index];

                      final quantity = _quantityForProduct(
                        product,
                        cartItems,
                      );

                      return Padding(
                        padding: EdgeInsets.only(
                          right:
                              index == _newArrivalProducts.length - 1 ? 0 : 14,
                        ),
                        child: ProductCard(
                          product: product,
                          quantity: quantity,
                          isFavorite: isFavorite(product),
                          onTap: () => _openProductDetails(product),
                          onFavoriteTap: () {
                            _handleFavoriteTap(
                              product,
                            );
                          },
                          onAddToCart: () {
                            _addProductToCart(product);
                          },
                          onIncrease: () {
                            _increaseProductQuantity(
                              product,
                            );
                          },
                          onDecrease: () {
                            _decreaseProductQuantity(
                              product,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 34),

              // =====================================================
              // RECOMMENDED
              // =====================================================

              const SectionTitle(
                title: 'Recommended for you',
              ),

              const SizedBox(height: 16),

              Column(
                children: List.generate(
                  _recommendedProducts.length,
                  (index) {
                    final product = _recommendedProducts[index];

                    final quantity = _quantityForProduct(
                      product,
                      cartItems,
                    );

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom:
                            index == _recommendedProducts.length - 1 ? 0 : 14,
                      ),
                      child: _RecommendedCard(
                        product: product,
                        onTap: () => _openProductDetails(product),
                        badge: _recommendedBadges[index],
                        quantity: quantity,
                        isFavorite: isFavorite(product),
                        onFavoriteTap: () {
                          _handleFavoriteTap(
                            product,
                          );
                        },
                        onAdd: () {
                          _addProductToCart(product);
                        },
                        onIncrease: () {
                          _increaseProductQuantity(
                            product,
                          );
                        },
                        onDecrease: () {
                          _decreaseProductQuantity(
                            product,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    List<Product> products,
    List<CartItem> cartItems,
    bool Function(Product product) isFavorite,
  ) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Color(0xFFBBBBBB),
              ),
              SizedBox(height: 14),
              Text(
                'No products found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171717),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Try another product or category name.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF777777),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: '${products.length} search results'),
        const SizedBox(height: 16),
        ...products.map((product) {
          final quantity = _quantityForProduct(product, cartItems);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _RecommendedCard(
              product: product,
              onTap: () => _openProductDetails(product),
              badge: 'SEARCH RESULT',
              quantity: quantity,
              isFavorite: isFavorite(product),
              onFavoriteTap: () => _handleFavoriteTap(product),
              onAdd: () => _addProductToCart(product),
              onIncrease: () => _increaseProductQuantity(product),
              onDecrease: () => _decreaseProductQuantity(product),
            ),
          );
        }),
      ],
    );
  }

  // =====================================================
  // CART BADGE
  // =====================================================

  Widget _buildCartIcon({
    required IconData icon,
    required int count,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -8,
            top: -7,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 17,
                minHeight: 17,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEE7424),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // =====================================================
  // BOTTOM NAVIGATION
  // =====================================================

  Widget _buildBottomNavigation() {
    final cartItems = ref.watch(cartProvider);

    final cartCount = cartItems.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 15,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFEE7424),
        unselectedItemColor: const Color(0xFF999999),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: _buildCartIcon(
              icon: Icons.shopping_cart_outlined,
              count: cartCount,
            ),
            activeIcon: _buildCartIcon(
              icon: Icons.shopping_cart_rounded,
              count: cartCount,
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// RECOMMENDED CARD
// =====================================================

class _RecommendedCard extends StatelessWidget {
  final Product product;
  final String badge;
  final int quantity;
  final bool isFavorite;
  final VoidCallback onTap;

  final VoidCallback onFavoriteTap;
  final VoidCallback onAdd;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _RecommendedCard({
    required this.product,
    required this.badge,
    required this.quantity,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onAdd,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F1ED),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 38,
                    color: Color(0xFFEE7424),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: InkWell(
                    onTap: onFavoriteTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: isFavorite
                            ? const Color(0xFFEE7424)
                            : const Color(0xFF171717),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFFFE6D5,
                      ),
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(
                          0xFFEE7424,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: Color(0xFF777777),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'EGP ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFEE7424),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!product.inStock)
              _buildOutOfStock()
            else if (quantity == 0)
              _buildAddButton()
            else
              _buildQuantityControl(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFF171717),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildQuantityControl() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrease,
            borderRadius: BorderRadius.circular(
              20,
            ),
            child: const SizedBox(
              width: 32,
              height: 38,
              child: Icon(
                Icons.remove_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
          Text(
            quantity.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          InkWell(
            onTap: onIncrease,
            borderRadius: BorderRadius.circular(
              20,
            ),
            child: const SizedBox(
              width: 32,
              height: 38,
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStock() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFCCCCCC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Out',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
