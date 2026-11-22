import 'package:flutter_test/flutter_test.dart';
import 'package:qebox_private/features/checkout/repositories/coupon_repository.dart';
import 'package:qebox_private/features/checkout/viewmodels/checkout_view_model.dart';

class _Coupons implements CouponRepository {
  const _Coupons(this.coupon);

  final Coupon? coupon;

  @override
  Future<Coupon?> findByCode(String code) async => coupon;
}

const _percentage = Coupon(
  code: 'SAVE20',
  type: 'percentage',
  value: 20,
  minimumOrder: 500,
);

void main() {
  test('recalculates a percentage discount when the cart changes', () async {
    final viewModel = CheckoutViewModel(const _Coupons(_percentage));

    await viewModel.applyPromoCode(code: 'save20', subtotal: 1000);

    expect(viewModel.state.promoCode, 'SAVE20');
    expect(viewModel.state.discountFor(1000), 200);
    expect(viewModel.state.discountFor(800), 160);
  });

  test('removes the discount below the minimum order', () async {
    final viewModel = CheckoutViewModel(const _Coupons(_percentage));

    await viewModel.applyPromoCode(code: 'SAVE20', subtotal: 1000);

    expect(viewModel.state.discountFor(200), 0);
    expect(viewModel.state.promoMessageFor(200), contains('Minimum order'));
    expect(viewModel.state.promoMessageFor(1000), contains('20%'));
  });

  test('limits a fixed discount to the subtotal', () {
    const coupon = Coupon(
      code: 'FIXED',
      type: 'fixed',
      value: 100,
      minimumOrder: 0,
    );

    expect(coupon.discountFor(60), 60);
    expect(coupon.discountFor(250), 100);
  });

  test('rounds a discount the same way as the server', () {
    const coupon = Coupon(
      code: 'ROUND',
      type: 'percentage',
      value: 15,
      minimumOrder: 0,
    );

    expect(coupon.discountFor(33.33), 5);
  });

  test('rejects an unknown code', () async {
    final viewModel = CheckoutViewModel(const _Coupons(null));

    await viewModel.applyPromoCode(code: 'NOPE', subtotal: 1000);

    expect(viewModel.state.coupon, isNull);
    expect(viewModel.state.discountFor(1000), 0);
  });
}
