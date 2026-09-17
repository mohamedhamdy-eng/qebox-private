import 'package:flutter/material.dart';

import '../../../core/theme/qebox_theme.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  final int quantity;

  final bool isFavorite;

  final VoidCallback? onAddToCart;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.quantity = 0,
    this.isFavorite = false,
    this.onAddToCart,
    this.onIncrease,
    this.onDecrease,
    this.onFavoriteTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: QeboxPalette.line),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A003B32),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: QeboxPalette.background,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child:
                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
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
                                    size: 48,
                                    color: Color(0xFFEE7424),
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.shopping_bag_outlined,
                              size: 48,
                              color: Color(0xFFEE7424),
                            ),
                ),
                if (product.isNew)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEE7424),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
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
            const SizedBox(height: 12),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'EGP ${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEE7424),
                  ),
                ),
                if (product.hasDiscount) ...[
                  const SizedBox(width: 6),
                  Text(
                    'EGP ${product.oldPrice!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF999999),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (!product.inStock)
              _buildOutOfStockButton()
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
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: onAddToCart,
        style: ElevatedButton.styleFrom(
          backgroundColor: QeboxPalette.deepGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Add to cart',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControl() {
    return Container(
      width: double.infinity,
      height: 36,
      decoration: BoxDecoration(
        color: QeboxPalette.deepGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: onDecrease,
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 36,
              child: Icon(
                Icons.remove_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
          Text(
            quantity.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          InkWell(
            onTap: onIncrease,
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 36,
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStockButton() {
    return Container(
      width: double.infinity,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFCCCCCC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Out of stock',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
