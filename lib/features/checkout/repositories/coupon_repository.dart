import 'package:cloud_firestore/cloud_firestore.dart';

class Coupon {
  const Coupon(
      {required this.code,
      required this.type,
      required this.value,
      required this.minimumOrder,
      required this.active});
  final String code;
  final String type;
  final double value;
  final double minimumOrder;
  final bool active;
}

abstract class CouponRepository {
  Future<Coupon?> findByCode(String code);
}

class FirestoreCouponRepository implements CouponRepository {
  FirestoreCouponRepository(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<Coupon?> findByCode(String code) async {
    final snapshot = await _firestore
        .collection('coupons')
        .where('code', isEqualTo: code)
        .where('active', isEqualTo: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    return Coupon(
        code: (data['code'] ?? '').toString(),
        type: (data['type'] ?? 'fixed').toString(),
        value: (data['value'] as num? ?? 0).toDouble(),
        minimumOrder: (data['minimumOrder'] as num? ?? 0).toDouble(),
        active: data['active'] == true);
  }
}
