import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/viewmodels/customer_view_model.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/viewmodels/cart_view_model.dart';
import '../../products/models/product.dart';
import '../viewmodels/favorites_view_model.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(customerProvider).customer;

    if (customer == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F7F3),
        appBar: _buildAppBar(context),
        body: const Center(
          child: Text(
            'Please sign in to view your favorites',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF777777),
            ),
          ),
        ),
      );
    }

    final favoritesState = ref.watch(favoritesProvider);

    final favorites = favoritesState.favoritesForCustomer(
      customer.id,
    );

    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      appBar: _buildAppBar(context),
      body: favorites.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                30,
              ),
              itemCount: favorites.length,
              separatorBuilder: (
                context,
                index,
              ) {
                return const SizedBox(
                  height: 12,
                );
              },
              itemBuilder: (
                context,
                index,
              ) {
                final product = favorites[index];

                final quantity = _quantityForProduct(
                  product,
                  cartItems,
                );

                return _FavoriteProductCard(
                  product: product,
                  quantity: quantity,
                  onFavoriteTap: () {
                    ref
                        .read(
                          favoritesProvider.notifier,
                        )
                        .toggleFavorite(
                          customerId: customer.id,
                          product: product,
                        );
                  },
                  onAddToCart: () {
                    ref
                        .read(
                          cartProvider.notifier,
                        )
                        .addProduct(product);
                  },
                  onIncrease: () {
                    ref
                        .read(
                          cartProvider.notifier,
                        )
                        .increaseQuantity(
                          product.id,
                        );
                  },
                  onDecrease: () {
                    ref
                        .read(
                          cartProvider.notifier,
                        )
                        .decreaseQuantity(
                          product.id,
                        );
                  },
                );
              },
            ),
    );
  }

  // =====================================================
  // APP BAR
  // =====================================================

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: const Color(0xFFF9F7F3),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF171717),
        ),
      ),
      title: const Text(
        'My Favorites',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF171717),
        ),
      ),
    );
  }

  // =====================================================
  // EMPTY STATE
  // =====================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE6D5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 38,
                color: Color(0xFFEE7424),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Products you love will appear here.',
              textAlign: TextAlign.center,
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

  // =====================================================
  // PRODUCT QUANTITY
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
}

// =====================================================
// FAVORITE PRODUCT CARD
// =====================================================

class _FavoriteProductCard extends StatelessWidget {
  final Product product;

  final int quantity;

  final VoidCallback onFavoriteTap;
  final VoidCallback onAddToCart;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _FavoriteProductCard({
    required this.product,
    required this.quantity,
    required this.onFavoriteTap,
    required this.onAddToCart,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          // =================================================
          // IMAGE
          // =================================================

          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F1ED),
              borderRadius: BorderRadius.circular(18),
            ),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons.shopping_bag_outlined,
                          size: 38,
                          color: Color(0xFFEE7424),
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.shopping_bag_outlined,
                    size: 38,
                    color: Color(0xFFEE7424),
                  ),
          ),

          const SizedBox(width: 14),

          // =================================================
          // PRODUCT INFO
          // =================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF171717),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Text(
                      'EGP ${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(
                          0xFFEE7424,
                        ),
                      ),
                    ),
                    if (product.hasDiscount) ...[
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        'EGP ${product.oldPrice!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(
                            0xFF999999,
                          ),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                if (!product.inStock)
                  _buildOutOfStock()
                else if (quantity == 0)
                  _buildAddButton()
                else
                  _buildQuantityControl(),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // =================================================
          // FAVORITE
          // =================================================

          Align(
            alignment: Alignment.topCenter,
            child: InkWell(
              onTap: onFavoriteTap,
              borderRadius: BorderRadius.circular(
                20,
              ),
              child: const SizedBox(
                width: 38,
                height: 38,
                child: Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFEE7424),
                  size: 23,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ADD
  // =====================================================

  Widget _buildAddButton() {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onAddToCart,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(
            0xFF171717,
          ),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
        ),
        child: const Text(
          'Add to cart',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // =====================================================
  // QUANTITY
  // =====================================================

  Widget _buildQuantityControl() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(20),
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
              width: 34,
              height: 36,
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
              width: 34,
              height: 36,
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

  // =====================================================
  // OUT OF STOCK
  // =====================================================

  Widget _buildOutOfStock() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFCCCCCC),
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: const Text(
        'Out of stock',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
