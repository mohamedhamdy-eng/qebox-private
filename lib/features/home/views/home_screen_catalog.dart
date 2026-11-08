part of 'home_screen.dart';

extension _HomeCatalogSections on _HomeScreenState {
  List<Widget> _dealsSection(List<StoreBanner> banners) {
    return [
      // =====================================================
      // DEALS
      // =====================================================
      const SectionTitle(title: 'Deals for you'),
      const SizedBox(height: 16),

      if (banners.isNotEmpty) ...[
        SizedBox(
          height: 190,
          child: Stack(
            children: [
              PageView.builder(
                controller: _bannerController,
                onPageChanged: (index) =>
                    _applyState(() => _activeBanner = index),
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: banner.imageUrl.startsWith('data:image/')
                          ? Image.memory(
                              base64Decode(banner.imageUrl.split(',').last),
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              banner.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                    ),
                  );
                },
              ),
              if (banners.length > 1) ...[
                PositionedDirectional(
                  start: 8,
                  top: 72,
                  child: _bannerArrow(
                    Icons.chevron_left,
                    () => _bannerController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                PositionedDirectional(
                  end: 8,
                  top: 72,
                  child: _bannerArrow(
                    Icons.chevron_right,
                    () => _bannerController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < banners.length; i++)
                        Container(
                          width: i == _activeBanner ? 18 : 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],

      Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 190),
        decoration: BoxDecoration(
          color: QeboxPalette.green,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -10,
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
                      borderRadius: BorderRadius.circular(20),
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
    ];
  }

  List<Widget> _popularSection(
    List<Product> popularProducts,
    List<CartItem> cartItems,
    bool Function(Product) isFavorite,
  ) {
    return [
      // =====================================================
      // POPULAR PRODUCTS
      // =====================================================
      const SectionTitle(title: 'Popular products'),

      const SizedBox(height: 16),

      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(popularProducts.length, (index) {
            final product = popularProducts[index];

            final quantity = _quantityForProduct(product, cartItems);

            return Padding(
              padding: EdgeInsetsDirectional.only(
                end: index == popularProducts.length - 1 ? 0 : 14,
              ),
              child: SizedBox(
                width: 176,
                child: ProductCard(
                  product: product,
                  quantity: quantity,
                  isFavorite: isFavorite(product),
                  onTap: () => _openProductDetails(product),
                  onFavoriteTap: () {
                    _handleFavoriteTap(product);
                  },
                  onAddToCart: () {
                    _addProductToCart(product);
                  },
                  onIncrease: () {
                    _increaseProductQuantity(product);
                  },
                  onDecrease: () {
                    _decreaseProductQuantity(product);
                  },
                ),
              ),
            );
          }),
        ),
      ),

      const SizedBox(height: 34),
    ];
  }

  List<Widget> _newArrivalsSection(
    List<Product> newArrivalProducts,
    List<CartItem> cartItems,
    bool Function(Product) isFavorite,
  ) {
    return [
      // =====================================================
      // NEW ARRIVALS
      // =====================================================
      const SectionTitle(title: 'New arrivals'),

      const SizedBox(height: 16),

      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(newArrivalProducts.length, (index) {
            final product = newArrivalProducts[index];

            final quantity = _quantityForProduct(product, cartItems);

            return Padding(
              padding: EdgeInsetsDirectional.only(
                end: index == newArrivalProducts.length - 1 ? 0 : 14,
              ),
              child: SizedBox(
                width: 176,
                child: ProductCard(
                  product: product,
                  quantity: quantity,
                  isFavorite: isFavorite(product),
                  onTap: () => _openProductDetails(product),
                  onFavoriteTap: () {
                    _handleFavoriteTap(product);
                  },
                  onAddToCart: () {
                    _addProductToCart(product);
                  },
                  onIncrease: () {
                    _increaseProductQuantity(product);
                  },
                  onDecrease: () {
                    _decreaseProductQuantity(product);
                  },
                ),
              ),
            );
          }),
        ),
      ),

      const SizedBox(height: 34),
    ];
  }

  List<Widget> _recommendedSection(
    List<Product> recommendedProducts,
    List<CartItem> cartItems,
    bool Function(Product) isFavorite,
  ) {
    return [
      // =====================================================
      // RECOMMENDED
      // =====================================================
      const SectionTitle(title: 'Recommended for you'),

      const SizedBox(height: 16),

      Column(
        children: List.generate(recommendedProducts.length, (index) {
          final product = recommendedProducts[index];

          final quantity = _quantityForProduct(product, cartItems);

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == recommendedProducts.length - 1 ? 0 : 14,
            ),
            child: _RecommendedCard(
              product: product,
              onTap: () => _openProductDetails(product),
              badge:
                  _HomeScreenState._recommendedBadges[index %
                      _HomeScreenState._recommendedBadges.length],
              quantity: quantity,
              isFavorite: isFavorite(product),
              onFavoriteTap: () {
                _handleFavoriteTap(product);
              },
              onAdd: () {
                _addProductToCart(product);
              },
              onIncrease: () {
                _increaseProductQuantity(product);
              },
              onDecrease: () {
                _decreaseProductQuantity(product);
              },
            ),
          );
        }),
      ),
    ];
  }
}
