class StoreBundle {
  const StoreBundle({
    required this.id,
    required this.name,
    required this.price,
    required this.productIds,
    this.imageUrl,
  });

  final String id;
  final String name;
  final double price;
  final List<String> productIds;
  final String? imageUrl;
}
