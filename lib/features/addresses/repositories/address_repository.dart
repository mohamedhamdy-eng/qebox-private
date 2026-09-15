import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';

class StoredAddresses {
  const StoredAddresses({
    required this.addresses,
    this.selectedAddressId,
  });

  final List<Address> addresses;
  final String? selectedAddressId;
}

abstract interface class AddressRepository {
  StoredAddresses? load(String ownerId);

  void save(String ownerId, StoredAddresses data);
}

class LocalAddressRepository implements AddressRepository {
  LocalAddressRepository(this._preferences);

  static const _prefix = 'addresses_';
  final SharedPreferences _preferences;

  @override
  StoredAddresses? load(String ownerId) {
    final value = _preferences.getString('$_prefix$ownerId');
    if (value == null) return null;

    try {
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      final addresses = (decoded['addresses'] as List<dynamic>)
          .map((item) => Address.fromJson(item as Map<String, dynamic>))
          .toList();
      return StoredAddresses(
        addresses: addresses,
        selectedAddressId: decoded['selected_address_id']?.toString(),
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  void save(String ownerId, StoredAddresses data) {
    unawaited(
      _preferences.setString(
        '$_prefix$ownerId',
        jsonEncode({
          'addresses': data.addresses.map((item) => item.toJson()).toList(),
          'selected_address_id': data.selectedAddressId,
        }),
      ),
    );
  }
}
