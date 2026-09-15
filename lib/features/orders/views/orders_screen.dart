import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../viewmodels/orders_view_model.dart';
import 'order_details_screen.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    final activeOrders = orders.where((order) {
      return order.status != OrderStatus.delivered &&
          order.status != OrderStatus.cancelled;
    }).toList();

    final previousOrders = orders.where((order) {
      return order.status == OrderStatus.delivered ||
          order.status == OrderStatus.cancelled;
    }).toList();

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
          'Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF171717),
          ),
        ),
      ),
      body: orders.isEmpty
          ? const _EmptyOrders()
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                30,
              ),
              children: [
                // =========================================
                // ACTIVE ORDERS
                // =========================================

                if (activeOrders.isNotEmpty) ...[
                  const Text(
                    'Active orders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Track your current orders and delivery status.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF777777),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...activeOrders.map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                      ),
                      child: _OrderCard(
                        order: order,
                      ),
                    ),
                  ),
                ],

                // =========================================
                // SPACE BETWEEN SECTIONS
                // =========================================

                if (activeOrders.isNotEmpty && previousOrders.isNotEmpty)
                  const SizedBox(height: 20),

                // =========================================
                // PREVIOUS ORDERS
                // =========================================

                if (previousOrders.isNotEmpty) ...[
                  const Text(
                    'Previous orders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your delivered and cancelled orders.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF777777),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...previousOrders.map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                      ),
                      child: _OrderCard(
                        order: order,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

// =====================================================
// ORDER CARD
// =====================================================

class _OrderCard extends StatelessWidget {
  final CustomerOrder order;

  const _OrderCard({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final status = _getStatus(
      order.status,
    );

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return OrderDetailsScreen(
                order: order,
              );
            },
          ),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =============================================
            // ORDER ID + STATUS
            // =============================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE6D5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: Color(0xFFEE7424),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF777777),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        order.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF171717),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: status.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: status.textColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(
              height: 1,
            ),

            const SizedBox(height: 18),

            // =============================================
            // DELIVERY TIME
            // =============================================

            Row(
              children: [
                const Icon(
                  Icons.schedule_outlined,
                  size: 19,
                  color: Color(0xFF777777),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _deliveryText(order),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF171717),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =============================================
            // ADDRESS
            // =============================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 19,
                  color: Color(0xFF777777),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '${order.addressLabel} • ${order.addressLine}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF777777),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // =============================================
            // ITEMS + TOTAL
            // =============================================

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_totalItems(order)} items',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'EGP ${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFEE7424),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFF999999),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // TOTAL ITEMS
  // =============================================

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

  // =============================================
  // DELIVERY TEXT
  // =============================================

  static String _deliveryText(
    CustomerOrder order,
  ) {
    return '${_dateText(order.deliveryStart)} • '
        '${_timeText(order.deliveryStart)} – '
        '${_timeText(order.deliveryEnd)}';
  }

  // =============================================
  // DATE TEXT
  // =============================================

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

    return '${date.day} ${_monthName(date.month)}';
  }

  static bool _sameDate(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  // =============================================
  // TIME TEXT
  // =============================================

  static String _timeText(
    DateTime date,
  ) {
    final period = date.hour >= 12 ? 'PM' : 'AM';

    var hour = date.hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:00 $period';
  }

  // =============================================
  // MONTH TEXT
  // =============================================

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

    return months[month - 1];
  }

  // =============================================
  // STATUS STYLE
  // =============================================

  static _StatusStyle _getStatus(
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
// STATUS STYLE MODEL
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

// =====================================================
// EMPTY ORDERS
// =====================================================

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 90,
              color: Color(0xFFCCCCCC),
            ),
            SizedBox(height: 20),
            Text(
              'No orders yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF171717),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your orders will appear here after you place them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF777777),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
