import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/coupon_repository.dart';

enum PaymentMethod { cash, card, wallet }

enum SubstitutionPreference { replaceAutomatically, contactMe, removeItem }

class CheckoutState {
  final PaymentMethod paymentMethod;

  final Coupon? coupon;
  final String? promoMessage;
  final SubstitutionPreference substitutionPreference;
  final String deliveryInstruction;

  const CheckoutState({
    this.paymentMethod = PaymentMethod.cash,
    this.coupon,
    this.promoMessage,
    this.substitutionPreference = SubstitutionPreference.contactMe,
    this.deliveryInstruction = 'Call on arrival',
  });

  String get promoCode => coupon?.code ?? '';

  double discountFor(double subtotal) => coupon?.discountFor(subtotal) ?? 0;

  /// The cart can change after the code is applied, so the message depends on
  /// the current subtotal.
  String? promoMessageFor(double subtotal) {
    final applied = coupon;
    if (applied != null && subtotal < applied.minimumOrder) {
      return 'Minimum order is EGP ${applied.minimumOrder.toStringAsFixed(0)}';
    }
    return promoMessage;
  }

  CheckoutState copyWith({
    PaymentMethod? paymentMethod,
    Coupon? coupon,
    bool clearCoupon = false,
    String? promoMessage,
    bool clearPromoMessage = false,
    SubstitutionPreference? substitutionPreference,
    String? deliveryInstruction,
  }) {
    return CheckoutState(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      coupon: clearCoupon ? null : coupon ?? this.coupon,
      promoMessage: clearPromoMessage
          ? null
          : promoMessage ?? this.promoMessage,
      substitutionPreference:
          substitutionPreference ?? this.substitutionPreference,
      deliveryInstruction: deliveryInstruction ?? this.deliveryInstruction,
    );
  }
}

class CheckoutViewModel extends StateNotifier<CheckoutState> {
  CheckoutViewModel(this._coupons) : super(const CheckoutState());

  final CouponRepository _coupons;

  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void selectSubstitutionPreference(SubstitutionPreference preference) {
    state = state.copyWith(substitutionPreference: preference);
  }

  void selectDeliveryInstruction(String instruction) {
    state = state.copyWith(deliveryInstruction: instruction);
  }

  void resetOrderPreferences() {
    state = CheckoutState(paymentMethod: state.paymentMethod);
  }

  Future<void> applyPromoCode({
    required String code,
    required double subtotal,
  }) async {
    final normalizedCode = code.trim().toUpperCase();

    if (normalizedCode.isEmpty) {
      state = state.copyWith(
        clearCoupon: true,
        promoMessage: 'Please enter a promo code',
      );

      return;
    }

    try {
      final coupon = await _coupons.findByCode(normalizedCode);
      if (coupon == null) {
        state = state.copyWith(
          clearCoupon: true,
          promoMessage: 'Invalid or inactive promo code',
        );
        return;
      }
      if (subtotal < coupon.minimumOrder) {
        state = state.copyWith(
          clearCoupon: true,
          promoMessage:
              'Minimum order is EGP ${coupon.minimumOrder.toStringAsFixed(0)}',
        );
        return;
      }
      state = state.copyWith(
        coupon: coupon,
        promoMessage: coupon.type == 'percentage'
            ? '${coupon.value.toStringAsFixed(0)}% discount applied'
            : 'EGP ${coupon.value.toStringAsFixed(0)} discount applied',
      );
      return;
    } catch (_) {
      state = state.copyWith(
        clearCoupon: true,
        promoMessage: 'Could not validate promo code. Try again.',
      );
      return;
    }
  }

  void removePromoCode() {
    state = state.copyWith(clearCoupon: true, clearPromoMessage: true);
  }
}

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  throw UnimplementedError('CouponRepository must be provided at app startup.');
});

final checkoutProvider =
    StateNotifierProvider<CheckoutViewModel, CheckoutState>(
      (ref) => CheckoutViewModel(ref.watch(couponRepositoryProvider)),
    );
