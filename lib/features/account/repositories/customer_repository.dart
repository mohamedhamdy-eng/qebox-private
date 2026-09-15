import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer.dart';

abstract interface class CustomerRepository {
  Customer? loadActiveCustomer();

  Map<String, Customer> loadRegisteredCustomers();

  void save({
    required Customer? activeCustomer,
    required Map<String, Customer> registeredCustomers,
  });
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
}
