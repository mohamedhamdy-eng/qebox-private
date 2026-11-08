import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';

class StoredAddresses {
  const StoredAddresses({required this.addresses, this.selectedAddressId});

  final List<Address> addresses;
  final String? selectedAddressId;
}

abstract interface class AddressRepository {
  StoredAddresses? load(String ownerId);

  void save(String ownerId, StoredAddresses data);

  /// Returns the addresses of the account, or null if it has none.
  Future<StoredAddresses?> fetchRemote();

  void saveRemote(StoredAddresses data);
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

  @override
  Future<StoredAddresses?> fetchRemote() async => null;

  @override
  void saveRemote(StoredAddresses data) {}
}

class FirestoreAddressRepository implements AddressRepository {
  FirestoreAddressRepository({
    required LocalAddressRepository local,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _local = local,
       _firestore = firestore,
       _auth = auth;

  final LocalAddressRepository _local;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  StoredAddresses? load(String ownerId) => _local.load(ownerId);

  @override
  void save(String ownerId, StoredAddresses data) => _local.save(ownerId, data);

  @override
  Future<StoredAddresses?> fetchRemote() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final customer = _firestore.collection('customers').doc(uid);
    final addresses = await customer.collection('addresses').get();
    if (addresses.docs.isEmpty) return null;
    final profile = await customer.get();
    return StoredAddresses(
      addresses: addresses.docs
          .map((doc) => Address.fromJson(doc.data()))
          .toList(),
      selectedAddressId: profile.data()?['selectedAddressId'] as String?,
    );
  }

  @override
  void saveRemote(StoredAddresses data) {
    unawaited(
      _replaceRemote(
        data,
      ).catchError((Object error) => debugPrint('Address sync failed: $error')),
    );
  }

  Future<void> _replaceRemote(StoredAddresses data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final customer = _firestore.collection('customers').doc(uid);
    final collection = customer.collection('addresses');
    final existing = await collection.get();
    final keptIds = data.addresses.map((address) => address.id).toSet();
    final batch = _firestore.batch();
    for (final doc in existing.docs) {
      if (!keptIds.contains(doc.id)) batch.delete(doc.reference);
    }
    for (final address in data.addresses) {
      batch.set(collection.doc(address.id), address.toJson());
    }
    batch.set(customer, {
      'selectedAddressId': data.selectedAddressId,
    }, SetOptions(merge: true));
    await batch.commit();
  }
}
