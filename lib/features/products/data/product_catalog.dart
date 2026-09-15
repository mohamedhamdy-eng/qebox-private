import '../models/product.dart';

class ProductCatalog {
  const ProductCatalog._();

  static const popularProducts = [
    Product(
        id: 'product_1',
        name: 'Fresh Milk',
        description: 'Fresh dairy milk for your family',
        price: 65,
        oldPrice: 70,
        categoryId: 'dairy',
        stockQuantity: 25,
        isFeatured: true),
    Product(
        id: 'product_2',
        name: 'Daily Snacks',
        description: 'A tasty selection for any time of day',
        price: 35,
        oldPrice: 42,
        categoryId: 'snacks',
        stockQuantity: 40,
        isFeatured: true),
    Product(
        id: 'product_3',
        name: 'Home Care',
        description: 'Everyday cleaning essentials',
        price: 50,
        oldPrice: 60,
        categoryId: 'home-care',
        stockQuantity: 18,
        isFeatured: true),
  ];

  static const newArrivalProducts = [
    Product(
        id: 'product_4',
        name: 'New Dessert',
        description: 'A sweet treat made fresh',
        price: 45,
        categoryId: 'desserts',
        stockQuantity: 20,
        isNew: true),
    Product(
        id: 'product_5',
        name: 'Fresh Bakery',
        description: 'Freshly baked every day',
        price: 30,
        categoryId: 'bakery',
        stockQuantity: 35,
        isNew: true),
    Product(
        id: 'product_6',
        name: 'Coffee Selection',
        description: 'Premium coffee for your morning',
        price: 80,
        categoryId: 'beverages',
        stockQuantity: 15,
        isNew: true),
  ];

  static const recommendedProducts = [
    Product(
        id: 'product_7',
        name: 'Fresh Eggs',
        description: 'Fresh selection for your daily essentials',
        price: 120,
        categoryId: 'dairy',
        stockQuantity: 30,
        isFeatured: true),
    Product(
        id: 'product_8',
        name: 'Fresh Chicken',
        description: 'Freshly prepared and delivered to your door',
        price: 185,
        categoryId: 'fresh-food',
        stockQuantity: 22,
        isFeatured: true),
    Product(
        id: 'product_9',
        name: 'Pantry Essentials',
        description: 'Everything you need for your kitchen',
        price: 25,
        categoryId: 'pantry',
        stockQuantity: 50,
        isFeatured: true),
  ];

  static const allProducts = [
    ...popularProducts,
    ...newArrivalProducts,
    ...recommendedProducts,
  ];
}
