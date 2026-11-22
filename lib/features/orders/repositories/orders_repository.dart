import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/l10n/app_language.dart';
import '../models/order.dart';

/// [message] is safe to show to the customer.
class OrderSubmissionException implements Exception {
  const OrderSubmissionException(this.message);

  final String message;
}

abstract interface class OrdersRepository {
  List<CustomerOrder> loadOrders(String customerId);

  void saveOrders(String customerId, List<CustomerOrder> orders);

  /// Throws [OrderSubmissionException] if the store does not accept the order.
  Future<void> publishOrder(CustomerOrder order);

  /// Throws [OrderSubmissionException] if the store does not cancel the order.
  Future<void> publishCancellation(String orderId, String reason);

  Stream<List<CustomerOrder>> watchRemoteOrders();
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
          .map((order) => CustomerOrder.fromJson(order as Map<String, dynamic>))
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

  @override
  Future<void> publishOrder(CustomerOrder order) async {}

  @override
  Future<void> publishCancellation(String orderId, String reason) async {}

  @override
  Stream<List<CustomerOrder>> watchRemoteOrders() => const Stream.empty();
}

class FirestoreOrdersRepository implements OrdersRepository {
  FirestoreOrdersRepository({
    required LocalOrdersRepository local,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseFunctions functions,
  }) : _local = local,
       _firestore = firestore,
       _auth = auth,
       _functions = functions;

  final LocalOrdersRepository _local;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  Future<void> _call(String name, Map<String, Object?> data) async {
    try {
      await _functions.httpsCallable(name).call<Object?>(data);
    } on FirebaseFunctionsException catch (error) {
      throw OrderSubmissionException(switch (error.code) {
        'failed-precondition' ||
        'invalid-argument' ||
        'already-exists' => _serverMessage(error),
        'unauthenticated' => tr('Please sign in again and try once more.'),
        _ => tr(_connectionError),
      });
    } on Exception {
      throw OrderSubmissionException(tr(_connectionError));
    }
  }

  String _serverMessage(FirebaseFunctionsException error) {
    final details = error.details;
    if (details is Map && details['template'] is String) {
      final args = details['args'];
      return tr(
        details['template'] as String,
        args is List ? args.cast<Object?>() : const [],
      );
    }
    return tr(error.message ?? 'Please review your order and try again.');
  }

  static const _connectionError =
      'Could not reach Qebox. Check your connection and try again.';

  @override
  List<CustomerOrder> loadOrders(String customerId) =>
      _local.loadOrders(customerId);

  @override
  void saveOrders(String customerId, List<CustomerOrder> orders) =>
      _local.saveOrders(customerId, orders);

  @override
  Future<void> publishOrder(CustomerOrder order) => _call('placeOrder', {
    'orderId': order.id,
    'items': order.items
        .map((item) => {'productId': item.productId, 'quantity': item.quantity})
        .toList(),
    'expectedTotal': order.total,
    'promoCode': order.promoCode,
    'customerReference': order.customerId,
    'customerName': order.customerName,
    'customerPhone': order.customerPhone,
    'paymentMethod': order.paymentMethod.name,
    'address': {
      'label': order.addressLabel,
      'line': order.addressLine,
      'building': order.building,
      'floor': order.floor,
      'apartment': order.apartment,
      'landmark': order.landmark,
    },
    'deliveryStart': order.deliveryStart.millisecondsSinceEpoch,
    'deliveryEnd': order.deliveryEnd.millisecondsSinceEpoch,
    'orderNote': order.orderNote,
    'substitutionPreference': order.substitutionPreference,
    'deliveryInstruction': order.deliveryInstruction,
  });

  @override
  Future<void> publishCancellation(String orderId, String reason) =>
      _call('cancelOrder', {'orderId': orderId, 'reason': reason});

  @override
  Stream<List<CustomerOrder>> watchRemoteOrders() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: user.uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(_fromDocument).toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  CustomerOrder _fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    final rawItems = data['items'];
    final rawAddress = data['addressSnapshot'];
    final address = rawAddress is Map ? rawAddress : const <String, dynamic>{};
    final status = switch (data['status']) {
      'Preparing' => OrderStatus.preparing,
      'Driver Assigned' => OrderStatus.driverAssigned,
      'Out For Delivery' => OrderStatus.outForDelivery,
      'Delivered' => OrderStatus.delivered,
      'Cancelled' => OrderStatus.cancelled,
      _ => OrderStatus.scheduled,
    };
    return CustomerOrder(
      id: (data['id'] ?? document.id) as String,
      customerId:
          (data['customerReference'] ?? data['customerId'] ?? '') as String,
      customerName: (data['customerName'] ?? '') as String,
      customerPhone: (data['customerPhone'] ?? '') as String,
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => OrderItem.fromJson(
                    item.map((key, value) => MapEntry('$key', value)),
                  ),
                )
                .toList()
          : const [],
      addressLabel: (address['label'] ?? data['branchName'] ?? '') as String,
      addressLine: (address['line'] ?? '') as String,
      building: address['building'] as String?,
      floor: address['floor'] as String?,
      apartment: address['apartment'] as String?,
      landmark: address['landmark'] as String?,
      deliveryStart:
          (data['deliveryStart'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryEnd:
          (data['deliveryEnd'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentMethod: OrderPaymentMethod.values.firstWhere(
        (method) => method.name == data['paymentMethod'],
        orElse: () => OrderPaymentMethod.cash,
      ),
      orderNote: data['orderNote'] as String?,
      promoCode: data['promoCode'] as String?,
      substitutionPreference:
          (data['substitutionPreference'] ?? 'contactMe') as String,
      deliveryInstruction:
          (data['deliveryInstruction'] ?? 'Call on arrival') as String,
      cancellationReason: data['cancellationReason'] as String?,
      subtotal: ((data['subtotal'] ?? 0) as num).toDouble(),
      discount: ((data['discount'] ?? 0) as num).toDouble(),
      deliveryFee: ((data['deliveryFee'] ?? 0) as num).toDouble(),
      total: ((data['totalAmount'] ?? 0) as num).toDouble(),
      status: status,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
