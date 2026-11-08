import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../checkout/views/checkout_screen.dart';
import '../../home/views/home_screen.dart';
import '../../products/models/product.dart';
import '../../products/viewmodels/catalog_view_model.dart';
import '../models/cart_item.dart';
import '../viewmodels/cart_view_model.dart';
import '../viewmodels/order_note_view_model.dart';

part 'cart_screen_sections.dart';
part 'cart_screen_widgets.dart';

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

  /// Suggests products from the live catalog that are not in the cart.
  List<Product> _recommendedProducts(WidgetRef ref, List<CartItem> cartItems) {
    final inCart = cartItems.map((item) => item.product.id).toSet();
    return ref
        .watch(catalogProvider)
        .products
        .where((product) => !inCart.contains(product.id))
        .take(6)
        .toList();
  }

  int _quantityForProduct(Product product, List<CartItem> cartItems) {
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
    final orderNote = ref.read(orderNoteProvider);

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
                  ..._headerSection(context, ref),
                  ..._contentSection(context, ref, cartItems, orderNote),
                  ..._summarySection(context, subtotal),
                ],
              ),
      ),
    );
  }
}
