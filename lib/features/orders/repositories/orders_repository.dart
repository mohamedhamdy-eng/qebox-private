import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order.dart';

abstract interface class OrdersRepository {
  List<CustomerOrder> loadOrders(String customerId);

  void saveOrders(String customerId, List<CustomerOrder> orders);

  Future<void> publishOrder(CustomerOrder order);

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

  @override
  Future<void> publishOrder(CustomerOrder order) async {}

  @override
  Stream<List<CustomerOrder>> watchRemoteOrders() => const Stream.empty();
}

class FirestoreOrdersRepository implements OrdersRepository {
  FirestoreOrdersRepository({
    required LocalOrdersRepository local,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _local = local,
        _firestore = firestore,
        _auth = auth;

  final LocalOrdersRepository _local;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  List<CustomerOrder> loadOrders(String customerId) =>
      _local.loadOrders(customerId);

  @override
  void saveOrders(String customerId, List<CustomerOrder> orders) =>
      _local.saveOrders(customerId, orders);

  @override
  Future<void> publishOrder(CustomerOrder order) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('A Development Firebase session is required.');
    }
    await _firestore.collection('orders').doc(order.id).set({
      'id': order.id,
      'customerId': user.uid,
      'customerReference': order.customerId,
      'customerName': order.customerName,
      'customerPhone': order.customerPhone,
      'items': order.items.map((item) => item.toJson()).toList(),
      'itemCount': order.items
          .fold<int>(0, (runningTotal, item) => runningTotal + item.quantity),
      'branchName': order.addressLabel,
      'totalAmount': order.total,
      'subtotal': order.subtotal,
      'discount': order.discount,
      'deliveryFee': order.deliveryFee,
      'paymentMethod': order.paymentMethod.name,
      'status': 'Pending',
      'addressSnapshot': {
        'label': order.addressLabel,
        'line': order.addressLine,
        'building': order.building,
        'floor': order.floor,
        'apartment': order.apartment,
        'landmark': order.landmark,
      },
      'deliveryStart': Timestamp.fromDate(order.deliveryStart),
      'deliveryEnd': Timestamp.fromDate(order.deliveryEnd),
      'orderNote': order.orderNote,
      'promoCode': order.promoCode,
      'substitutionPreference': order.substitutionPreference,
      'deliveryInstruction': order.deliveryInstruction,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<CustomerOrder>> watchRemoteOrders() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDocument).toList());
  }

  CustomerOrder _fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    final rawItems = data['items'];
    final rawAddress = data['addressSnapshot'];
    final address = rawAddress is Map ? rawAddress : const <String, dynamic>{};
    final status = switch (data['status']) {
      'Preparing' => OrderStatus.preparing,
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
              .map((item) => OrderItem.fromJson(
                  item.map((key, value) => MapEntry('$key', value))))
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
      subtotal: ((data['subtotal'] ?? 0) as num).toDouble(),
      discount: ((data['discount'] ?? 0) as num).toDouble(),
      deliveryFee: ((data['deliveryFee'] ?? 0) as num).toDouble(),
      total: ((data['totalAmount'] ?? 0) as num).toDouble(),
      status: status,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
