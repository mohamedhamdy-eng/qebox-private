import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentMethod {
  cash,
  card,
  wallet,
}

class CheckoutState {
  final PaymentMethod paymentMethod;

  final String promoCode;
  final double discountAmount;
  final String? promoMessage;

  const CheckoutState({
    this.paymentMethod = PaymentMethod.cash,
    this.promoCode = '',
    this.discountAmount = 0,
    this.promoMessage,
  });

  CheckoutState copyWith({
    PaymentMethod? paymentMethod,
    String? promoCode,
    double? discountAmount,
    String? promoMessage,
    bool clearPromoMessage = false,
  }) {
    return CheckoutState(
      paymentMethod:
          paymentMethod ?? this.paymentMethod,
      promoCode:
          promoCode ?? this.promoCode,
      discountAmount:
          discountAmount ?? this.discountAmount,
      promoMessage: clearPromoMessage
          ? null
          : promoMessage ?? this.promoMessage,
    );
  }
}

class CheckoutNotifier
    extends StateNotifier<CheckoutState> {
  CheckoutNotifier()
      : super(
          const CheckoutState(),
        );

  void selectPaymentMethod(
    PaymentMethod method,
  ) {
    state = state.copyWith(
      paymentMethod: method,
    );
  }

  void applyPromoCode({
    required String code,
    required double subtotal,
  }) {
    final normalizedCode =
        code.trim().toUpperCase();

    if (normalizedCode.isEmpty) {
      state = state.copyWith(
        promoCode: '',
        discountAmount: 0,
        promoMessage:
            'Please enter a promo code',
      );

      return;
    }

    // TEMPORARY DEMO PROMO LOGIC
    // Later this will come from Backend / Dashboard.

    if (normalizedCode == 'SAVE10') {
      final discount =
          subtotal * 0.10;

      state = state.copyWith(
        promoCode: normalizedCode,
        discountAmount: discount,
        promoMessage:
            '10% discount applied',
      );

      return;
    }

    if (normalizedCode == 'QBOX20') {
      final discount =
          subtotal >= 200 ? 20.0 : 0.0;

      if (discount == 0) {
        state = state.copyWith(
          promoCode: '',
          discountAmount: 0,
          promoMessage:
              'Minimum order is EGP 200',
        );

        return;
      }

      state = state.copyWith(
        promoCode: normalizedCode,
        discountAmount: 20,
        promoMessage:
            'EGP 20 discount applied',
      );

      return;
    }

    state = state.copyWith(
      promoCode: '',
      discountAmount: 0,
      promoMessage:
          'Invalid promo code',
    );
  }

  void removePromoCode() {
    state = state.copyWith(
      promoCode: '',
      discountAmount: 0,
      clearPromoMessage: true,
    );
  }
}

final checkoutProvider =
    StateNotifierProvider<
        CheckoutNotifier,
        CheckoutState>(
  (ref) {
    return CheckoutNotifier();
  },
);