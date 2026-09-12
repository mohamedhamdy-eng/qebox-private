import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';

class OrdersNotifier
    extends StateNotifier<List<CustomerOrder>> {
  OrdersNotifier() : super([]);

  void createOrder(CustomerOrder order) {
    state = [
      order,
      ...state,
    ];
  }

  void updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) {
    state = state.map(
      (order) {
        if (order.id == orderId) {
          return order.copyWith(
            status: status,
          );
        }

        return order;
      },
    ).toList();
  }

  CustomerOrder? getOrderById(
    String orderId,
  ) {
    for (final order in state) {
      if (order.id == orderId) {
        return order;
      }
    }

    return null;
  }

  void clearOrders() {
    state = [];
  }
}

final ordersProvider =
    StateNotifierProvider<
        OrdersNotifier,
        List<CustomerOrder>>(
  (ref) {
    return OrdersNotifier();
  },
);