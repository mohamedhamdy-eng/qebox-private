import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/models/cart_item.dart';
import '../../cart/viewmodels/cart_view_model.dart';
import '../../orders/models/order.dart';
import '../../orders/viewmodels/orders_view_model.dart';
import '../../products/data/product_catalog.dart';
import '../../products/models/product.dart';
import '../../products/viewmodels/catalog_view_model.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';

class ChatState {
  const ChatState({required this.messages, this.isTyping = false});
  final List<ChatMessage> messages;
  final bool isTyping;
  ChatState copyWith({List<ChatMessage>? messages, bool? isTyping}) =>
      ChatState(
          messages: messages ?? this.messages,
          isTyping: isTyping ?? this.isTyping);
}

class ChatViewModel extends StateNotifier<ChatState> {
  ChatViewModel(
    this._repository, {
    List<Product> Function()? products,
    List<CustomerOrder> Function()? orders,
    List<CartItem> Function()? cartItems,
    void Function(Product product)? addProduct,
    void Function(String productId)? removeProduct,
  })  : _products = products ?? _fallbackProducts,
        _orders = orders ?? _noOrders,
        _cartItems = cartItems ?? _noCartItems,
        _addProduct = addProduct,
        _removeProduct = removeProduct,
        super(ChatState(messages: [
          ChatMessage(
            id: 'welcome',
            role: ChatRole.assistant,
            text:
                'Hi! I am Q Bot. I understand Arabic and English. Tell me what you need and I will prepare your cart.',
            createdAt: DateTime.now(),
          ),
        ]));

  final ChatRepository _repository;
  final List<Product> Function() _products;
  final List<CustomerOrder> Function() _orders;
  final List<CartItem> Function() _cartItems;
  final void Function(Product product)? _addProduct;
  final void Function(String productId)? _removeProduct;

  static List<Product> _fallbackProducts() => ProductCatalog.allProducts;
  static List<CustomerOrder> _noOrders() => const [];
  static List<CartItem> _noCartItems() => const [];

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
            createdAt: now)
      ],
      isTyping: true,
    );
    final reply = _handleCommand(cleanText);
    if (reply != null) {
      _addAssistantMessage(reply);
      return;
    }
    try {
      _addAssistantMessage(await _repository.sendMessage(cleanText));
    } catch (_) {
      _addAssistantMessage(
          'I could not answer right now. Please try again in a moment.');
    }
  }

  String? _handleCommand(String source) {
    final message = _normalize(source);
    if (_containsAny(message, _trackingTerms)) return _latestOrderReply();
    if (_containsAny(message, _removeTerms)) return _removeFromCart(message);
    if (_containsAny(message, _cartTerms) &&
        !_containsAny(message, _addTerms)) {
      return _cartSummaryReply();
    }
    if (_containsAny(message, _recommendTerms)) return _recommendProducts();
    if (_containsAny(message, _productQuestionTerms)) {
      final products = _findProducts(message, _products());
      if (products.isNotEmpty) return _productDetailsReply(products);
    }
    if (!_containsAny(message, _addTerms)) return null;

    final catalog = _products();
    final matches = _findProducts(message, catalog);
    if (matches.isEmpty) {
      if (_containsAny(message, _genericOrderTerms)) {
        return _hasArabic(source)
            ? 'تمام. اكتب المنتجات والكميات التي تريدها، مثلاً: ضيف ٢ لبن و١ خبز. سأجهز السلة ثم تختار التوصيل والدفع من Checkout.'
            : 'Great. Tell me the products and quantities you want. Example: add 2 milk and 1 bread. I will prepare the cart, then you confirm delivery and payment in Checkout.';
      }
      if (RegExp(r'^(?:i )?(?:need|want)\s*\d*\s*$').hasMatch(message)) {
        return 'Tell me the product name after the quantity. For example: “I need 2 bread”.';
      }
      final names = catalog.take(5).map((product) => product.name).join(', ');
      return 'I did not find a product name in your message. Try: $names.';
    }
    if (_addProduct == null) {
      return 'Cart actions are temporarily unavailable. Please try again.';
    }

    final added = <String>[];
    final unavailable = <Product>[];
    for (final product in matches) {
      if (!product.isActive || !product.inStock) {
        unavailable.add(product);
        continue;
      }
      final quantity = _requestedQuantity(message, product);
      for (var i = 0; i < quantity; i++) {
        _addProduct(product);
      }
      added.add(
          quantity == 1 ? product.name : '$quantity \u00d7 ${product.name}');
    }
    final lines = <String>[];
    if (added.isNotEmpty) lines.add('Added ${added.join(', ')} to your cart.');
    if (unavailable.isNotEmpty) {
      lines.add(
          'Unavailable: ${unavailable.map((product) => product.name).join(', ')}.');
      final alternatives = _alternativesFor(unavailable);
      if (alternatives.isNotEmpty) {
        lines.add('Try instead: ${alternatives.join(', ')}.');
      }
    }
    lines.add(
        'Open Cart, then Checkout to choose delivery details and confirm your order.');
    return lines.join('\n');
  }

  List<Product> _findProducts(String message, List<Product> products) {
    final exact = products.where((product) {
      final names = [product.name, product.nameAr]
          .whereType<String>()
          .map(_normalize)
          .where((name) => name.length > 1);
      return names.any(message.contains);
    }).toList();
    if (exact.isNotEmpty) return exact;

    Product? best;
    var score = 0;
    for (final product in products) {
      final words = _normalize([
        product.name,
        product.nameAr,
        product.description
      ].whereType<String>().join(' '))
          .split(RegExp(r'\s+'))
          .where((word) => word.length > 2);
      final candidateScore = words.where(message.contains).length;
      if (candidateScore > score) {
        score = candidateScore;
        best = product;
      }
    }
    return score == 0 ? const [] : [best!];
  }

  int _requestedQuantity(String message, Product product) {
    for (final name in [product.name, product.nameAr].whereType<String>()) {
      final match = RegExp(
              '(\\d+)\\s*(?:x)?\\s*${RegExp.escape(_normalize(name))}',
              caseSensitive: false)
          .firstMatch(message);
      final number = int.tryParse(match?.group(1) ?? '');
      if (number != null) {
        return number.clamp(
            1, product.maxQuantityPerOrder ?? product.stockQuantity);
      }
    }
    return 1;
  }

  String _removeFromCart(String message) {
    if (_removeProduct == null) {
      return 'Cart actions are temporarily unavailable. Please try again.';
    }
    final items = _cartItems();
    final matches =
        _findProducts(message, items.map((item) => item.product).toList());
    if (matches.isEmpty) {
      return 'Tell me the product name you want removed from your cart.';
    }
    for (final product in matches) {
      _removeProduct(product.id);
    }
    return 'Removed ${matches.map((product) => product.name).join(', ')} from your cart.';
  }

  String _cartSummaryReply() {
    final items = _cartItems();
    if (items.isEmpty) {
      return 'Your cart is empty. Tell me what you need and I will add it.';
    }
    final lines = items
        .map((item) =>
            '${item.quantity} x ${item.product.name} - EGP ${item.totalPrice.toStringAsFixed(2)}')
        .join('\n');
    final total = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
    return 'Your cart:\n$lines\n\nTotal: EGP ${total.toStringAsFixed(2)}.';
  }

  String _latestOrderReply() {
    final orders = _orders();
    if (orders.isEmpty) {
      return 'You do not have any orders yet. Open My Orders to track future orders, or I can help you prepare a new cart.';
    }
    final latest = [...orders]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return 'Your latest order ${latest.first.id} is ${_orderStatus(latest.first.status)}. Open My Orders for tracking and details.';
  }

  String _recommendProducts() {
    final products = _products()
        .where((product) => product.isActive && product.inStock)
        .take(4)
        .toList();
    if (products.isEmpty) return 'There are no available products right now.';
    return 'Available picks:\n${products.map((product) => '${product.name} - EGP ${product.price.toStringAsFixed(0)}').join('\n')}';
  }

  String _productDetailsReply(List<Product> products) =>
      products.map((product) {
        final stock = product.isActive && product.inStock
            ? '${product.stockQuantity} in stock'
            : 'currently unavailable';
        return '${product.name} - EGP ${product.price.toStringAsFixed(2)}\n$stock';
      }).join('\n\n');

  List<String> _alternativesFor(List<Product> unavailable) {
    final categories = unavailable.map((product) => product.categoryId).toSet();
    final ids = unavailable.map((product) => product.id).toSet();
    return _products()
        .where((product) =>
            !ids.contains(product.id) &&
            categories.contains(product.categoryId) &&
            product.isActive &&
            product.inStock)
        .take(3)
        .map((product) => product.name)
        .toList();
  }

  String _orderStatus(OrderStatus status) => switch (status) {
        OrderStatus.placed => 'received',
        OrderStatus.scheduled => 'scheduled',
        OrderStatus.preparing => 'being prepared',
        OrderStatus.driverAssigned => 'assigned to a driver',
        OrderStatus.outForDelivery => 'out for delivery',
        OrderStatus.delivered => 'delivered',
        OrderStatus.cancelled => 'cancelled',
      };

  bool _containsAny(String message, List<String> terms) =>
      terms.any(message.contains);

  bool _hasArabic(String value) => RegExp('[\u0600-\u06ff]').hasMatch(value);

  String _normalize(String value) => _westernDigits(value.toLowerCase())
      .replaceAll(RegExp('[\\u064b-\\u065f\\u0670]'), '')
      .replaceAll('\\u0623', '\\u0627')
      .replaceAll('\\u0625', '\\u0627')
      .replaceAll('\\u0622', '\\u0627')
      .replaceAll('\\u0649', '\\u064a')
      .replaceAll('\\u0629', '\\u0647')
      .replaceAll('\\u0640', '');

  String _westernDigits(String value) {
    const eastern =
        '\u0660\u0661\u0662\u0663\u0664\u0665\u0666\u0667\u0668\u0669';
    return value.replaceAllMapped(RegExp('[\\u0660-\\u0669]'),
        (match) => eastern.indexOf(match.group(0)!).toString());
  }

  void _addAssistantMessage(String text) {
    final now = DateTime.now();
    state = state.copyWith(messages: [
      ...state.messages,
      ChatMessage(
          id: 'bot-${now.microsecondsSinceEpoch}',
          role: ChatRole.assistant,
          text: text,
          createdAt: now)
    ], isTyping: false);
  }

  static const _addTerms = [
    'add',
    'put',
    'buy',
    'order',
    'cart',
    'more',
    'another',
    'increase',
    'need',
    'want',
    '\u0636\u064a\u0641',
    '\u0627\u0636\u0641',
    '\u062d\u0637',
    '\u0627\u0634\u062a\u0631\u064a',
    '\u0639\u0627\u064a\u0632',
    '\u0639\u0627\u0648\u0632',
    '\u0645\u062d\u062a\u0627\u062c',
    '\u0627\u0637\u0644\u0628',
    '\u0633\u0644\u0647',
    '\u0627\u0648\u0631\u062f\u0631',
    '\u0637\u0644\u0628'
  ];
  static const _removeTerms = [
    'remove',
    'delete',
    'take out',
    '\u0634\u064a\u0644',
    '\u0627\u0645\u0633\u062d',
    '\u0627\u062d\u0630\u0641',
    '\u0627\u0644\u063a\u064a'
  ];
  static const _cartTerms = [
    'what is in my cart',
    'show cart',
    'show my cart',
    'show me my cart',
    'you show my cart',
    'my cart',
    'cart total',
    '\u0627\u0644\u0633\u0644\u0647',
    '\u0633\u0644\u0647',
    '\u0645\u0648\u062c\u0648\u062f \u0641\u064a \u0627\u0644\u0633\u0644\u0647'
  ];
  static const _genericOrderTerms = [
    'make an order',
    'place an order',
    'create an order',
    'new order',
    'i need order',
    'i need an order',
    'need order',
    'i want an order',
    '\u0639\u0627\u064a\u0632 \u0627\u0639\u0645\u0644 \u0627\u0648\u0631\u062f\u0631',
    '\u0639\u0627\u0648\u0632 \u0627\u0639\u0645\u0644 \u0627\u0648\u0631\u062f\u0631',
    '\u0627\u0639\u0645\u0644 \u0627\u0648\u0631\u062f\u0631',
    '\u0637\u0644\u0628 \u062c\u062f\u064a\u062f'
  ];
  static const _trackingTerms = [
    'track',
    'status',
    'where is',
    'my order',
    'delivery status',
    '\u062a\u062a\u0628\u0639',
    '\u062d\u0627\u0644\u0647',
    '\u0641\u064a\u0646 \u0627\u0644\u0627\u0648\u0631\u062f\u0631',
    '\u0637\u0644\u0628\u064a',
    '\u0627\u0644\u0637\u0644\u0628'
  ];
  static const _recommendTerms = [
    'recommend',
    'suggest',
    'popular',
    'best',
    'offer',
    '\u0627\u0642\u062a\u0631\u0627\u062d',
    '\u0631\u0634\u062d',
    '\u0639\u0631\u0648\u0636'
  ];
  static const _productQuestionTerms = [
    'price',
    'cost',
    'available',
    'stock',
    'details',
    'how much',
    '\u0633\u0639\u0631',
    '\u0645\u062a\u0627\u062d',
    '\u0645\u062e\u0632\u0648\u0646',
    '\u062a\u0641\u0627\u0635\u064a\u0644',
    '\u0628\u0643\u0627\u0645'
  ];
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  const apiKey = String.fromEnvironment('GEMINI_API_KEY');
  const model =
      String.fromEnvironment('GEMINI_MODEL', defaultValue: 'gemini-2.5-flash');
  if (apiKey.isEmpty) return const LocalQBotRepository();
  return GeminiQBotRepository(apiKey: apiKey, model: model);
});

final chatProvider =
    StateNotifierProvider<ChatViewModel, ChatState>((ref) => ChatViewModel(
          ref.watch(chatRepositoryProvider),
          products: () => ref.read(catalogProvider).products,
          orders: () => ref.read(ordersProvider),
          cartItems: () => ref.read(cartProvider),
          addProduct: ref.read(cartProvider.notifier).addProduct,
          removeProduct: ref.read(cartProvider.notifier).removeProduct,
        ));
