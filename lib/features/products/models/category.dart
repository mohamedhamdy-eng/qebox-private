class Category {
  const Category(
      {required this.id,
      required this.name,
      required this.isActive,
      this.imageUrl,
      this.sortOrder = 0});
  final String id;
  final String name;
  final bool isActive;
  final String? imageUrl;
  final int sortOrder;
}
