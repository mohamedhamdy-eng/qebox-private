import 'package:flutter_test/flutter_test.dart';
import 'package:qebox_private/features/chat/models/chat_message.dart';
import 'package:qebox_private/features/chat/repositories/chat_repository.dart';
import 'package:qebox_private/features/chat/viewmodels/chat_view_model.dart';
import 'package:qebox_private/features/products/data/product_catalog.dart';

void main() {
  test('Q Bot sends a customer message and returns a support answer', () async {
    final viewModel = ChatViewModel(const LocalQBotRepository());

    await viewModel.send('How can I track my order?');

    expect(viewModel.state.isTyping, isFalse);
    expect(viewModel.state.messages, hasLength(3));
    expect(viewModel.state.messages[1].role, ChatRole.user);
    expect(viewModel.state.messages.last.role, ChatRole.assistant);
    expect(viewModel.state.messages.last.text, contains('My Orders'));
  });

  test(
    'Q Bot executes add-to-cart commands against the real catalog',
    () async {
      final added = <String>[];
      final viewModel = ChatViewModel(
        const LocalQBotRepository(),
        addProduct: (product) => added.add(product.id),
      );

      await viewModel.send('Add 2 fresh milk to my cart');

      expect(added, [
        ProductCatalog.popularProducts.first.id,
        ProductCatalog.popularProducts.first.id,
      ]);
      expect(viewModel.state.messages.last.text, contains('2 × Fresh Milk'));
    },
  );
}
