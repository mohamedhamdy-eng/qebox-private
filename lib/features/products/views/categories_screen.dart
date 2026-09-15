import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/viewmodels/customer_view_model.dart';
import '../../account/views/account_screen.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/viewmodels/cart_view_model.dart';
import '../../favorites/viewmodels/favorites_view_model.dart';
import '../data/product_catalog.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen(
      {this.initialCategory, this.showBackButton = false, super.key});
  final String? initialCategory;
  final bool showBackButton;

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  late String? _selectedCategory = widget.initialCategory;

  static const _categories = <String, String>{
    'dairy': 'Dairy',
    'snacks': 'Snacks',
    'home-care': 'Home care',
    'desserts': 'Desserts',
    'bakery': 'Bakery',
    'beverages': 'Beverages',
    'fresh-food': 'Fresh food',
    'pantry': 'Pantry',
  };

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final customer = ref.watch(customerProvider).customer;
    final favorites = ref.watch(favoritesProvider);
    final products = _selectedCategory == null
        ? ProductCatalog.allProducts
        : ProductCatalog.allProducts
            .where((item) => item.categoryId == _selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        backgroundColor: const Color(0xFFF9F7F3),
        surfaceTintColor: Colors.transparent,
        title: const Text('Categories',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _chip(null, 'All'),
                ..._categories.entries
                    .map((entry) => _chip(entry.key, entry.value)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .64,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final quantity = _quantity(product, cart);
                return ProductCard(
                  product: product,
                  quantity: quantity,
                  isFavorite: customer != null &&
                      favorites.isFavorite(
                        customerId: customer.id,
                        productId: product.id,
                      ),
                  onTap: () => _openDetails(product),
                  onFavoriteTap: () => _toggleFavorite(product),
                  onAddToCart: () =>
                      ref.read(cartProvider.notifier).addProduct(product),
                  onIncrease: () => ref
                      .read(cartProvider.notifier)
                      .increaseQuantity(product.id),
                  onDecrease: () => ref
                      .read(cartProvider.notifier)
                      .decreaseQuantity(product.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String? id, String label) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _selectedCategory == id,
          onSelected: (_) => setState(() => _selectedCategory = id),
          selectedColor: const Color(0xFFFFE6D5),
        ),
      );

  int _quantity(Product product, List<CartItem> cart) => cart
      .where((item) => item.product.id == product.id)
      .fold<int>(0, (total, item) => total + item.quantity);

  void _openDetails(Product product) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product)));
  }

  Future<void> _toggleFavorite(Product product) async {
    var customer = ref.read(customerProvider).customer;
    if (customer == null) {
      final authenticated = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const AccountScreen(
            closeAfterAuthentication: true,
          ),
        ),
      );
      if (!mounted || authenticated != true) return;
      customer = ref.read(customerProvider).customer;
    }
    if (customer == null) return;
    ref.read(favoritesProvider.notifier).toggleFavorite(
          customerId: customer.id,
          product: product,
        );
  }
}
