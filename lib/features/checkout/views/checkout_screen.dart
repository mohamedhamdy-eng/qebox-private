import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/models/customer.dart';
import '../../account/viewmodels/customer_view_model.dart';
import '../../account/views/account_screen.dart';

import '../../addresses/models/address.dart';
import '../../addresses/viewmodels/address_view_model.dart';
import '../../addresses/views/address_selection_screen.dart';

import '../../cart/models/cart_item.dart';
import '../../cart/viewmodels/cart_view_model.dart';
import '../../cart/viewmodels/order_note_view_model.dart';

import '../../orders/models/order.dart';
import '../../orders/repositories/orders_repository.dart';
import '../../orders/viewmodels/orders_view_model.dart';
import '../../orders/views/order_confirmed_screen.dart';

import '../viewmodels/checkout_view_model.dart';
import '../viewmodels/delivery_schedule_view_model.dart';
import 'delivery_schedule_screen.dart';
import '../../../core/l10n/app_language.dart';

part 'checkout_screen_sections.dart';
part 'checkout_screen_pricing.dart';
part 'checkout_screen_widgets.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController _promoController = TextEditingController();
  bool _isPlacingOrder = false;
  String? _pendingOrderId;
  String? _pendingCartSignature;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

    final addressState = ref.watch(addressProvider);

    final orderNote = ref.watch(orderNoteProvider);

    final checkoutState = ref.watch(checkoutProvider);

    final deliverySchedule = ref.watch(deliveryScheduleProvider);

    final selectedAddress = addressState.selectedAddress;

    // ==========================================
    // PRICES
    // ==========================================

    final subtotal = cartItems.fold<double>(
      0,
      (total, item) => total + item.totalPrice,
    );

    // مؤقتًا
    // بعدين تيجي من الـ Backend / Dashboard
    const double deliveryFee = 20.0;

    final discount = checkoutState.discountFor(subtotal);

    final promoMessage = checkoutState.promoMessageFor(subtotal);

    final total = subtotal - discount + deliveryFee;

    // ==========================================
    // PLACE ORDER VALIDATION
    // ==========================================

    final canPlaceOrder =
        cartItems.isNotEmpty &&
        selectedAddress != null &&
        deliverySchedule.isComplete;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),

      // ========================================
      // APP BAR
      // ========================================
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F3),
        elevation: 0,
        centerTitle: true,
        title: Text(
          tr('Checkout'),
          style: const TextStyle(
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
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._deliveryAddressSection(checkoutState, selectedAddress),
              ..._deliveryTimeSection(deliverySchedule),
              ..._promoSection(checkoutState, subtotal, discount, promoMessage),
              ..._paymentSection(checkoutState),
              ..._orderNotesSection(orderNote),
              ..._orderSummarySection(subtotal, discount, total),
            ],
          ),
        ),
      ),

      // ========================================
      // PLACE ORDER
      // ========================================
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 15,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedAddress == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    tr('Please choose a delivery address'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFE53935),
                    ),
                  ),
                )
              else if (!deliverySchedule.isComplete)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    tr('Please choose a delivery time'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: canPlaceOrder && !_isPlacingOrder
                      ? () async {
                          await _handlePlaceOrder(
                            context: context,
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
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF171717),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCCCCCC),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    _isPlacingOrder
                        ? tr('Placing order...')
                        : tr('Place Order • EGP {0}', [
                            total.toStringAsFixed(2),
                          ]),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
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
    required DeliveryScheduleState deliverySchedule,
    required CheckoutState checkoutState,
    required String orderNote,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
  }) async {
    var customer = ref.read(customerProvider).customer;

    if (customer == null) {
      final verified = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) {
            return const AccountScreen(closeAfterAuthentication: true);
          },
        ),
      );

      if (!context.mounted || verified != true) {
        return;
      }

      customer = ref.read(customerProvider).customer;
    }

    if (customer == null) {
      return;
    }

    await _placeOrder(
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

  /// A retry of the same cart reuses the order number. The server then returns
  /// the first order if only its response was lost.
  String _orderIdFor(String cartSignature, DateTime now) {
    if (_pendingOrderId != null && _pendingCartSignature == cartSignature) {
      return _pendingOrderId!;
    }
    final random = Random.secure();
    final suffix = List.generate(
      4,
      (_) => random.nextInt(16).toRadixString(16),
    ).join().toUpperCase();
    _pendingCartSignature = cartSignature;
    return _pendingOrderId = 'QB-${now.millisecondsSinceEpoch}-$suffix';
  }

  Future<void> _placeOrder({
    required BuildContext context,
    required Customer customer,
    required List<CartItem> cartItems,
    required Address selectedAddress,
    required DeliveryScheduleState deliverySchedule,
    required CheckoutState checkoutState,
    required String orderNote,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
  }) async {
    final deliveryStart = deliverySchedule.deliveryStartDateTime;

    final deliveryEnd = deliverySchedule.deliveryEndDateTime;

    if (deliveryStart == null || deliveryEnd == null || cartItems.isEmpty) {
      return;
    }

    final now = DateTime.now();

    final cartSignature = [
      ...cartItems.map((item) => '${item.product.id}:${item.quantity}'),
      total,
      checkoutState.promoCode,
    ].join('|');

    final order = CustomerOrder(
      id: _orderIdFor(cartSignature, now),

      customerId: customer.id,

      customerName: customer.name,

      customerPhone: customer.phone,

      items: cartItems.map((cartItem) {
        return OrderItem(
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          price: cartItem.product.price,
          quantity: cartItem.quantity,
          imageUrl: cartItem.product.imageUrl,
        );
      }).toList(),

      addressLabel: selectedAddress.label,

      addressLine: selectedAddress.addressLine,

      building: selectedAddress.building,

      floor: selectedAddress.floor,

      apartment: selectedAddress.apartment,

      landmark: selectedAddress.landmark,

      deliveryStart: deliveryStart,

      deliveryEnd: deliveryEnd,

      paymentMethod: _mapPaymentMethod(checkoutState.paymentMethod),

      orderNote: orderNote.trim().isEmpty ? null : orderNote.trim(),

      promoCode: checkoutState.promoCode.isEmpty
          ? null
          : checkoutState.promoCode,

      substitutionPreference: checkoutState.substitutionPreference.name,
      deliveryInstruction: checkoutState.deliveryInstruction,
      subtotal: subtotal,

      discount: discount,

      deliveryFee: deliveryFee,

      total: total,

      // كل الطلبات حاليًا مرتبطة بموعد توصيل
      status: OrderStatus.scheduled,

      createdAt: now,
    );

    // ==========================================
    // SAVE ORDER
    // ==========================================

    setState(() => _isPlacingOrder = true);
    try {
      await ref.read(ordersProvider.notifier).createOrder(order);
    } on OrderSubmissionException catch (error) {
      if (!context.mounted) return;
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }
    if (!context.mounted) return;
    _isPlacingOrder = false;
    _pendingOrderId = null;

    // ==========================================
    // CLEAR CART
    // ==========================================

    ref.read(cartProvider.notifier).clearCart();

    // ==========================================
    // CLEAR ORDER NOTE
    // ==========================================

    ref.read(orderNoteProvider.notifier).clear();

    // ==========================================
    // CLEAR DELIVERY TIME
    // ==========================================

    ref.read(deliveryScheduleProvider.notifier).clearSchedule();

    // ==========================================
    // CLEAR PROMO
    // ==========================================

    ref.read(checkoutProvider.notifier).resetOrderPreferences();

    // ==========================================
    // ORDER CONFIRMED SCREEN
    // ==========================================

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return OrderConfirmedScreen(order: order);
        },
      ),
    );
  }

  // ==========================================
  // PAYMENT CONVERSION
  // ==========================================

  OrderPaymentMethod _mapPaymentMethod(PaymentMethod method) {
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

  IconData _getAddressIcon(String? label) {
    switch (label?.toLowerCase()) {
      case 'work':
        return Icons.work_outline_rounded;

      case 'other':
        return Icons.place_outlined;

      case 'home':
      default:
        return Icons.home_outlined;
    }
  }

  // ==========================================
  // ADDRESS DETAILS
  // ==========================================

  String _buildAddressDetails(Address address) {
    final parts = <String>[];

    if (address.building != null && address.building!.isNotEmpty) {
      parts.add(tr('Building {0}', [address.building]));
    }

    if (address.floor != null && address.floor!.isNotEmpty) {
      parts.add(tr('Floor {0}', [address.floor]));
    }

    if (address.apartment != null && address.apartment!.isNotEmpty) {
      parts.add(tr('Apartment {0}', [address.apartment]));
    }

    return parts.join(' • ');
  }

  // ==========================================
  // DELIVERY DATE
  // ==========================================

  String _deliveryDateLabel(DeliveryScheduleState state) {
    final date = state.selectedDate;

    if (date == null) {
      return tr('Choose delivery time');
    }

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final tomorrow = today.add(const Duration(days: 1));

    final selected = DateTime(date.year, date.month, date.day);

    if (_sameDate(selected, today)) {
      return tr('Today');
    }

    if (_sameDate(selected, tomorrow)) {
      return tr('Tomorrow');
    }

    return '${_weekdayName(date)}, '
        '${date.day} ${_monthName(date.month)}';
  }

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _weekdayName(DateTime date) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return tr(names[date.weekday - 1]);
  }

  String _monthName(int month) {
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

    return tr(months[month - 1]);
  }
}
