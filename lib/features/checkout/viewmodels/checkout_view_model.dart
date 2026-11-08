import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/coupon_repository.dart';

enum PaymentMethod {
  cash,
  card,
  wallet,
}

enum SubstitutionPreference {
  replaceAutomatically,
  contactMe,
  removeItem,
}

class CheckoutState {
  final PaymentMethod paymentMethod;

  final String promoCode;
  final double discountAmount;
  final String? promoMessage;
  final SubstitutionPreference substitutionPreference;
  final String deliveryInstruction;

  const CheckoutState({
    this.paymentMethod = PaymentMethod.cash,
    this.promoCode = '',
    this.discountAmount = 0,
    this.promoMessage,
    this.substitutionPreference = SubstitutionPreference.contactMe,
    this.deliveryInstruction = 'Call on arrival',
  });

  CheckoutState copyWith({
    PaymentMethod? paymentMethod,
    String? promoCode,
    double? discountAmount,
    String? promoMessage,
    bool clearPromoMessage = false,
    SubstitutionPreference? substitutionPreference,
    String? deliveryInstruction,
  }) {
    return CheckoutState(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      promoCode: promoCode ?? this.promoCode,
      discountAmount: discountAmount ?? this.discountAmount,
      promoMessage:
          clearPromoMessage ? null : promoMessage ?? this.promoMessage,
      substitutionPreference:
          substitutionPreference ?? this.substitutionPreference,
      deliveryInstruction: deliveryInstruction ?? this.deliveryInstruction,
    );
  }
}

class CheckoutViewModel extends StateNotifier<CheckoutState> {
  CheckoutViewModel(this._coupons)
      : super(
          const CheckoutState(),
        );

  final CouponRepository _coupons;

  void selectPaymentMethod(
    PaymentMethod method,
  ) {
    state = state.copyWith(
      paymentMethod: method,
    );
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
        promoCode: '',
        discountAmount: 0,
        promoMessage: 'Please enter a promo code',
      );

      return;
    }

    try {
      final coupon = await _coupons.findByCode(normalizedCode);
      if (coupon == null || !coupon.active) {
        state = state.copyWith(
            promoCode: '',
            discountAmount: 0,
            promoMessage: 'Invalid or inactive promo code');
        return;
      }
      if (subtotal < coupon.minimumOrder) {
        state = state.copyWith(
            promoCode: '',
            discountAmount: 0,
            promoMessage:
                'Minimum order is EGP ${coupon.minimumOrder.toStringAsFixed(0)}');
        return;
      }
      final discount = coupon.type == 'percentage'
          ? subtotal * coupon.value / 100
          : coupon.value;
      state = state.copyWith(
          promoCode: coupon.code,
          discountAmount: discount > subtotal ? subtotal : discount,
          promoMessage: coupon.type == 'percentage'
              ? '${coupon.value.toStringAsFixed(0)}% discount applied'
              : 'EGP ${coupon.value.toStringAsFixed(0)} discount applied');
      return;
    } catch (_) {
      state = state.copyWith(
          promoCode: '',
          discountAmount: 0,
          promoMessage: 'Could not validate promo code. Try again.');
      return;
    }
  }

  void removePromoCode() {
    state = state.copyWith(
      promoCode: '',
      discountAmount: 0,
      clearPromoMessage: true,
    );
  }
}

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  throw UnimplementedError('CouponRepository must be provided at app startup.');
});

final checkoutProvider =
    StateNotifierProvider<CheckoutViewModel, CheckoutState>(
  (ref) => CheckoutViewModel(ref.watch(couponRepositoryProvider)),
);
