import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/qebox_theme.dart';
import '../../account/viewmodels/customer_view_model.dart';
import '../../account/views/account_screen.dart';
import '../../addresses/models/address.dart';
import '../../addresses/viewmodels/address_view_model.dart';
import '../../addresses/views/address_selection_screen.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/viewmodels/cart_view_model.dart';
import '../../cart/views/cart_screen.dart';
import '../../favorites/viewmodels/favorites_view_model.dart';
import '../../orders/views/orders_screen.dart';
import '../../products/models/product.dart';
import '../../products/models/banner.dart';
import '../../products/models/bundle.dart';
import '../../products/viewmodels/catalog_view_model.dart';
import '../../products/views/categories_screen.dart';
import '../../products/views/product_details_screen.dart';
import '../../products/widgets/product_card.dart';
import '../viewmodels/home_search_view_model.dart';
import '../widgets/category_item.dart';
import '../widgets/section_title.dart';

part 'home_screen_top.dart';
part 'home_screen_catalog.dart';
part 'home_screen_layout.dart';
part 'home_screen_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _applyState(VoidCallback change) => setState(change);

  int _selectedIndex = 0;
  final _bannerController = PageController();
  int _activeBanner = 0;

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  // =====================================================
  // TEMPORARY PRODUCT DATA
  // Later this will come from API / Backend / Dashboard
  // =====================================================

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
      MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
    );
  }

  void _openCategory(String? categoryId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CategoriesScreen(initialCategory: categoryId, showBackButton: true),
      ),
    );
  }

  void _showBundleDetails(StoreBundle bundle, List<Product> products) {
    final included = products
        .where((product) => bundle.productIds.contains(product.id))
        .toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bundle.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'EGP ${bundle.price.toStringAsFixed(2)} · ${bundle.productIds.length} products',
                style: const TextStyle(color: QeboxPalette.muted),
              ),
              const SizedBox(height: 16),
              const Text(
                'Included products',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              if (included.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Product details are loading.'),
                ),
              for (final product in included)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: Text(product.name),
                  trailing: Text('EGP ${product.price.toStringAsFixed(2)}'),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  ref.read(cartProvider.notifier).addBundle(bundle);
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${bundle.name} added to cart')),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Add bundle to cart'),
              ),
            ],
          ),
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

  Future<void> _handleFavoriteTap(Product product) async {
    var customer = ref.read(customerProvider).customer;

    // Guest -> Sign In / Sign Up first.
    if (customer == null) {
      final authenticated = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) {
            return const AccountScreen(closeAfterAuthentication: true);
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

    final wasFavorite = ref
        .read(favoritesProvider)
        .isFavorite(customerId: customer.id, productId: product.id);

    ref
        .read(favoritesProvider.notifier)
        .toggleFavorite(customerId: customer.id, product: product);

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

  int _quantityForProduct(Product product, List<CartItem> cartItems) {
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

    final beforeQuantity = _quantityForProduct(product, beforeItems);

    ref.read(cartProvider.notifier).addProduct(product);

    final afterItems = ref.read(cartProvider);

    final afterQuantity = _quantityForProduct(product, afterItems);

    if (afterQuantity == beforeQuantity) {
      _showMaximumQuantityMessage(product);
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'VIEW CART', onPressed: _openCart),
      ),
    );
  }

  void _increaseProductQuantity(Product product) {
    final beforeItems = ref.read(cartProvider);

    final beforeQuantity = _quantityForProduct(product, beforeItems);

    ref.read(cartProvider.notifier).increaseQuantity(product.id);

    final afterItems = ref.read(cartProvider);

    final afterQuantity = _quantityForProduct(product, afterItems);

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

  Widget _bannerArrow(IconData icon, VoidCallback onTap) => Material(
    color: Colors.black.withValues(alpha: .35),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, color: Colors.white),
      ),
    ),
  );

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

  // =====================================================
  // CART BADGE
  // =====================================================

  // =====================================================
  // BOTTOM NAVIGATION
  // =====================================================
}
