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
    await firstViewModel.createOrder(order);

    final restoredViewModel = OrdersViewModel(
      LocalOrdersRepository(preferences),
      'customer-a',
    );
    expect(restoredViewModel.state, hasLength(1));
    expect(restoredViewModel.state.single.id, order.id);
    expect(restoredViewModel.state.single.substitutionPreference, 'removeItem');
    expect(
      restoredViewModel.state.single.deliveryInstruction,
      'Leave at the door',
    );
    await restoredViewModel.cancelOrder(order.id, 'Changed my mind');
    expect(restoredViewModel.state.single.status, OrderStatus.cancelled);
    expect(
      restoredViewModel.state.single.cancellationReason,
      'Changed my mind',
    );

    restoredViewModel.switchCustomer('customer-b');
    expect(restoredViewModel.state, isEmpty);

    restoredViewModel.switchCustomer('customer-a');
    expect(restoredViewModel.state.single.id, order.id);
  });

  group('when the store rejects a change', () {
    final now = DateTime(2026, 9, 13, 12);
    final order = CustomerOrder(
      id: 'QB-1',
      customerId: 'customer-a',
      items: const [],
      addressLabel: 'Home',
      addressLine: 'Alexandria',
      deliveryStart: now,
      deliveryEnd: now,
      paymentMethod: OrderPaymentMethod.cash,
      subtotal: 0,
      discount: 0,
      deliveryFee: 20,
      total: 20,
      createdAt: now,
    );

    test('a rejected order is not saved and the error propagates', () async {
      final viewModel = OrdersViewModel(_RejectingOrders(), 'customer-a');

      await expectLater(
        viewModel.createOrder(order),
        throwsA(isA<OrderSubmissionException>()),
      );
      expect(viewModel.state, isEmpty);
    });

    test('a rejected cancellation keeps the order active', () async {
      final repository = _RejectingOrders()..saved = [order];
      final viewModel = OrdersViewModel(repository, 'customer-a');

      await expectLater(
        viewModel.cancelOrder(order.id, 'Changed my mind'),
        throwsA(isA<OrderSubmissionException>()),
      );
      expect(viewModel.state.single.status, isNot(OrderStatus.cancelled));
    });
  });
}

class _RejectingOrders implements OrdersRepository {
  List<CustomerOrder> saved = [];

  @override
  List<CustomerOrder> loadOrders(String customerId) => saved;

  @override
  void saveOrders(String customerId, List<CustomerOrder> orders) {}

  @override
  Future<void> publishOrder(CustomerOrder order) async =>
      throw const OrderSubmissionException('Rejected');

  @override
  Future<void> publishCancellation(String orderId, String reason) async =>
      throw const OrderSubmissionException('Rejected');

  @override
  Stream<List<CustomerOrder>> watchRemoteOrders() => const Stream.empty();
}
