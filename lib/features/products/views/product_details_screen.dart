import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/viewmodels/customer_view_model.dart';
import '../../account/views/account_screen.dart';
import '../../cart/viewmodels/cart_view_model.dart';
import '../../favorites/viewmodels/favorites_view_model.dart';
import '../models/product.dart';
import '../../../core/l10n/app_language.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final customer = ref.watch(customerProvider).customer;
    final favorites = ref.watch(favoritesProvider);
    final quantity = cartItems
        .where((item) => item.product.id == product.id)
        .fold<int>(0, (total, item) => total + item.quantity);
    final isFavorite =
        customer != null &&
        favorites.isFavorite(customerId: customer.id, productId: product.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F3),
        surfaceTintColor: Colors.transparent,
        title: Text(tr('Product details')),
        actions: [
          IconButton(
            onPressed: () => _toggleFavorite(context, ref),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? const Color(0xFFEE7424) : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 290,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDE7),
                borderRadius: BorderRadius.circular(28),
              ),
              child: product.imageUrl?.isNotEmpty == true
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: product.imageUrl!.startsWith('data:image/')
                          ? Image.memory(
                              base64Decode(product.imageUrl!.split(',').last),
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            ),
                    )
                  : _placeholder(),
            ),
            const SizedBox(height: 24),
            Text(
              product.displayName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF171717),
              ),
            ),
            if (product.nameAr != null) ...[
              const SizedBox(height: 4),
              Text(
                product.nameAr!,
                style: const TextStyle(color: Color(0xFF777777)),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  tr('EGP {0}', [product.price.toStringAsFixed(2)]),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFEE7424),
                  ),
                ),
                if (product.hasDiscount) ...[
                  const SizedBox(width: 10),
                  Text(
                    tr('EGP {0}', [product.oldPrice!.toStringAsFixed(2)]),
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            Text(
              product.description ??
                  tr('Fresh, carefully selected and ready for delivery.'),
              style: const TextStyle(
                fontSize: 15,
                height: 1.55,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 22),
            _InfoRow(
              label: tr('Category'),
              value: product.categoryId.replaceAll('-', ' '),
            ),
            _InfoRow(
              label: tr('Availability'),
              value: product.inStock
                  ? tr('{0} in stock', [product.stockQuantity])
                  : tr('Out of stock'),
            ),
            if (product.unit != null)
              _InfoRow(label: tr('Unit'), value: product.unit!),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: product.inStock
            ? quantity == 0
                  ? ElevatedButton(
                      onPressed: () =>
                          ref.read(cartProvider.notifier).addProduct(product),
                      style: _buttonStyle(),
                      child: Text(tr('Add to cart')),
                    )
                  : Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF171717),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .decreaseQuantity(product.id),
                            icon: const Icon(Icons.remove, color: Colors.white),
                          ),
                          Text(
                            tr('{0} in cart', [quantity]),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          IconButton(
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .increaseQuantity(product.id),
                            icon: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                    )
            : SizedBox(
                height: 56,
                child: Center(child: Text(tr('Out of stock'))),
              ),
      ),
    );
  }

  Widget _placeholder() => const Center(
    child: Icon(
      Icons.shopping_bag_outlined,
      size: 100,
      color: Color(0xFFEE7424),
    ),
  );

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(56),
    backgroundColor: const Color(0xFF171717),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
  );

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref) async {
    var customer = ref.read(customerProvider).customer;
    if (customer == null) {
      final authenticated = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const AccountScreen(closeAfterAuthentication: true),
        ),
      );
      if (!context.mounted || authenticated != true) return;
      customer = ref.read(customerProvider).customer;
    }
    if (customer == null) return;
    ref
        .read(favoritesProvider.notifier)
        .toggleFavorite(customerId: customer.id, product: product);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(color: Color(0xFF777777))),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
