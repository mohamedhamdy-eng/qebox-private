part of 'home_screen.dart';

// =====================================================
// RECOMMENDED CARD
// =====================================================

class _RecommendedCard extends StatelessWidget {
  final Product product;
  final String badge;
  final int quantity;
  final bool isFavorite;
  final VoidCallback onTap;

  final VoidCallback onFavoriteTap;
  final VoidCallback onAdd;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _RecommendedCard({
    required this.product,
    required this.badge,
    required this.quantity,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onAdd,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F1ED),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 38,
                    color: Color(0xFFEE7424),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE6D5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEE7424),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: Color(0xFF777777),
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
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!product.inStock)
              _buildOutOfStock()
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
    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFF171717),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildQuantityControl() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrease,
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 32,
              height: 38,
              child: Icon(Icons.remove_rounded, color: Colors.white, size: 17),
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
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 32,
              height: 38,
              child: Icon(Icons.add_rounded, color: Colors.white, size: 17),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFCCCCCC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Out',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
