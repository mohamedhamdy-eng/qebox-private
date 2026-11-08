import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/banner.dart';
import '../models/bundle.dart';
import '../models/product.dart';

class FirestoreCatalogRepository {
  FirestoreCatalogRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Stream<List<StoreBanner>> watchBanners() => _firestore
      .collection('banners')
      .where('active', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return StoreBanner(
              id: doc.id,
              title: (data['title'] ?? '').toString(),
              imageUrl: (data['imageUrl'] ?? '').toString(),
            );
          }).where((banner) => banner.imageUrl.isNotEmpty).toList());

  Stream<List<Category>> watchCategories() => _firestore
          .collection('categories')
          .where('active', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          return Category(
              id: doc.id,
              name: (data['name'] ?? doc.id).toString(),
              isActive: data['active'] != false,
              imageUrl: data['imageUrl'] as String?,
              sortOrder: (data['sortOrder'] as num? ?? 0).toInt());
        }).toList();
        items.sort((a, b) => a.sortOrder != b.sortOrder
            ? a.sortOrder.compareTo(b.sortOrder)
            : a.name.compareTo(b.name));
        return items;
      });

  Stream<List<StoreBundle>> watchBundles() => _firestore
      .collection('bundles')
      .where('active', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return StoreBundle(
              id: doc.id,
              name: (data['name'] ?? doc.id).toString(),
              price: (data['price'] as num? ?? 0).toDouble(),
              imageUrl: data['imageUrl'] as String?,
              productIds: (data['productIds'] as List? ?? const [])
                  .map((item) => item.toString())
                  .toList(),
            );
          }).where((bundle) => bundle.productIds.isNotEmpty).toList());

  Stream<List<Product>> watchProducts() => _firestore
          .collection('products')
          .where('active', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          return Product(
              id: doc.id,
              name: (data['name'] ?? doc.id).toString(),
              nameAr: data['nameAr'] as String?,
              description: data['description'] as String?,
              imageUrl: data['imageUrl'] as String?,
              price: (data['price'] as num? ?? 0).toDouble(),
              oldPrice: (data['oldPrice'] as num?)?.toDouble(),
              categoryId: (data['categoryId'] ?? '').toString(),
              stockQuantity: (data['stockQuantity'] as num? ?? 0).toInt(),
              maxQuantityPerOrder:
                  (data['maxQuantityPerOrder'] as num?)?.toInt(),
              unit: data['unit'] as String?,
              isActive: data['active'] != false,
              isNew: data['isNew'] == true,
              isFeatured: data['featured'] == true);
        }).toList();
        final available = items.where((product) => product.inStock).toList();
        available.sort((a, b) => a.name.compareTo(b.name));
        return available;
      });
}
