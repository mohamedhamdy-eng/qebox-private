import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../repositories/orders_repository.dart';
import '../viewmodels/orders_view_model.dart';
import '../../../core/l10n/app_language.dart';

part 'order_details_screen_sections.dart';
part 'order_details_screen_widgets.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final CustomerOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF171717)),
        ),
        title: Text(
          tr('Order details'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF171717),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._statusSection(statusStyle),
            ..._journeySection(),
            ..._customerSection(),
            ..._deliverySection(),
            ..._itemsSection(context),
            ..._paymentSection(),
            ..._notesSection(),
            ..._summarySection(),
          ],
        ),
      ),
      bottomNavigationBar:
          order.status == OrderStatus.placed ||
              order.status == OrderStatus.scheduled
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: OutlinedButton(
                  onPressed: () => _cancelOrder(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(tr('Cancel order')),
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _cancelOrder(BuildContext context, WidgetRef ref) async {
    const reasons = [
      'Changed my mind',
      'Ordered by mistake',
      'Delivery time is not suitable',
      'Need to change items or address',
      'Other',
    ];
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(tr('Why are you cancelling?')),
        children: reasons
            .map(
              (item) => SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(tr(item)),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (reason == null || !context.mounted) return;
    try {
      await ref.read(ordersProvider.notifier).cancelOrder(order.id, reason);
    } on OrderSubmissionException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  // =====================================================
  // ORDER JOURNEY LOGIC
  // =====================================================

  bool _isStepCompleted(OrderStatus current, OrderStatus step) {
    if (current == OrderStatus.cancelled) {
      return false;
    }

    return _statusIndex(current) >= _statusIndex(step);
  }

  int _statusIndex(OrderStatus status) {
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

  int _totalItems(CustomerOrder order) {
    return order.items.fold(0, (total, item) {
      return total + item.quantity;
    });
  }

  String _substitutionLabel(String preference) {
    switch (preference) {
      case 'replaceAutomatically':
        return tr('Replace automatically');
      case 'removeItem':
        return tr('Remove unavailable item');
      default:
        return tr('Contact me first');
    }
  }

  // =====================================================
  // ADDRESS
  // =====================================================

  String _addressText(CustomerOrder order) {
    final details = <String>[tr(order.addressLabel), order.addressLine];

    if (order.building != null && order.building!.isNotEmpty) {
      details.add(tr('Building {0}', [order.building]));
    }

    if (order.floor != null && order.floor!.isNotEmpty) {
      details.add(tr('Floor {0}', [order.floor]));
    }

    if (order.apartment != null && order.apartment!.isNotEmpty) {
      details.add(tr('Apartment {0}', [order.apartment]));
    }

    if (order.landmark != null && order.landmark!.isNotEmpty) {
      details.add(tr('Landmark: {0}', [order.landmark]));
    }

    return details.join('\n');
  }

  // =====================================================
  // DELIVERY
  // =====================================================

  String _deliveryText(CustomerOrder order) {
    return '${_dateText(order.deliveryStart)} • '
        '${_timeText(order.deliveryStart)} – '
        '${_timeText(order.deliveryEnd)}';
  }

  String _dateText(DateTime date) {
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

  String _timeText(DateTime date) {
    final period = date.hour >= 12 ? tr('PM') : tr('AM');

    var hour = date.hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:00 $period';
  }

  // =====================================================
  // PAYMENT
  // =====================================================

  String _paymentText(OrderPaymentMethod method) {
    switch (method) {
      case OrderPaymentMethod.cash:
        return tr('Cash on delivery');

      case OrderPaymentMethod.card:
        return tr('Credit / Debit Card');

      case OrderPaymentMethod.wallet:
        return tr('Qebox Wallet');
    }
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

  // =====================================================
  // STATUS
  // =====================================================

  _StatusStyle _getStatusStyle(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return _StatusStyle(
          label: tr('Order received'),
          backgroundColor: const Color(0xFFFFE6D5),
          textColor: const Color(0xFFEE7424),
        );

      case OrderStatus.scheduled:
        return _StatusStyle(
          label: tr('Scheduled'),
          backgroundColor: const Color(0xFFFFE6D5),
          textColor: const Color(0xFFEE7424),
        );

      case OrderStatus.preparing:
        return _StatusStyle(
          label: tr('Preparing'),
          backgroundColor: const Color(0xFFFFF4D6),
          textColor: const Color(0xFF9A6A00),
        );

      case OrderStatus.driverAssigned:
        return _StatusStyle(
          label: tr('Driver assigned'),
          backgroundColor: const Color(0xFFE8F0FF),
          textColor: const Color(0xFF315EAD),
        );

      case OrderStatus.outForDelivery:
        return _StatusStyle(
          label: tr('Out for delivery'),
          backgroundColor: const Color(0xFFE8F0FF),
          textColor: const Color(0xFF315EAD),
        );

      case OrderStatus.delivered:
        return _StatusStyle(
          label: tr('Delivered'),
          backgroundColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2E7D32),
        );

      case OrderStatus.cancelled:
        return _StatusStyle(
          label: tr('Cancelled'),
          backgroundColor: const Color(0xFFFFE8E8),
          textColor: const Color(0xFFE53935),
        );
    }
  }
}
