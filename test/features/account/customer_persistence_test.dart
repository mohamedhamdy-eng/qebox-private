import 'package:flutter_test/flutter_test.dart';
import 'package:qebox_private/features/account/repositories/customer_repository.dart';
import 'package:qebox_private/features/account/viewmodels/customer_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restores the active customer after an app restart', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    final firstViewModel = CustomerViewModel(
      LocalCustomerRepository(preferences),
    );
    final customer = firstViewModel.signUp(
      name: 'Mohamed',
      phone: '01000000000',
    );

    final restoredViewModel = CustomerViewModel(
      LocalCustomerRepository(preferences),
    );

    expect(restoredViewModel.state.customer, isNotNull);
    expect(restoredViewModel.state.customer?.id, customer?.id);
    expect(restoredViewModel.state.customer?.phone, '01000000000');
  });
}
