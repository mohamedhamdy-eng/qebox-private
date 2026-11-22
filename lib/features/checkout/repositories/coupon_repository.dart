import 'package:cloud_functions/cloud_functions.dart';

class Coupon {
  const Coupon({
    required this.code,
    required this.type,
    required this.value,
    required this.minimumOrder,
  });
  final String code;
  final String type;
  final double value;
  final double minimumOrder;

  /// Returns 0 below the minimum order. This calculation matches the
  /// placeOrder function, which rejects any different total.
  double discountFor(double subtotal) {
    if (subtotal < minimumOrder) return 0;
    final piastres = (subtotal * 100).round();
    final discount = type == 'percentage'
        ? (piastres * value / 100).round()
        : (value * 100).round();
    return discount.clamp(0, piastres) / 100;
  }
}

abstract class CouponRepository {
  Future<Coupon?> findByCode(String code);
}

class CallableCouponRepository implements CouponRepository {
  CallableCouponRepository(this._functions);
  final FirebaseFunctions _functions;

  @override
  Future<Coupon?> findByCode(String code) async {
    final result = await _functions
        .httpsCallable('previewCoupon')
        .call<Map<Object?, Object?>?>({'code': code});
    final data = result.data;
    if (data == null) return null;
    return Coupon(
      code: (data['code'] ?? '').toString(),
      type: (data['type'] ?? 'fixed').toString(),
      value: (data['value'] as num? ?? 0).toDouble(),
      minimumOrder: (data['minimumOrder'] as num? ?? 0).toDouble(),
    );
  }
}
