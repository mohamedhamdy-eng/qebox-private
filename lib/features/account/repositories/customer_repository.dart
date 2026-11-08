import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer.dart';

abstract interface class CustomerRepository {
  Customer? loadActiveCustomer();

  Map<String, Customer> loadRegisteredCustomers();

  void save({
    required Customer? activeCustomer,
    required Map<String, Customer> registeredCustomers,
  });

  /// Returns the account name, or null if the account has no saved profile.
  Future<String?> fetchRemoteName();

  void saveRemoteProfile(Customer customer);
}

class LocalCustomerRepository implements CustomerRepository {
  LocalCustomerRepository(this._preferences);

  static const _activeCustomerKey = 'active_customer';
  static const _registeredCustomersKey = 'registered_customers';

  final SharedPreferences _preferences;

  @override
  Customer? loadActiveCustomer() {
    final value = _preferences.getString(_activeCustomerKey);
    if (value == null) return null;

    try {
      return Customer.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Map<String, Customer> loadRegisteredCustomers() {
    final value = _preferences.getString(_registeredCustomersKey);
    if (value == null) return {};

    try {
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      return decoded.map(
        (phone, customer) => MapEntry(
          phone,
          Customer.fromJson(customer as Map<String, dynamic>),
        ),
      );
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  @override
  void save({
    required Customer? activeCustomer,
    required Map<String, Customer> registeredCustomers,
  }) {
    final encodedCustomers = registeredCustomers.map(
      (phone, customer) => MapEntry(phone, customer.toJson()),
    );
    unawaited(
      _preferences.setString(
        _registeredCustomersKey,
        jsonEncode(encodedCustomers),
      ),
    );

    if (activeCustomer == null) {
      unawaited(_preferences.remove(_activeCustomerKey));
    } else {
      unawaited(
        _preferences.setString(
          _activeCustomerKey,
          jsonEncode(activeCustomer.toJson()),
        ),
      );
    }
  }

  @override
  Future<String?> fetchRemoteName() async => null;

  @override
  void saveRemoteProfile(Customer customer) {}
}

class FirestoreCustomerRepository implements CustomerRepository {
  FirestoreCustomerRepository({
    required LocalCustomerRepository local,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _local = local,
       _firestore = firestore,
       _auth = auth;

  final LocalCustomerRepository _local;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Customer? loadActiveCustomer() => _local.loadActiveCustomer();

  @override
  Map<String, Customer> loadRegisteredCustomers() =>
      _local.loadRegisteredCustomers();

  @override
  void save({
    required Customer? activeCustomer,
    required Map<String, Customer> registeredCustomers,
  }) => _local.save(
    activeCustomer: activeCustomer,
    registeredCustomers: registeredCustomers,
  );

  @override
  Future<String?> fetchRemoteName() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final snapshot = await _firestore.collection('customers').doc(uid).get();
    return snapshot.data()?['name'] as String?;
  }

  @override
  void saveRemoteProfile(Customer customer) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    unawaited(
      _firestore
          .collection('customers')
          .doc(uid)
          .set({
            'name': customer.name,
            'phone': customer.phone,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .catchError(
            (Object error) => debugPrint('Profile sync failed: $error'),
          ),
    );
  }
}
