import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../checkout/screens/checkout_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../products/models/product.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../providers/order_note_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) {
          return const HomeScreen();
        },
      ),
      (route) => false,
    );
  }

  static const List<Product> _recommendedProducts = [
    Product(
      id: 'product_4',
      name: 'Fresh Bakery',
      price: 30,
      categoryId: 'bakery',
      stockQuantity: 35,
      isNew: true,
    ),
    Product(
      id: 'product_6',
      name: 'Coffee Selection',
      price: 80,
      categoryId: 'beverages',
      stockQuantity: 15,
      isNew: true,
    ),
    Product(
      id: 'product_7',
      name: 'Fresh Eggs',
      description: 'Fresh selection for your daily essentials',
      price: 120,
      categoryId: 'dairy',
      stockQuantity: 30,
      isFeatured: true,
    ),
  ];

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final orderNote = ref.watch(orderNoteProvider);

    final subtotal = cartItems.fold<double>(
      0,
      (total, item) => total + item.totalPrice,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),

      body: SafeArea(
        child: cartItems.isEmpty
            ? _buildEmptyCart(context)
            : Column(
                children: [
                  // =================================================
                  // HEADER
                  // =================================================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      10,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            _goToHome(context);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 26,
                            color: Color(0xFF171717),
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            ref
                                .read(cartProvider.notifier)
                                .clearCart();

                            ref
                                .read(orderNoteProvider.notifier)
                                .state = '';
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              color: Color(0xFFEE7424),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // SCROLLABLE CART CONTENT
                  // =================================================

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        10,
                        20,
                        24,
                      ),
                      children: [
                        // =============================================
                        // CART ITEMS
                        // =============================================

                        ...List.generate(
                          cartItems.length,
                          (index) {
                            final item = cartItems[index];
                            final product = item.product;

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    index == cartItems.length - 1
                                        ? 0
                                        : 14,
                              ),
                              child: _CartItemCard(
                                item: item,

                                onDecrease: () {
                                  ref
                                      .read(
                                        cartProvider.notifier,
                                      )
                                      .decreaseQuantity(
                                        product.id,
                                      );
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

                                onRemove: () {
                                  ref
                                      .read(
                                        cartProvider.notifier,
                                      )
                                      .removeProduct(
                                        product.id,
                                      );
                                },
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // =============================================
                        // ORDER NOTES
                        // =============================================

                        const Text(
                          'Order notes',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF171717),
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Add any special instructions for your order.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF777777),
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          key: ValueKey(orderNote),
                          initialValue: orderNote,
                          maxLines: 4,
                          maxLength: 250,

                          onChanged: (value) {
                            ref
                                .read(orderNoteProvider.notifier)
                                .state = value;
                          },

                          decoration: InputDecoration(
                            hintText:
                                'Example: Please call before delivery...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 13,
                            ),

                            filled: true,
                            fillColor: Colors.white,

                            contentPadding:
                                const EdgeInsets.all(16),

                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFFEE7424),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // =============================================
                        // RECOMMENDED PRODUCTS
                        // =============================================

                        const Text(
                          'You may also like',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF171717),
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Popular additions for your order',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF777777),
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          height: 190,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,

                            itemCount:
                                _recommendedProducts.length,

                            separatorBuilder: (
                              context,
                              index,
                            ) {
                              return const SizedBox(
                                width: 12,
                              );
                            },

                            itemBuilder: (
                              context,
                              index,
                            ) {
                              final product =
                                  _recommendedProducts[index];

                              final quantity =
                                  _quantityForProduct(
                                product,
                                cartItems,
                              );

                              return _CartRecommendedCard(
                                product: product,
                                quantity: quantity,

                                onAdd: () {
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
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // BOTTOM SUMMARY
                  // =================================================

                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      16,
                      20,
                      20,
                    ),
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF777777),
                              ),
                            ),

                            Text(
                              'EGP ${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF171717),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const CheckoutScreen();
                                  },
                                ),
                              );
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF171717),
                              foregroundColor: Colors.white,
                              elevation: 0,

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(28),
                              ),
                            ),

                            child: const Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            10,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {
                _goToHome(context);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 26,
                color: Color(0xFF171717),
              ),
            ),
          ),
        ),

        const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 90,
                  color: Color(0xFFCCCCCC),
                ),

                SizedBox(height: 20),

                Text(
                  'Your cart is empty',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF171717),
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Add some products and they will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// CART ITEM
// =====================================================

class _CartItemCard extends StatelessWidget {
  final CartItem item;

  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),

      child: Row(
        children: [
          Container(
            width: 85,
            height: 85,

            decoration: BoxDecoration(
              color: const Color(0xFFF3F1ED),
              borderRadius: BorderRadius.circular(18),
            ),

            child: product.imageUrl != null &&
                    product.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(18),
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

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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

                Text(
                  'EGP ${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEE7424),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  height: 36,

                  decoration: BoxDecoration(
                    color: const Color(0xFF171717),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onDecrease,

                        child: const SizedBox(
                          width: 38,
                          height: 36,

                          child: Icon(
                            Icons.remove_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      Text(
                        item.quantity.toString(),

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      InkWell(
                        onTap: onIncrease,

                        child: const SizedBox(
                          width: 38,
                          height: 36,

                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onRemove,

            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// CART RECOMMENDATION CARD
// =====================================================

class _CartRecommendedCard extends StatelessWidget {
  final Product product;
  final int quantity;

  final VoidCallback onAdd;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _CartRecommendedCard({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,

              decoration: BoxDecoration(
                color: const Color(0xFFF3F1ED),
                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 36,
                color: Color(0xFFEE7424),
              ),
            ),
          ),

          const SizedBox(height: 9),

          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF171717),
            ),
          ),

          const SizedBox(height: 5),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'EGP ${product.price.toStringAsFixed(0)}',

                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEE7424),
                  ),
                ),
              ),

              if (quantity == 0)
                InkWell(
                  onTap: onAdd,

                  child: Container(
                    width: 30,
                    height: 30,

                    decoration: const BoxDecoration(
                      color: Color(0xFF171717),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                )
              else
                Container(
                  height: 30,

                  decoration: BoxDecoration(
                    color: const Color(0xFF171717),
                    borderRadius:
                        BorderRadius.circular(18),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onDecrease,

                        child: const SizedBox(
                          width: 27,
                          child: Icon(
                            Icons.remove_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      Text(
                        quantity.toString(),

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      InkWell(
                        onTap: onIncrease,

                        child: const SizedBox(
                          width: 27,
                          child: Icon(
                            Icons.add_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}