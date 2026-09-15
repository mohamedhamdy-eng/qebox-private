import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/order.dart';

abstract interface class OrdersRepository {
  List<CustomerOrder> loadOrders(String customerId);

  void saveOrders(String customerId, List<CustomerOrder> orders);
}

class LocalOrdersRepository implements OrdersRepository {
  LocalOrdersRepository(this._preferences);

  static const _prefix = 'orders_';
  final SharedPreferences _preferences;

  @override
  List<CustomerOrder> loadOrders(String customerId) {
    if (customerId.isEmpty) return [];
    final value = _preferences.getString('$_prefix$customerId');
    if (value == null) return [];

    try {
      final decoded = jsonDecode(value) as List<dynamic>;
      return decoded
          .map(
            (order) => CustomerOrder.fromJson(
              order as Map<String, dynamic>,
            ),
          )
          .toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  @override
  void saveOrders(String customerId, List<CustomerOrder> orders) {
    if (customerId.isEmpty) return;
    unawaited(
      _preferences.setString(
        '$_prefix$customerId',
        jsonEncode(orders.map((order) => order.toJson()).toList()),
      ),
    );
  }
}
