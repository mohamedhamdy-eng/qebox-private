import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../repositories/orders_repository.dart';

class OrdersViewModel extends StateNotifier<List<CustomerOrder>> {
  OrdersViewModel(this._repository, String? customerId)
      : _customerId = customerId ?? '',
        super(_repository.loadOrders(customerId ?? '')) {
    _listenForRemoteOrders();
  }

  final OrdersRepository _repository;
  String _customerId;
  StreamSubscription<List<CustomerOrder>>? _remoteOrdersSubscription;

  void _listenForRemoteOrders() {
    _remoteOrdersSubscription?.cancel();
    _remoteOrdersSubscription =
        _repository.watchRemoteOrders().listen((orders) {
      state = orders;
      _repository.saveOrders(_customerId, orders);
    });
  }

  void _setOrders(List<CustomerOrder> orders) {
    state = orders;
    _repository.saveOrders(_customerId, orders);
  }

  void switchCustomer(String? customerId) {
    final nextCustomerId = customerId ?? '';
    if (_customerId == nextCustomerId) return;
    _customerId = nextCustomerId;
    state = _repository.loadOrders(_customerId);
    _listenForRemoteOrders();
  }

  void createOrder(CustomerOrder order) {
    _customerId = order.customerId;
    _setOrders([
      order,
      ...state,
    ]);
    unawaited(
      _repository
          .publishOrder(order)
          .catchError((Object error, StackTrace stack) {
        // The local order must remain available even when the remote service is
        // temporarily unavailable. A later sync can publish it again.
      }),
    );
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

  @override
  void dispose() {
    _remoteOrdersSubscription?.cancel();
    super.dispose();
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
