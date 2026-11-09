import 'package:flutter/material.dart';

import '../../home/views/home_screen.dart';
import '../models/order.dart';
import '../../../core/l10n/app_language.dart';

class OrderConfirmedScreen extends StatelessWidget {
  final CustomerOrder order;

  const OrderConfirmedScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
          child: Column(
            children: [
              // =========================================
              // SUCCESS ICON
              // =========================================
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE6D5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 50,
                  color: Color(0xFFEE7424),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                tr('Order confirmed!'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF171717),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                tr('Your order has been received successfully.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF777777),
                ),
              ),

              const SizedBox(height: 28),

              // =========================================
              // ORDER NUMBER
              // =========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      tr('Order number'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.id,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF171717),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // =========================================
              // SCHEDULED STATUS
              // =========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4EC),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE6D5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.schedule_rounded,
                        color: Color(0xFFEE7424),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('Scheduled delivery'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF171717),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _deliveryDateText(order),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEE7424),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            tr(
                              'We will prepare your order based on your selected delivery time. Live tracking will start when your delivery begins.',
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.5,
                              color: Color(0xFF777777),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // =========================================
              // ORDER DETAILS
              // =========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      title: tr('Customer'),
                      value: _customerText(order),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      title: tr('Delivery address'),
                      value: '${tr(order.addressLabel)}\n${order.addressLine}',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),
                    _InfoRow(
                      icon: Icons.payments_outlined,
                      title: tr('Payment'),
                      value: _paymentText(order.paymentMethod),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),
                    _InfoRow(
                      icon: Icons.shopping_bag_outlined,
                      title: tr('Items'),
                      value: tr('{0} items', [_totalItems(order)]),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),
                    _InfoRow(
                      icon: Icons.receipt_long_outlined,
                      title: tr('Total'),
                      value: tr('EGP {0}', [order.total.toStringAsFixed(2)]),
                      highlight: true,
                    ),
                  ],
                ),
              ),

              // =========================================
              // ORDER NOTES
              // =========================================
              if (order.orderNote != null &&
                  order.orderNote!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
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
                      const Icon(Icons.notes_rounded, color: Color(0xFFEE7424)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('Order notes'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF171717),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              order.orderNote!,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF777777),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // =========================================
              // CONTINUE SHOPPING
              // =========================================
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) {
                          return const HomeScreen();
                        },
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF171717),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    tr('Continue shopping'),
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

  // ===========================================
  // CUSTOMER TEXT
  // ===========================================

  static String _customerText(CustomerOrder order) {
    final lines = <String>[];

    if (order.customerName.trim().isNotEmpty) {
      lines.add(order.customerName.trim());
    }

    if (order.customerPhone.trim().isNotEmpty) {
      lines.add(order.customerPhone.trim());
    }

    if (order.customerId.trim().isNotEmpty) {
      lines.add(tr('ID: {0}', [order.customerId.trim()]));
    }

    if (lines.isEmpty) {
      return tr('Customer information not available');
    }

    return lines.join('\n');
  }

  // ===========================================
  // TOTAL ITEMS
  // ===========================================

  static int _totalItems(CustomerOrder order) {
    return order.items.fold(0, (total, item) => total + item.quantity);
  }

  // ===========================================
  // PAYMENT TEXT
  // ===========================================

  static String _paymentText(OrderPaymentMethod method) {
    switch (method) {
      case OrderPaymentMethod.cash:
        return tr('Cash on delivery');

      case OrderPaymentMethod.card:
        return tr('Credit / Debit Card');

      case OrderPaymentMethod.wallet:
        return tr('Qebox Wallet');
    }
  }

  // ===========================================
  // DELIVERY DATE
  // ===========================================

  static String _deliveryDateText(CustomerOrder order) {
    final date = order.deliveryStart;

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final tomorrow = today.add(const Duration(days: 1));

    final selected = DateTime(date.year, date.month, date.day);

    String dayText;

    if (_sameDate(selected, today)) {
      dayText = tr('Today');
    } else if (_sameDate(selected, tomorrow)) {
      dayText = tr('Tomorrow');
    } else {
      dayText = '${_weekdayName(date)}, ${date.day} ${_monthName(date.month)}';
    }

    return '$dayText • '
        '${_formatTime(order.deliveryStart)} – '
        '${_formatTime(order.deliveryEnd)}';
  }

  static bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static String _formatTime(DateTime date) {
    final period = date.hour >= 12 ? tr('PM') : tr('AM');

    var hour = date.hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:00 $period';
  }

  static String _weekdayName(DateTime date) {
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

  static String _monthName(int month) {
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

// =============================================
// INFO ROW
// =============================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool highlight;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.highlight = false,
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
          child: Icon(icon, size: 21, color: const Color(0xFFEE7424)),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Color(0xFF777777)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: highlight ? 16 : 13,
                  height: 1.4,
                  fontWeight: highlight ? FontWeight.w900 : FontWeight.w700,
                  color: highlight
                      ? const Color(0xFFEE7424)
                      : const Color(0xFF171717),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
