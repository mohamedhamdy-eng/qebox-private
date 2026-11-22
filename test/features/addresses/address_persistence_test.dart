import 'package:flutter_test/flutter_test.dart';
import 'package:qebox_private/features/addresses/models/address.dart';
import 'package:qebox_private/features/addresses/repositories/address_repository.dart';
import 'package:qebox_private/features/addresses/viewmodels/address_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a new customer has no placeholder address', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    final viewModel = AddressViewModel(
      LocalAddressRepository(preferences),
      'new-customer',
    );

    expect(viewModel.state.addresses, isEmpty);
    expect(viewModel.state.selectedAddress, isNull);
  });

  test('restores account addresses on a new device', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const address = Address(id: 'a1', label: 'Home', addressLine: 'Alexandria');

    final viewModel = AddressViewModel(
      _RemoteAddresses(
        LocalAddressRepository(preferences),
        const StoredAddresses(addresses: [address], selectedAddressId: 'a1'),
      ),
      'customer-a',
    );
    await pumpEventQueue();

    expect(viewModel.state.selectedAddress?.id, 'a1');
  });

  test('keeps addresses isolated between customers', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final viewModel = AddressViewModel(
      LocalAddressRepository(preferences),
      'customer-a',
    );
    const address = Address(
      id: 'work-a',
      label: 'Work',
      addressLine: 'Customer A address',
    );

    viewModel.addAddress(address);
    viewModel.switchCustomer('customer-b');

    expect(
      viewModel.state.addresses.any((item) => item.id == address.id),
      isFalse,
    );

    viewModel.switchCustomer('customer-a');
    expect(
      viewModel.state.addresses.any((item) => item.id == address.id),
      isTrue,
    );
  });
}

class _RemoteAddresses implements AddressRepository {
  _RemoteAddresses(this._local, this._remote);

  final LocalAddressRepository _local;
  final StoredAddresses _remote;

  @override
  StoredAddresses? load(String ownerId) => _local.load(ownerId);

  @override
  void save(String ownerId, StoredAddresses data) => _local.save(ownerId, data);

  @override
  Future<StoredAddresses?> fetchRemote() async => _remote;

  @override
  void saveRemote(StoredAddresses data) {}
}
