part of 'cart_screen.dart';

extension _CartSections on CartScreen {
  List<Widget> _headerSection(BuildContext context, WidgetRef ref) {
    return [
      // =================================================
      // HEADER
      // =================================================
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                ref.read(cartProvider.notifier).clearCart();

                ref.read(orderNoteProvider.notifier).clear();
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
    ];
  }

  List<Widget> _contentSection(
    BuildContext context,
    WidgetRef ref,
    List<CartItem> cartItems,
    String orderNote,
  ) {
    final recommended = _recommendedProducts(ref, cartItems);

    return [
      // =================================================
      // SCROLLABLE CART CONTENT
      // =================================================
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            // =============================================
            // CART ITEMS
            // =============================================
            ...List.generate(cartItems.length, (index) {
              final item = cartItems[index];
              final product = item.product;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == cartItems.length - 1 ? 0 : 14,
                ),
                child: _CartItemCard(
                  item: item,
                  onDecrease: () {
                    ref
                        .read(cartProvider.notifier)
                        .decreaseQuantity(product.id);
                  },
                  onIncrease: () {
                    ref
                        .read(cartProvider.notifier)
                        .increaseQuantity(product.id);
                  },
                  onRemove: () {
                    ref.read(cartProvider.notifier).removeProduct(product.id);
                  },
                ),
              );
            }),

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
              style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
            ),

            const SizedBox(height: 14),

            TextFormField(
              initialValue: orderNote,
              maxLines: 4,
              maxLength: 250,
              onChanged: (value) {
                ref.read(orderNoteProvider.notifier).updateNote(value);
              },
              decoration: InputDecoration(
                hintText: 'Example: Please call before delivery...',
                hintStyle: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Color(0xFFEE7424),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // =============================================
            // RECOMMENDED PRODUCTS
            // =============================================
            if (recommended.isNotEmpty) ...[
              const SizedBox(height: 30),

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
                style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommended.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 12);
                  },
                  itemBuilder: (context, index) {
                    final product = recommended[index];

                    final quantity = _quantityForProduct(product, cartItems);

                    return _CartRecommendedCard(
                      product: product,
                      quantity: quantity,
                      onAdd: () {
                        ref.read(cartProvider.notifier).addProduct(product);
                      },
                      onIncrease: () {
                        ref
                            .read(cartProvider.notifier)
                            .increaseQuantity(product.id);
                      },
                      onDecrease: () {
                        ref
                            .read(cartProvider.notifier)
                            .decreaseQuantity(product.id);
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    ];
  }

  List<Widget> _summarySection(BuildContext context, double subtotal) {
    return [
      // =================================================
      // BOTTOM SUMMARY
      // =================================================
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(fontSize: 15, color: Color(0xFF777777)),
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
                  backgroundColor: const Color(0xFF171717),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                  style: TextStyle(fontSize: 13, color: Color(0xFF777777)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
