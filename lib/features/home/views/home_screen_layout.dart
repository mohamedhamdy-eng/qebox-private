part of 'home_screen.dart';

extension _HomeLayout on _HomeScreenState {
  Widget _buildHome() {
    final catalog = ref.watch(catalogProvider);
    final allProducts = catalog.products;
    final banners = catalog.banners;
    final popularProducts = allProducts
        .where((product) => product.isFeatured)
        .toList();
    final newArrivalProducts = allProducts
        .where((product) => product.isNew)
        .toList();
    final recommendedProducts = allProducts
        .where((product) => !product.isNew && !product.isFeatured)
        .toList();
    final cartItems = ref.watch(cartProvider);

    final addressState = ref.watch(addressProvider);

    final customerState = ref.watch(customerProvider);

    final favoritesState = ref.watch(favoritesProvider);

    final searchQuery = ref.watch(homeSearchProvider);
    final searchResults = ref.read(homeSearchProvider.notifier).filter([
      ...allProducts,
    ]);

    final selectedAddress = addressState.selectedAddress;

    bool isFavorite(Product product) {
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._headerSection(),
            ..._deliveryAddressSection(selectedAddress),
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
                decoration: InputDecoration(
                  hintText: tr('Search products, brands and categories'),
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF171717),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 17),
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (searchQuery.isNotEmpty) ...[
              _buildSearchResults(searchResults, cartItems, isFavorite),
            ] else ...[
              SectionTitle(title: tr('Shop by category')),
              const SizedBox(height: 18),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: catalog.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = catalog.categories[index];
                    return CategoryItem(
                      icon: Icons.local_grocery_store_outlined,
                      title: category.displayName,
                      imageUrl: category.imageUrl,
                      onTap: () => _openCategory(category.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 34),

              if (catalog.bundles.isNotEmpty) ...[
                SectionTitle(title: tr('Value bundles')),
                const SizedBox(height: 14),
                SizedBox(
                  height: 144,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: catalog.bundles.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final bundle = catalog.bundles[index];
                      return InkWell(
                        onTap: () =>
                            _showBundleDetails(bundle, catalog.products),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 220,
                          decoration: BoxDecoration(
                            color: QeboxPalette.mint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (bundle.imageUrl?.isNotEmpty == true)
                                bundle.imageUrl!.startsWith('data:image')
                                    ? Image.memory(
                                        base64Decode(
                                          bundle.imageUrl!.split(',').last,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        bundle.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const SizedBox.shrink(),
                                      ),
                              Container(
                                color: bundle.imageUrl?.isNotEmpty == true
                                    ? Colors.black38
                                    : Colors.transparent,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bundle.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tr('{0} products · EGP {1}', [
                                        bundle.productIds.length,
                                        bundle.price.toStringAsFixed(2),
                                      ]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            bundle.imageUrl?.isNotEmpty == true
                                            ? Colors.white
                                            : QeboxPalette.muted,
                                      ),
                                    ),
                                    const Spacer(),
                                    Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: TextButton.icon(
                                        onPressed: () => _showBundleDetails(
                                          bundle,
                                          catalog.products,
                                        ),
                                        icon: const Icon(
                                          Icons.add_shopping_cart_outlined,
                                          size: 18,
                                        ),
                                        label: Text(tr('Add bundle')),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],

              ..._dealsSection(banners),
              ..._popularSection(popularProducts, cartItems, isFavorite),
              ..._newArrivalsSection(newArrivalProducts, cartItems, isFavorite),
              ..._recommendedSection(
                recommendedProducts,
                cartItems,
                isFavorite,
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Color(0xFFBBBBBB),
              ),
              const SizedBox(height: 14),
              Text(
                tr('No products found'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171717),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tr('Try another product or category name.'),
                style: const TextStyle(fontSize: 13, color: Color(0xFF777777)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: tr('{0} search results', [products.length])),
        const SizedBox(height: 16),
        ...products.map((product) {
          final quantity = _quantityForProduct(product, cartItems);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _RecommendedCard(
              product: product,
              onTap: () => _openProductDetails(product),
              badge: tr('SEARCH RESULT'),
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

  Widget _buildCartIcon({required IconData icon, required int count}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          PositionedDirectional(
            end: -8,
            top: -7,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEE7424),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1.5),
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
          _applyState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFEE7424),
        unselectedItemColor: const Color(0xFF999999),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: (AppLanguage.isArabic ? 'الرئيسية' : 'Home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_outlined),
            activeIcon: const Icon(Icons.grid_view_rounded),
            label: tr('Categories'),
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
            label: tr('Cart'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long_rounded),
            label: tr('Orders'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: tr('Account'),
          ),
        ],
      ),
    );
  }
}
