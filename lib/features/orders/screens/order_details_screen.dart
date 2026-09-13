import 'package:flutter/material.dart';

import '../models/order.dart';

class OrderDetailsScreen extends StatelessWidget {
  final CustomerOrder order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final statusStyle = _getStatusStyle(order.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F3),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF171717),
          ),
        ),
        title: const Text(
          'Order details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF171717),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // ORDER NUMBER + STATUS
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE6D5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Color(0xFFEE7424),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order number',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF777777),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF171717),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusStyle.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusStyle.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusStyle.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // ORDER JOURNEY
            // =====================================================

            const Text(
              'Order journey',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF171717),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Follow the progress of your order.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF777777),
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  _JourneyStep(
                    title: 'Order received',
                    completed: _isStepCompleted(
                      order.status,
                      OrderStatus.placed,
                    ),
                    current: order.status == OrderStatus.placed,
                    isLast: false,
                  ),
                  _JourneyStep(
                    title: 'Scheduled',
                    completed: _isStepCompleted(
                      order.status,
                      OrderStatus.scheduled,
                    ),
                    current: order.status == OrderStatus.scheduled,
                    isLast: false,
                  ),
                  _JourneyStep(
                    title: 'Preparing',
                    completed: _isStepCompleted(
                      order.status,
                      OrderStatus.preparing,
                    ),
                    current: order.status == OrderStatus.preparing,
                    isLast: false,
                  ),
                  _JourneyStep(
                    title: 'Driver assigned',
                    completed: _isStepCompleted(
                      order.status,
                      OrderStatus.driverAssigned,
                    ),
                    current:
                        order.status == OrderStatus.driverAssigned,
                    isLast: false,
                  ),
                  _JourneyStep(
                    title: 'Out for delivery',
                    completed: _isStepCompleted(
                      order.status,
                      OrderStatus.outForDelivery,
                    ),
                    current:
                        order.status == OrderStatus.outForDelivery,
                    isLast: false,
                  ),
                  _JourneyStep(
                    title: 'Delivered',
                    completed:
                        order.status == OrderStatus.delivered,
                    current:
                        order.status == OrderStatus.delivered,
                    isLast: true,
                  ),
                ],
              ),
            ),

            if (order.status == OrderStatus.cancelled) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      color: Color(0xFFE53935),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This order has been cancelled.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // =====================================================
            // CUSTOMER DETAILS
            // =====================================================

            const Text(
              'Customer details',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF171717),
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    title: 'Full name',
                    value: order.customerName.trim().isEmpty
                        ? 'Not available'
                        : order.customerName,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Divider(height: 1),
                  ),

                  _InfoRow(
                    icon: Icons.phone_outlined,
                    title: 'Mobile number',
                    value: order.customerPhone.trim().isEmpty
                        ? 'Not available'
                        : order.customerPhone,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Divider(height: 1),
                  ),

                  _InfoRow(
                    icon: Icons.badge_outlined,
                    title: 'Customer ID',
                    value: order.customerId.trim().isEmpty
                        ? 'Not available'
                        : order.customerId,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // DELIVERY
            // =====================================================

            const Text(
              'Delivery',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF171717),
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.schedule_outlined,
                    title: 'Delivery time',
                    value: _deliveryText(order),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Divider(height: 1),
                  ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    title: 'Delivery address',
                    value: _addressText(order),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // ITEMS
            // =====================================================

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF171717),
                  ),
                ),
                Text(
                  '${_totalItems(order)} items',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: List.generate(
                  order.items.length,
                  (index) {
                    final item = order.items[index];

                    return Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F1ED),
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              child: item.imageUrl != null &&
                                      item.imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      child: Image.network(
                                        item.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Icon(
                                            Icons
                                                .shopping_bag_outlined,
                                            color:
                                                Color(0xFFEE7424),
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: Color(0xFFEE7424),
                                    ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.w800,
                                      color: Color(0xFF171717),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Qty: ${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF777777),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'EGP ${item.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w800,
                                    color: Color(0xFF171717),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'EGP ${item.price.toStringAsFixed(2)} each',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        if (index != order.items.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            child: Divider(height: 1),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // PAYMENT
            // =====================================================

            const Text(
              'Payment',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF171717),
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: _InfoRow(
                icon: Icons.payments_outlined,
                title: 'Payment method',
                value: _paymentText(
                  order.paymentMethod,
                ),
              ),
            ),

            // =====================================================
            // ORDER NOTES
            // =====================================================

            if (order.orderNote != null &&
                order.orderNote!.trim().isNotEmpty) ...[
              const SizedBox(height: 24),

              const Text(
                'Order notes',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171717),
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.notes_rounded,
                      color: Color(0xFFEE7424),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        order.orderNote!,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: Color(0xFF171717),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // =====================================================
            // ORDER SUMMARY
            // =====================================================

            const Text(
              'Order summary',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF171717),
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    title: 'Subtotal',
                    value:
                        'EGP ${order.subtotal.toStringAsFixed(2)}',
                  ),

                  if (order.discount > 0) ...[
                    const SizedBox(height: 12),
                    _SummaryRow(
                      title: 'Discount',
                      value:
                          '- EGP ${order.discount.toStringAsFixed(2)}',
                      isDiscount: true,
                    ),
                  ],

                  const SizedBox(height: 12),

                  _SummaryRow(
                    title: 'Delivery fee',
                    value:
                        'EGP ${order.deliveryFee.toStringAsFixed(2)}',
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Divider(height: 1),
                  ),

                  _SummaryRow(
                    title: 'Total',
                    value:
                        'EGP ${order.total.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ORDER JOURNEY LOGIC
  // =====================================================

  static bool _isStepCompleted(
    OrderStatus current,
    OrderStatus step,
  ) {
    if (current == OrderStatus.cancelled) {
      return false;
    }

    return _statusIndex(current) >=
        _statusIndex(step);
  }

  static int _statusIndex(
    OrderStatus status,
  ) {
    switch (status) {
      case OrderStatus.placed:
        return 0;

      case OrderStatus.scheduled:
        return 1;

      case OrderStatus.preparing:
        return 2;

      case OrderStatus.driverAssigned:
        return 3;

      case OrderStatus.outForDelivery:
        return 4;

      case OrderStatus.delivered:
        return 5;

      case OrderStatus.cancelled:
        return -1;
    }
  }

  // =====================================================
  // TOTAL ITEMS
  // =====================================================

  static int _totalItems(
    CustomerOrder order,
  ) {
    return order.items.fold(
      0,
      (total, item) {
        return total + item.quantity;
      },
    );
  }

  // =====================================================
  // ADDRESS
  // =====================================================

  static String _addressText(
    CustomerOrder order,
  ) {
    final details = <String>[
      order.addressLabel,
      order.addressLine,
    ];

    if (order.building != null &&
        order.building!.isNotEmpty) {
      details.add(
        'Building ${order.building}',
      );
    }

    if (order.floor != null &&
        order.floor!.isNotEmpty) {
      details.add(
        'Floor ${order.floor}',
      );
    }

    if (order.apartment != null &&
        order.apartment!.isNotEmpty) {
      details.add(
        'Apartment ${order.apartment}',
      );
    }

    if (order.landmark != null &&
        order.landmark!.isNotEmpty) {
      details.add(
        'Landmark: ${order.landmark}',
      );
    }

    return details.join('\n');
  }

  // =====================================================
  // DELIVERY
  // =====================================================

  static String _deliveryText(
    CustomerOrder order,
  ) {
    return '${_dateText(order.deliveryStart)} • '
        '${_timeText(order.deliveryStart)} – '
        '${_timeText(order.deliveryEnd)}';
  }

  static String _dateText(
    DateTime date,
  ) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final tomorrow = today.add(
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

  static bool _sameDate(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static String _timeText(
    DateTime date,
  ) {
    final period =
        date.hour >= 12 ? 'PM' : 'AM';

    var hour = date.hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:00 $period';
  }

  // =====================================================
  // PAYMENT
  // =====================================================

  static String _paymentText(
    OrderPaymentMethod method,
  ) {
    switch (method) {
      case OrderPaymentMethod.cash:
        return 'Cash on delivery';

      case OrderPaymentMethod.card:
        return 'Credit / Debit Card';

      case OrderPaymentMethod.wallet:
        return 'Qebox Wallet';
    }
  }

  static String _weekdayName(
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

  static String _monthName(
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

  // =====================================================
  // STATUS
  // =====================================================

  static _StatusStyle _getStatusStyle(
    OrderStatus status,
  ) {
    switch (status) {
      case OrderStatus.placed:
        return const _StatusStyle(
          label: 'Order received',
          backgroundColor: Color(0xFFFFE6D5),
          textColor: Color(0xFFEE7424),
        );

      case OrderStatus.scheduled:
        return const _StatusStyle(
          label: 'Scheduled',
          backgroundColor: Color(0xFFFFE6D5),
          textColor: Color(0xFFEE7424),
        );

      case OrderStatus.preparing:
        return const _StatusStyle(
          label: 'Preparing',
          backgroundColor: Color(0xFFFFF4D6),
          textColor: Color(0xFF9A6A00),
        );

      case OrderStatus.driverAssigned:
        return const _StatusStyle(
          label: 'Driver assigned',
          backgroundColor: Color(0xFFE8F0FF),
          textColor: Color(0xFF315EAD),
        );

      case OrderStatus.outForDelivery:
        return const _StatusStyle(
          label: 'Out for delivery',
          backgroundColor: Color(0xFFE8F0FF),
          textColor: Color(0xFF315EAD),
        );

      case OrderStatus.delivered:
        return const _StatusStyle(
          label: 'Delivered',
          backgroundColor: Color(0xFFE8F5E9),
          textColor: Color(0xFF2E7D32),
        );

      case OrderStatus.cancelled:
        return const _StatusStyle(
          label: 'Cancelled',
          backgroundColor: Color(0xFFFFE8E8),
          textColor: Color(0xFFE53935),
        );
    }
  }
}

// =====================================================
// JOURNEY STEP
// =====================================================

class _JourneyStep extends StatelessWidget {
  final String title;
  final bool completed;
  final bool current;
  final bool isLast;

  const _JourneyStep({
    required this.title,
    required this.completed,
    required this.current,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final active = completed || current;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFEE7424)
                      : const Color(0xFFE5E5E5),
                  shape: BoxShape.circle,
                ),
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: Colors.white,
                      )
                    : current
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration:
                                  const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
              ),

              if (!isLast)
                Container(
                  width: 2,
                  height: 34,
                  color: active
                      ? const Color(0xFFEE7424)
                      : const Color(0xFFE5E5E5),
                ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 2,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: current
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: active
                    ? const Color(0xFF171717)
                    : const Color(0xFF999999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// INFO ROW
// =====================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE6D5),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            size: 21,
            color: const Color(0xFFEE7424),
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF777777),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171717),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =====================================================
// SUMMARY ROW
// =====================================================

class _SummaryRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 17 : 13,
            fontWeight: isTotal
                ? FontWeight.w800
                : FontWeight.w500,
            color: isTotal
                ? const Color(0xFF171717)
                : const Color(0xFF777777),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 13,
            fontWeight: FontWeight.w800,
            color: isDiscount
                ? const Color(0xFF2E7D32)
                : isTotal
                    ? const Color(0xFFEE7424)
                    : const Color(0xFF171717),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// STATUS STYLE
// =====================================================

class _StatusStyle {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatusStyle({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}