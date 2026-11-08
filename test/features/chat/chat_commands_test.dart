import 'package:flutter_test/flutter_test.dart';
import 'package:qebox_private/features/cart/models/cart_item.dart';
import 'package:qebox_private/features/chat/repositories/chat_repository.dart';
import 'package:qebox_private/features/chat/viewmodels/chat_view_model.dart';
import 'package:qebox_private/features/products/models/product.dart';

class _Assistant implements ChatRepository {
  int calls = 0;

  @override
  Future<String> sendMessage(String message) async {
    calls++;
    return 'assistant answer';
  }
}

const _milk = Product(
  id: 'milk',
  name: 'Fresh Milk',
  nameAr: 'لبن',
  description: 'Fresh dairy milk for your family',
  price: 65,
  categoryId: 'dairy',
  stockQuantity: 25,
);
const _chocolateMilk = Product(
  id: 'chocolate-milk',
  name: 'Chocolate Milk',
  price: 40,
  categoryId: 'dairy',
  stockQuantity: 5,
);

void main() {
  late _Assistant assistant;
  late List<String> added;
  late List<String> removed;

  ChatViewModel build({
    List<Product> products = const [_milk],
    List<CartItem> cart = const [],
  }) {
    assistant = _Assistant();
    added = [];
    removed = [];
    return ChatViewModel(
      assistant,
      products: () => products,
      cartItems: () => cart,
      addProduct: (product) => added.add(product.id),
      removeProduct: removed.add,
    );
  }

  test('does not add a product from words in its description', () async {
    final viewModel = build();

    await viewModel.send('I want help with my family delivery');

    expect(added, isEmpty);
    expect(assistant.calls, 1);
  });

  test('does not treat "address" as an add command', () async {
    final viewModel = build();

    await viewModel.send('change my address');

    expect(added, isEmpty);
    expect(assistant.calls, 1);
  });

  test('understands Arabic with hamza and taa marbuta', () async {
    final viewModel = build();

    await viewModel.send('أضف لبن');
    expect(added, ['milk']);

    final cartViewModel = build(cart: const [CartItem(product: _milk)]);
    await cartViewModel.send('السلة');
    expect(assistant.calls, 0);
    expect(cartViewModel.state.messages.last.text, contains('Fresh Milk'));
  });

  test('understands Arabic digits and the attached article', () async {
    final viewModel = build();

    await viewModel.send('ضيف ٢ اللبن');

    expect(added, ['milk', 'milk']);
  });

  test('adds a partial name only after an explicit request', () async {
    final viewModel = build();

    await viewModel.send('add 2 milk');
    expect(added, ['milk', 'milk']);

    final softViewModel = build();
    await softViewModel.send('I need milk');
    expect(added, isEmpty);
    expect(softViewModel.state.messages.last.text, contains('Did you mean'));
  });

  test('asks when a partial name matches several products', () async {
    final viewModel = build(products: const [_milk, _chocolateMilk]);

    await viewModel.send('add milk');

    expect(added, isEmpty);
    expect(viewModel.state.messages.last.text, contains('Chocolate Milk'));
  });

  test('reports only the quantity that fits the stock limit', () async {
    final viewModel = build(
      products: const [_chocolateMilk],
      cart: const [CartItem(product: _chocolateMilk, quantity: 3)],
    );

    await viewModel.send('add 10 chocolate milk');

    expect(added, hasLength(2));
    expect(viewModel.state.messages.last.text, contains('2 × Chocolate Milk'));
  });

  test('reports when the cart already has the maximum', () async {
    final viewModel = build(
      products: const [_chocolateMilk],
      cart: const [CartItem(product: _chocolateMilk, quantity: 5)],
    );

    await viewModel.send('add chocolate milk');

    expect(added, isEmpty);
    expect(viewModel.state.messages.last.text, contains('maximum'));
  });

  test('handles product names with special characters', () async {
    const special = Product(
      id: 'special',
      name: 'Milk-1L (2%)',
      price: 10,
      categoryId: 'dairy',
      stockQuantity: 3,
    );
    final viewModel = build(products: const [special]);

    await viewModel.send('add milk-1l (2%)');

    expect(added, ['special']);
    expect(viewModel.state.isTyping, isFalse);
  });
}
