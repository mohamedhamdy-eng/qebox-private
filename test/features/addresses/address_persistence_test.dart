import 'package:flutter_test/flutter_test.dart';
import 'package:qebox_private/features/addresses/models/address.dart';
import 'package:qebox_private/features/addresses/repositories/address_repository.dart';
import 'package:qebox_private/features/addresses/viewmodels/address_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
