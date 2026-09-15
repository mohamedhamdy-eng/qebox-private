import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address.dart';
import '../repositories/address_repository.dart';

class AddressState {
  final List<Address> addresses;
  final String? selectedAddressId;

  const AddressState({
    this.addresses = const [],
    this.selectedAddressId,
  });

  Address? get selectedAddress {
    if (addresses.isEmpty) {
      return null;
    }

    if (selectedAddressId != null) {
      for (final address in addresses) {
        if (address.id == selectedAddressId) {
          return address;
        }
      }
    }

    for (final address in addresses) {
      if (address.isDefault) {
        return address;
      }
    }

    return addresses.first;
  }

  AddressState copyWith({
    List<Address>? addresses,
    String? selectedAddressId,
    bool clearSelectedAddress = false,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedAddressId: clearSelectedAddress
          ? null
          : selectedAddressId ?? this.selectedAddressId,
    );
  }
}

class AddressViewModel extends StateNotifier<AddressState> {
  AddressViewModel(this._repository, String? customerId)
      : _ownerId = customerId ?? _guestOwnerId,
        super(_initialState(_repository, customerId ?? _guestOwnerId));

  static const _guestOwnerId = 'guest';
  final AddressRepository _repository;
  String _ownerId;

  static AddressState _initialState(
    AddressRepository repository,
    String ownerId,
  ) {
    final stored = repository.load(ownerId);
    if (stored != null) {
      return AddressState(
        addresses: stored.addresses,
        selectedAddressId: stored.selectedAddressId,
      );
    }

    return const AddressState(
      addresses: [
        Address(
          id: 'address_1',
          label: 'Home',
          addressLine: 'Smouha, Alexandria',
          building: '12',
          floor: '3',
          apartment: '8',
          isDefault: true,
        ),
      ],
      selectedAddressId: 'address_1',
    );
  }

  void _saveState() {
    _repository.save(
      _ownerId,
      StoredAddresses(
        addresses: state.addresses,
        selectedAddressId: state.selectedAddressId,
      ),
    );
  }

  void switchCustomer(String? customerId) {
    final nextOwnerId = customerId ?? _guestOwnerId;
    if (nextOwnerId == _ownerId) return;
    _ownerId = nextOwnerId;
    state = _initialState(_repository, _ownerId);
  }

  void addAddress(Address address) {
    var updatedAddresses = [
      ...state.addresses,
      address,
    ];

    if (address.isDefault) {
      updatedAddresses = updatedAddresses.map((item) {
        return item.copyWith(
          isDefault: item.id == address.id,
        );
      }).toList();
    }

    state = state.copyWith(
      addresses: updatedAddresses,
      selectedAddressId: state.selectedAddressId ?? address.id,
    );
    _saveState();
  }

  void updateAddress(Address updatedAddress) {
    var updatedAddresses = state.addresses.map((address) {
      if (address.id == updatedAddress.id) {
        return updatedAddress;
      }

      if (updatedAddress.isDefault) {
        return address.copyWith(
          isDefault: false,
        );
      }

      return address;
    }).toList();

    state = state.copyWith(
      addresses: updatedAddresses,
    );
    _saveState();
  }

  void removeAddress(String addressId) {
    final updatedAddresses = state.addresses
        .where(
          (address) => address.id != addressId,
        )
        .toList();

    String? newSelectedAddressId = state.selectedAddressId;

    if (newSelectedAddressId == addressId) {
      newSelectedAddressId =
          updatedAddresses.isEmpty ? null : updatedAddresses.first.id;
    }

    state = AddressState(
      addresses: updatedAddresses,
      selectedAddressId: newSelectedAddressId,
    );
    _saveState();
  }

  void selectAddress(String addressId) {
    final exists = state.addresses.any(
      (address) => address.id == addressId,
    );

    if (!exists) return;

    state = state.copyWith(
      selectedAddressId: addressId,
    );
    _saveState();
  }

  void setDefaultAddress(String addressId) {
    final updatedAddresses = state.addresses.map((address) {
      return address.copyWith(
        isDefault: address.id == addressId,
      );
    }).toList();

    state = state.copyWith(
      addresses: updatedAddresses,
      selectedAddressId: addressId,
    );
    _saveState();
  }
}

final addressProvider = StateNotifierProvider<AddressViewModel, AddressState>(
  (ref) {
    throw UnimplementedError(
      'addressProvider must be overridden with a repository in main.',
    );
  },
);
