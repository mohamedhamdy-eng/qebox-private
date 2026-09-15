import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/viewmodels/cart_view_model.dart';
import '../../products/data/product_catalog.dart';
import '../../products/models/product.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';

class ChatState {
  const ChatState({required this.messages, this.isTyping = false});

  final List<ChatMessage> messages;
  final bool isTyping;

  ChatState copyWith({List<ChatMessage>? messages, bool? isTyping}) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatViewModel extends StateNotifier<ChatState> {
  ChatViewModel(
    this._repository, {
    List<Product> products = ProductCatalog.allProducts,
    void Function(Product product)? addProduct,
  })  : _products = products,
        _addProduct = addProduct,
        super(
          ChatState(
            messages: [
              ChatMessage(
                id: 'welcome',
                role: ChatRole.assistant,
                text:
                    'Hi! I’m Q Bot, your Qebox AI assistant. How can I help you today?',
                createdAt: DateTime.now(),
              ),
            ],
          ),
        );

  final ChatRepository _repository;
  final List<Product> _products;
  final void Function(Product product)? _addProduct;

  Future<void> send(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || state.isTyping) return;
    final now = DateTime.now();
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          id: 'user-${now.microsecondsSinceEpoch}',
          role: ChatRole.user,
          text: cleanText,
          createdAt: now,
        ),
      ],
      isTyping: true,
    );

    final commandReply = _handleCartCommand(cleanText);
    if (commandReply != null) {
      _addAssistantMessage(commandReply);
      return;
    }

    try {
      final reply = await _repository.sendMessage(cleanText);
      final replyTime = DateTime.now();
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            id: 'bot-${replyTime.microsecondsSinceEpoch}',
            role: ChatRole.assistant,
            text: reply,
            createdAt: replyTime,
          ),
        ],
        isTyping: false,
      );
    } catch (_) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            id: 'error-${DateTime.now().microsecondsSinceEpoch}',
            role: ChatRole.assistant,
            text: 'I could not answer right now. Please try again.',
            createdAt: DateTime.now(),
          ),
        ],
        isTyping: false,
      );
    }
  }

  String? _handleCartCommand(String message) {
    final normalized = message.toLowerCase();
    final isAddCommand = RegExp(r'\b(add|put|place)\b').hasMatch(normalized) &&
        normalized.contains('cart');
    if (!isAddCommand) return null;

    Product? match;
    var bestScore = 0;
    for (final product in _products) {
      final name = product.name.toLowerCase();
      final tokens = name
          .split(RegExp(r'\s+'))
          .where((token) => token.length > 2)
          .toList();
      final score = normalized.contains(name)
          ? 100
          : tokens.where(normalized.contains).length;
      if (score > bestScore) {
        bestScore = score;
        match = product;
      }
    }

    if (match == null || bestScore == 0) {
      final names = _products.take(6).map((product) => product.name).join(', ');
      return 'I could not find that product. Try one of these: $names.';
    }
    if (_addProduct == null) {
      return 'Cart actions are not available right now.';
    }
    if (!match.isActive || !match.inStock) {
      return '${match.name} is currently out of stock.';
    }

    final quantityMatch = RegExp(r'\b(\d+)\b').firstMatch(normalized);
    final requested = int.tryParse(quantityMatch?.group(1) ?? '1') ?? 1;
    final quantity = requested.clamp(1, 20);
    for (var index = 0; index < quantity; index++) {
      _addProduct(match);
    }
    return quantity == 1
        ? '${match.name} was added to your cart.'
        : '$quantity × ${match.name} were added to your cart.';
  }

  void _addAssistantMessage(String text) {
    final now = DateTime.now();
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          id: 'bot-${now.microsecondsSinceEpoch}',
          role: ChatRole.assistant,
          text: text,
          createdAt: now,
        ),
      ],
      isTyping: false,
    );
  }
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) {
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    const model = String.fromEnvironment(
      'GEMINI_MODEL',
      defaultValue: 'gemini-2.5-flash',
    );
    if (apiKey.isEmpty) return const LocalQBotRepository();
    return GeminiQBotRepository(apiKey: apiKey, model: model);
  },
);

final chatProvider = StateNotifierProvider<ChatViewModel, ChatState>(
  (ref) => ChatViewModel(
    ref.watch(chatRepositoryProvider),
    addProduct: ref.read(cartProvider.notifier).addProduct,
  ),
);
