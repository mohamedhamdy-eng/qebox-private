import '../../../core/l10n/app_language.dart';

class Product {
  final String id;
  final String name;
  final String? nameAr;
  final String? description;
  final String? imageUrl;

  final double price;
  final double? oldPrice;

  final String categoryId;
  final String? brandId;

  final int stockQuantity;
  final int? maxQuantityPerOrder;

  final String? unit;
  final double? weight;

  final bool isActive;
  final bool isNew;
  final bool isFeatured;

  const Product({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.imageUrl,
    required this.price,
    this.oldPrice,
    required this.categoryId,
    this.brandId,
    this.stockQuantity = 0,
    this.maxQuantityPerOrder,
    this.unit,
    this.weight,
    this.isActive = true,
    this.isNew = false,
    this.isFeatured = false,
  });

  bool get inStock => stockQuantity > 0;

  String get displayName =>
      AppLanguage.isArabic && (nameAr?.isNotEmpty ?? false) ? nameAr! : name;

  bool get hasDiscount {
    return oldPrice != null && oldPrice! > price;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      nameAr: json['name_ar'],
      description: json['description'],
      imageUrl: json['image_url'],
      price: (json['price'] as num?)?.toDouble() ?? 0,
      oldPrice: (json['old_price'] as num?)?.toDouble(),
      categoryId: json['category_id']?.toString() ?? '',
      brandId: json['brand_id']?.toString(),
      stockQuantity: json['stock_quantity'] ?? 0,
      maxQuantityPerOrder: json['max_quantity_per_order'],
      unit: json['unit'],
      weight: (json['weight'] as num?)?.toDouble(),
      isActive: json['is_active'] ?? true,
      isNew: json['is_new'] ?? false,
      isFeatured: json['is_featured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'old_price': oldPrice,
      'category_id': categoryId,
      'brand_id': brandId,
      'stock_quantity': stockQuantity,
      'max_quantity_per_order': maxQuantityPerOrder,
      'unit': unit,
      'weight': weight,
      'is_active': isActive,
      'is_new': isNew,
      'is_featured': isFeatured,
    };
  }
}
