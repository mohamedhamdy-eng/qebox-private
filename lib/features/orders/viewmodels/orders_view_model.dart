import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../repositories/orders_repository.dart';

class OrdersViewModel extends StateNotifier<List<CustomerOrder>> {
  OrdersViewModel(this._repository, String? customerId)
      : _customerId = customerId ?? '',
        super(_repository.loadOrders(customerId ?? ''));

  final OrdersRepository _repository;
  String _customerId;

  void _setOrders(List<CustomerOrder> orders) {
    state = orders;
    _repository.saveOrders(_customerId, orders);
  }

  void switchCustomer(String? customerId) {
    final nextCustomerId = customerId ?? '';
    if (_customerId == nextCustomerId) return;
    _customerId = nextCustomerId;
    state = _repository.loadOrders(_customerId);
  }

  void createOrder(CustomerOrder order) {
    _customerId = order.customerId;
    _setOrders([
      order,
      ...state,
    ]);
  }

  void updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) {
    _setOrders(state.map(
      (order) {
        if (order.id == orderId) {
          return order.copyWith(
            status: status,
          );
        }

        return order;
      },
    ).toList());
  }

  void cancelOrder(String orderId, String reason) {
    _setOrders(state.map((order) {
      if (order.id != orderId) return order;
      return order.copyWith(
        status: OrderStatus.cancelled,
        cancellationReason: reason,
      );
    }).toList());
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
    _setOrders([]);
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersViewModel, List<CustomerOrder>>(
  (ref) {
    throw UnimplementedError(
      'ordersProvider must be overridden with a repository in main.',
    );
  },
);
