import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/models/customer.dart';
import '../../account/providers/customer_provider.dart';
import '../../account/screens/account_screen.dart';

import '../../addresses/models/address.dart';
import '../../addresses/providers/address_provider.dart';
import '../../addresses/screens/address_selection_screen.dart';

import '../../cart/models/cart_item.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/providers/order_note_provider.dart';

import '../../orders/models/order.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/screens/order_confirmed_screen.dart';

import '../providers/checkout_provider.dart';
import '../providers/delivery_schedule_provider.dart';
import 'delivery_schedule_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({
    super.key,
  });

  @override
  ConsumerState<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState
    extends ConsumerState<CheckoutScreen> {
  final TextEditingController _promoController =
      TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

    final addressState =
        ref.watch(addressProvider);

    final orderNote =
        ref.watch(orderNoteProvider);

    final checkoutState =
        ref.watch(checkoutProvider);

    final deliverySchedule =
        ref.watch(deliveryScheduleProvider);

    final selectedAddress =
        addressState.selectedAddress;

    // ==========================================
    // PRICES
    // ==========================================

    final subtotal =
        cartItems.fold<double>(
      0,
      (total, item) =>
          total + item.totalPrice,
    );

    // مؤقتًا
    // بعدين تيجي من الـ Backend / Dashboard
    const double deliveryFee = 20.0;

    final discount =
        checkoutState.discountAmount > subtotal
            ? subtotal
            : checkoutState.discountAmount;

    final total =
        subtotal -
            discount +
            deliveryFee;

    // ==========================================
    // PLACE ORDER VALIDATION
    // ==========================================

    final canPlaceOrder =
        cartItems.isNotEmpty &&
            selectedAddress != null &&
            deliverySchedule.isComplete;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF9F7F3),

      // ========================================
      // APP BAR
      // ========================================

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF9F7F3),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF171717),
          ),
        ),
      ),

      // ========================================
      // BODY
      // ========================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            130,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================
              // DELIVERY ADDRESS
              // ==================================

              const _SectionTitle(
                title: 'Delivery address',
              ),

              const SizedBox(height: 14),

              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const AddressSelectionScreen();
                      },
                    ),
                  );
                },
                borderRadius:
                    BorderRadius.circular(22),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      _ContainerIcon(
                        icon: _getAddressIcon(
                          selectedAddress?.label,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child:
                            selectedAddress == null
                                ? const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Add delivery address',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.w800,
                                          color:
                                              Color(0xFF171717),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Choose where you want your order delivered',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Color(0xFF777777),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              selectedAddress
                                                  .label,
                                              style:
                                                  const TextStyle(
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight.w800,
                                                color:
                                                    Color(0xFF171717),
                                              ),
                                            ),
                                          ),

                                          if (selectedAddress
                                              .isDefault) ...[
                                            const SizedBox(
                                              width: 7,
                                            ),

                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 3,
                                              ),
                                              decoration:
                                                  BoxDecoration(
                                                color:
                                                    const Color(
                                                  0xFFFFE6D5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  10,
                                                ),
                                              ),
                                              child:
                                                  const Text(
                                                'DEFAULT',
                                                style:
                                                    TextStyle(
                                                  fontSize: 8,
                                                  fontWeight:
                                                      FontWeight.w800,
                                                  color:
                                                      Color(
                                                    0xFFEE7424,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        selectedAddress
                                            .addressLine,
                                        maxLines: 2,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style:
                                            const TextStyle(
                                          fontSize: 12,
                                          height: 1.3,
                                          color:
                                              Color(0xFF777777),
                                        ),
                                      ),

                                      if (_buildAddressDetails(
                                        selectedAddress,
                                      ).isNotEmpty) ...[
                                        const SizedBox(
                                          height: 4,
                                        ),

                                        Text(
                                          _buildAddressDetails(
                                            selectedAddress,
                                          ),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style:
                                              const TextStyle(
                                            fontSize: 11,
                                            color:
                                                Color(0xFF999999),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                      ),

                      const SizedBox(width: 8),

                      const Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        size: 16,
                        color:
                            Color(0xFF999999),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ==================================
              // DELIVERY TIME
              // ==================================

              const _SectionTitle(
                title: 'Delivery time',
              ),

              const SizedBox(height: 6),

              const Text(
                'Choose when you want your order delivered.',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      Color(0xFF777777),
                ),
              ),

              const SizedBox(height: 14),

              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const DeliveryScheduleScreen();
                      },
                    ),
                  );
                },
                borderRadius:
                    BorderRadius.circular(22),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(22),
                    border: Border.all(
                      color:
                          deliverySchedule
                                  .isComplete
                              ? const Color(
                                  0xFFEE7424,
                                )
                              : Colors
                                  .transparent,
                      width: 1.3,
                    ),
                  ),
                  child: Row(
                    children: [
                      const _ContainerIcon(
                        icon: Icons
                            .calendar_month_outlined,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child:
                            deliverySchedule
                                    .isComplete
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Selected delivery time',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              Color(0xFF777777),
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 5,
                                      ),

                                      Text(
                                        _deliveryDateLabel(
                                          deliverySchedule,
                                        ),
                                        style:
                                            const TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.w800,
                                          color:
                                              Color(0xFF171717),
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        deliverySchedule
                                            .selectedTimeSlot!
                                            .label,
                                        style:
                                            const TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w700,
                                          color:
                                              Color(0xFFEE7424),
                                        ),
                                      ),
                                    ],
                                  )
                                : const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Choose delivery time',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.w800,
                                          color:
                                              Color(0xFF171717),
                                        ),
                                      ),

                                      SizedBox(height: 4),

                                      Text(
                                        'Today, tomorrow or the next available day',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Color(0xFF777777),
                                        ),
                                      ),
                                    ],
                                  ),
                      ),

                      const SizedBox(width: 8),

                      const Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        size: 16,
                        color:
                            Color(0xFF999999),
                      ),
                    ],
                  ),
                ),
              ),

              if (deliverySchedule
                  .isComplete) ...[
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFFFF4EC),
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons
                            .info_outline_rounded,
                        color:
                            Color(0xFFEE7424),
                        size: 20,
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Your order will be prepared based on your selected delivery slot. Live tracking will start when your delivery begins.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color:
                                Color(0xFF777777),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // ==================================
              // SAVE ON YOUR ORDER
              // ==================================

              const _SectionTitle(
                title: 'Save on your order',
              ),

              const SizedBox(height: 6),

              const Text(
                'Have a promo code? Apply it here.',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      Color(0xFF777777),
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding:
                    const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller:
                                _promoController,
                            enabled:
                                checkoutState
                                    .promoCode
                                    .isEmpty,
                            textCapitalization:
                                TextCapitalization
                                    .characters,
                            decoration:
                                InputDecoration(
                              hintText:
                                  'Enter promo code',
                              prefixIcon:
                                  const Icon(
                                Icons
                                    .local_offer_outlined,
                                color:
                                    Color(0xFFEE7424),
                              ),
                              filled: true,
                              fillColor:
                                  const Color(
                                0xFFF9F7F3,
                              ),
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                                borderSide:
                                    BorderSide.none,
                              ),
                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                                borderSide:
                                    BorderSide.none,
                              ),
                              disabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                                borderSide:
                                    BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                checkoutState
                                        .promoCode
                                        .isEmpty
                                    ? () {
                                        ref
                                            .read(
                                              checkoutProvider
                                                  .notifier,
                                            )
                                            .applyPromoCode(
                                              code:
                                                  _promoController
                                                      .text,
                                              subtotal:
                                                  subtotal,
                                            );
                                      }
                                    : () {
                                        ref
                                            .read(
                                              checkoutProvider
                                                  .notifier,
                                            )
                                            .removePromoCode();

                                        _promoController
                                            .clear();
                                      },
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  checkoutState
                                          .promoCode
                                          .isEmpty
                                      ? const Color(
                                          0xFF171717,
                                        )
                                      : const Color(
                                          0xFFEE7424,
                                        ),
                              foregroundColor:
                                  Colors.white,
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                              ),
                            ),
                            child: Text(
                              checkoutState
                                      .promoCode
                                      .isEmpty
                                  ? 'Apply'
                                  : 'Remove',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (checkoutState
                            .promoMessage !=
                        null) ...[
                      const SizedBox(height: 10),

                      Align(
                        alignment:
                            Alignment.centerLeft,
                        child: Text(
                          checkoutState
                              .promoMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w600,
                            color: checkoutState
                                        .discountAmount >
                                    0
                                ? const Color(
                                    0xFF2E7D32,
                                  )
                                : const Color(
                                    0xFFE53935,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==================================
              // PAYMENT METHOD
              // ==================================

              const _SectionTitle(
                title: 'Payment method',
              ),

              const SizedBox(height: 6),

              const Text(
                'Choose how you want to pay.',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      Color(0xFF777777),
                ),
              ),

              const SizedBox(height: 14),

              _PaymentOption(
                title: 'Cash on delivery',
                subtitle:
                    'Pay when your order arrives',
                icon:
                    Icons.payments_outlined,
                selected:
                    checkoutState
                            .paymentMethod ==
                        PaymentMethod.cash,
                onTap: () {
                  ref
                      .read(
                        checkoutProvider.notifier,
                      )
                      .selectPaymentMethod(
                        PaymentMethod.cash,
                      );
                },
              ),

              const SizedBox(height: 12),

              _PaymentOption(
                title:
                    'Credit / Debit Card',
                subtitle:
                    'Pay securely using your card',
                icon:
                    Icons.credit_card_rounded,
                selected:
                    checkoutState
                            .paymentMethod ==
                        PaymentMethod.card,
                onTap: () {
                  ref
                      .read(
                        checkoutProvider.notifier,
                      )
                      .selectPaymentMethod(
                        PaymentMethod.card,
                      );
                },
              ),

              const SizedBox(height: 12),

              _PaymentOption(
                title: 'Qebox Wallet',
                subtitle:
                    'Use your Qebox wallet balance',
                icon: Icons
                    .account_balance_wallet_outlined,
                selected:
                    checkoutState
                            .paymentMethod ==
                        PaymentMethod.wallet,
                onTap: () {
                  ref
                      .read(
                        checkoutProvider.notifier,
                      )
                      .selectPaymentMethod(
                        PaymentMethod.wallet,
                      );
                },
              ),

              const SizedBox(height: 28),

              // ==================================
              // ORDER NOTES
              // ==================================

              const _SectionTitle(
                title: 'Order notes',
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child:
                    orderNote.trim().isEmpty
                        ? const Row(
                            children: [
                              Icon(
                                Icons.notes_rounded,
                                color:
                                    Color(0xFF999999),
                              ),

                              SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  'No order notes added',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        Color(0xFF777777),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.notes_rounded,
                                color:
                                    Color(0xFFEE7424),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Expanded(
                                child: Text(
                                  orderNote,
                                  style:
                                      const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color:
                                        Color(0xFF171717),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),

              const SizedBox(height: 28),

              // ==================================
              // ORDER SUMMARY
              // ==================================

              const _SectionTitle(
                title: 'Order summary',
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      title: 'Subtotal',
                      value:
                          'EGP ${subtotal.toStringAsFixed(2)}',
                    ),

                    if (discount > 0) ...[
                      const SizedBox(
                        height: 12,
                      ),

                      _SummaryRow(
                        title: 'Discount',
                        value:
                            '- EGP ${discount.toStringAsFixed(2)}',
                        isDiscount: true,
                      ),
                    ],

                    const SizedBox(height: 12),

                    const _SummaryRow(
                      title: 'Delivery fee',
                      value: 'EGP 20.00',
                    ),

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      child: Divider(
                        height: 1,
                      ),
                    ),

                    _SummaryRow(
                      title: 'Total',
                      value:
                          'EGP ${total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ========================================
      // PLACE ORDER
      // ========================================

      bottomNavigationBar: SafeArea(
        child: Container(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            18,
          ),
          decoration:
              const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color:
                    Color(0x14000000),
                blurRadius: 15,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              if (selectedAddress == null)
                const Padding(
                  padding:
                      EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Text(
                    'Please choose a delivery address',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          Color(0xFFE53935),
                    ),
                  ),
                )
              else if (!deliverySchedule
                  .isComplete)
                const Padding(
                  padding:
                      EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Text(
                    'Please choose a delivery time',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          Color(0xFFE53935),
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      canPlaceOrder
                          ? () async {
                              await _handlePlaceOrder(
                                context: context,
                                cartItems:
                                    cartItems,
                                selectedAddress:
                                    selectedAddress,
                                deliverySchedule:
                                    deliverySchedule,
                                checkoutState:
                                    checkoutState,
                                orderNote:
                                    orderNote,
                                subtotal:
                                    subtotal,
                                discount:
                                    discount,
                                deliveryFee:
                                    deliveryFee,
                                total: total,
                              );
                            }
                          : null,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF171717,
                    ),
                    foregroundColor:
                        Colors.white,
                    disabledBackgroundColor:
                        const Color(
                      0xFFCCCCCC,
                    ),
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        28,
                      ),
                    ),
                  ),
                  child: Text(
                    'Place Order • EGP ${total.toStringAsFixed(2)}',
                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CUSTOMER CHECK + PLACE ORDER
  // ==========================================

  Future<void> _handlePlaceOrder({
    required BuildContext context,
    required List<CartItem> cartItems,
    required Address selectedAddress,
    required DeliveryScheduleState
        deliverySchedule,
    required CheckoutState checkoutState,
    required String orderNote,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
  }) async {
    var customer =
        ref.read(customerProvider).customer;

    if (customer == null) {
      final verified =
          await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) {
            return const AccountScreen(
              closeAfterAuthentication: true,
            );
          },
        ),
      );

      if (!mounted || verified != true) {
        return;
      }

      customer =
          ref.read(customerProvider).customer;
    }

    if (customer == null) {
      return;
    }

    _placeOrder(
      context: context,
      customer: customer,
      cartItems: cartItems,
      selectedAddress: selectedAddress,
      deliverySchedule: deliverySchedule,
      checkoutState: checkoutState,
      orderNote: orderNote,
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,
    );
  }

  // ==========================================
  // CREATE ORDER
  // ==========================================

  void _placeOrder({
    required BuildContext context,
    required Customer customer,
    required List<CartItem> cartItems,
    required Address selectedAddress,
    required DeliveryScheduleState
        deliverySchedule,
    required CheckoutState checkoutState,
    required String orderNote,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
  }) {
    final deliveryStart =
        deliverySchedule
            .deliveryStartDateTime;

    final deliveryEnd =
        deliverySchedule
            .deliveryEndDateTime;

    if (deliveryStart == null ||
        deliveryEnd == null ||
        cartItems.isEmpty) {
      return;
    }

    final now = DateTime.now();

    final order = CustomerOrder(
      id:
          'QB-${now.millisecondsSinceEpoch}',

      customerId:
          customer.id,

      customerName:
          customer.name,

      customerPhone:
          customer.phone,

      items: cartItems.map(
        (cartItem) {
          return OrderItem(
            productId:
                cartItem.product.id,
            productName:
                cartItem.product.name,
            price:
                cartItem.product.price,
            quantity:
                cartItem.quantity,
            imageUrl:
                cartItem.product.imageUrl,
          );
        },
      ).toList(),

      addressLabel:
          selectedAddress.label,

      addressLine:
          selectedAddress.addressLine,

      building:
          selectedAddress.building,

      floor:
          selectedAddress.floor,

      apartment:
          selectedAddress.apartment,

      landmark:
          selectedAddress.landmark,

      deliveryStart:
          deliveryStart,

      deliveryEnd:
          deliveryEnd,

      paymentMethod:
          _mapPaymentMethod(
        checkoutState.paymentMethod,
      ),

      orderNote:
          orderNote.trim().isEmpty
              ? null
              : orderNote.trim(),

      promoCode:
          checkoutState
                  .promoCode.isEmpty
              ? null
              : checkoutState
                  .promoCode,

      subtotal: subtotal,

      discount: discount,

      deliveryFee:
          deliveryFee,

      total: total,

      // كل الطلبات حاليًا مرتبطة بموعد توصيل
      status:
          OrderStatus.scheduled,

      createdAt: now,
    );

    // ==========================================
    // SAVE ORDER
    // ==========================================

    ref
        .read(
          ordersProvider.notifier,
        )
        .createOrder(order);

    // ==========================================
    // CLEAR CART
    // ==========================================

    ref
        .read(
          cartProvider.notifier,
        )
        .clearCart();

    // ==========================================
    // CLEAR ORDER NOTE
    // ==========================================

    ref
        .read(
          orderNoteProvider.notifier,
        )
        .state = '';

    // ==========================================
    // CLEAR DELIVERY TIME
    // ==========================================

    ref
        .read(
          deliveryScheduleProvider
              .notifier,
        )
        .clearSchedule();

    // ==========================================
    // CLEAR PROMO
    // ==========================================

    ref
        .read(
          checkoutProvider.notifier,
        )
        .removePromoCode();

    // ==========================================
    // ORDER CONFIRMED SCREEN
    // ==========================================

    Navigator.of(context)
        .pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return OrderConfirmedScreen(
            order: order,
          );
        },
      ),
    );
  }

  // ==========================================
  // PAYMENT CONVERSION
  // ==========================================

  OrderPaymentMethod _mapPaymentMethod(
    PaymentMethod method,
  ) {
    switch (method) {
      case PaymentMethod.cash:
        return OrderPaymentMethod.cash;

      case PaymentMethod.card:
        return OrderPaymentMethod.card;

      case PaymentMethod.wallet:
        return OrderPaymentMethod.wallet;
    }
  }

  // ==========================================
  // ADDRESS ICON
  // ==========================================

  IconData _getAddressIcon(
    String? label,
  ) {
    switch (
        label?.toLowerCase()) {
      case 'work':
        return Icons
            .work_outline_rounded;

      case 'other':
        return Icons.place_outlined;

      case 'home':
      default:
        return Icons
            .home_outlined;
    }
  }

  // ==========================================
  // ADDRESS DETAILS
  // ==========================================

  String _buildAddressDetails(
    Address address,
  ) {
    final parts = <String>[];

    if (address.building != null &&
        address.building!.isNotEmpty) {
      parts.add(
        'Building ${address.building}',
      );
    }

    if (address.floor != null &&
        address.floor!.isNotEmpty) {
      parts.add(
        'Floor ${address.floor}',
      );
    }

    if (address.apartment != null &&
        address.apartment!.isNotEmpty) {
      parts.add(
        'Apartment ${address.apartment}',
      );
    }

    return parts.join(' • ');
  }

  // ==========================================
  // DELIVERY DATE
  // ==========================================

  String _deliveryDateLabel(
    DeliveryScheduleState state,
  ) {
    final date =
        state.selectedDate;

    if (date == null) {
      return 'Choose delivery time';
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final tomorrow =
        today.add(
      const Duration(days: 1),
    );

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
    );

    if (_sameDate(
      selected,
      today,
    )) {
      return 'Today';
    }

    if (_sameDate(
      selected,
      tomorrow,
    )) {
      return 'Tomorrow';
    }

    return '${_weekdayName(date)}, '
        '${date.day} ${_monthName(date.month)}';
  }

  bool _sameDate(
    DateTime first,
    DateTime second,
  ) {
    return first.year ==
            second.year &&
        first.month ==
            second.month &&
        first.day ==
            second.day;
  }

  String _weekdayName(
    DateTime date,
  ) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return names[
        date.weekday - 1];
  }

  String _monthName(
    int month,
  ) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[
        month - 1];
  }
}

// ==============================================
// SECTION TITLE
// ==============================================

class _SectionTitle
    extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      title,
      style:
          const TextStyle(
        fontSize: 19,
        fontWeight:
            FontWeight.w800,
        color:
            Color(0xFF171717),
      ),
    );
  }
}

// ==============================================
// ICON CONTAINER
// ==============================================

class _ContainerIcon
    extends StatelessWidget {
  final IconData icon;

  const _ContainerIcon({
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color:
            const Color(
          0xFFFFE6D5,
        ),
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color:
            const Color(
          0xFFEE7424,
        ),
      ),
    );
  }
}

// ==============================================
// PAYMENT OPTION
// ==============================================

class _PaymentOption
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? const Color(
                    0xFFEE7424,
                  )
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            _ContainerIcon(
              icon: icon,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          Color(0xFF171717),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              selected
                  ? Icons
                      .check_circle_rounded
                  : Icons
                      .radio_button_unchecked_rounded,
              color: selected
                  ? const Color(
                      0xFFEE7424,
                    )
                  : const Color(
                      0xFFCCCCCC,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================
// SUMMARY ROW
// ==============================================

class _SummaryRow
    extends StatelessWidget {
  final String title;
  final String value;
  final bool isTotal;
  final bool isDiscount;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize:
                isTotal ? 17 : 14,
            fontWeight:
                isTotal
                    ? FontWeight.w800
                    : FontWeight.w500,
            color:
                isTotal
                    ? const Color(
                        0xFF171717,
                      )
                    : const Color(
                        0xFF777777,
                      ),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize:
                isTotal ? 18 : 14,
            fontWeight:
                FontWeight.w800,
            color:
                isDiscount
                    ? const Color(
                        0xFF2E7D32,
                      )
                    : isTotal
                        ? const Color(
                            0xFFEE7424,
                          )
                        : const Color(
                            0xFF171717,
                          ),
          ),
        ),
      ],
    );
  }
}