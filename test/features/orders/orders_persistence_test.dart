import 'package:flutter_test/flutter_test.dart';
import 'package:qebox_private/features/orders/models/order.dart';
import 'package:qebox_private/features/orders/repositories/orders_repository.dart';
import 'package:qebox_private/features/orders/viewmodels/orders_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restores order history only for the owning customer', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final now = DateTime(2026, 9, 13, 12);
    final order = CustomerOrder(
      id: 'QB-1',
      customerId: 'customer-a',
      customerName: 'Mohamed',
      customerPhone: '01000000000',
      items: const [
        OrderItem(
          productId: 'milk',
          productName: 'Fresh Milk',
          price: 65,
          quantity: 2,
        ),
      ],
      addressLabel: 'Home',
      addressLine: 'Alexandria',
      deliveryStart: now,
      deliveryEnd: now.add(const Duration(hours: 2)),
      paymentMethod: OrderPaymentMethod.cash,
      substitutionPreference: 'removeItem',
      deliveryInstruction: 'Leave at the door',
      subtotal: 130,
      discount: 0,
      deliveryFee: 20,
      total: 150,
      createdAt: now,
    );

    final firstViewModel = OrdersViewModel(
      LocalOrdersRepository(preferences),
      'customer-a',
    );
    firstViewModel.createOrder(order);

    final restoredViewModel = OrdersViewModel(
      LocalOrdersRepository(preferences),
      'customer-a',
    );
    expect(restoredViewModel.state, hasLength(1));
    expect(restoredViewModel.state.single.id, order.id);
    expect(restoredViewModel.state.single.substitutionPreference, 'removeItem');
    expect(restoredViewModel.state.single.deliveryInstruction,
        'Leave at the door');
    restoredViewModel.cancelOrder(order.id, 'Changed my mind');
    expect(restoredViewModel.state.single.status, OrderStatus.cancelled);
    expect(
        restoredViewModel.state.single.cancellationReason, 'Changed my mind');

    restoredViewModel.switchCustomer('customer-b');
    expect(restoredViewModel.state, isEmpty);

    restoredViewModel.switchCustomer('customer-a');
    expect(restoredViewModel.state.single.id, order.id);
  });
}
