import 'dart:math';

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
import '../../../core/l10n/app_language.dart';

class ChatState {
  const ChatState({required this.messages, this.isTyping = false});
  final List<ChatMessage> messages;
  final bool isTyping;
  ChatState copyWith({List<ChatMessage>? messages, bool? isTyping}) =>
      ChatState(
        messages: messages ?? this.messages,
        isTyping: isTyping ?? this.isTyping,
      );
}

class ChatViewModel extends StateNotifier<ChatState> {
  ChatViewModel(
    this._repository, {
    List<Product> Function()? products,
    List<CustomerOrder> Function()? orders,
    List<CartItem> Function()? cartItems,
    void Function(Product product)? addProduct,
    void Function(String productId)? removeProduct,
  }) : _products = products ?? _fallbackProducts,
       _orders = orders ?? _noOrders,
       _cartItems = cartItems ?? _noCartItems,
       _addProduct = addProduct,
       _removeProduct = removeProduct,
       super(
         ChatState(
           messages: [
             ChatMessage(
               id: 'welcome',
               role: ChatRole.assistant,
               text: tr(
                 'Hi! I am Q Bot. I understand Arabic and English. Tell me what you need and I will prepare your cart.',
               ),
               createdAt: DateTime.now(),
             ),
           ],
         ),
       );

  final ChatRepository _repository;
  final List<Product> Function() _products;
  final List<CustomerOrder> Function() _orders;
  final List<CartItem> Function() _cartItems;
  final void Function(Product product)? _addProduct;
  final void Function(String productId)? _removeProduct;

  static List<Product> _fallbackProducts() => ProductCatalog.allProducts;
  static List<CustomerOrder> _noOrders() => const [];
  static List<CartItem> _noCartItems() => const [];

  bool _replyInArabic = false;

  String _t(String english, [List<Object?> args = const []]) =>
      translate(english, args, arabic: _replyInArabic);

  String _name(Product product) =>
      _replyInArabic && (product.nameAr?.isNotEmpty ?? false)
      ? product.nameAr!
      : product.name;

  Future<void> send(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || state.isTyping) return;
    _replyInArabic = _hasArabic(cleanText);
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
    try {
      final reply = _handleCommand(cleanText);
      _addAssistantMessage(reply ?? await _repository.sendMessage(cleanText));
    } catch (_) {
      _addAssistantMessage(
        _t('I could not answer right now. Please try again in a moment.'),
      );
    }
  }

  String? _handleCommand(String source) {
    final message = _normalize(source);
    if (_containsAny(message, _trackingTerms)) return _latestOrderReply();
    if (_containsAny(message, _removeTerms)) return _removeFromCart(message);
    if (_containsAny(message, _cartTerms) &&
        !_containsAny(message, _explicitAddTerms) &&
        _exactMatches(message, _products()).isEmpty) {
      return _cartSummaryReply();
    }
    if (_containsAny(message, _recommendTerms)) return _recommendProducts();
    if (_containsAny(message, _productQuestionTerms)) {
      final catalog = _products();
      final exact = _exactMatches(message, catalog);
      final products = exact.isNotEmpty
          ? exact
          : _partialMatches(message, catalog);
      if (products.isNotEmpty) return _productDetailsReply(products);
    }
    if (!_containsAny(message, _addTerms)) return null;

    final catalog = _products();
    var matches = _exactMatches(message, catalog);
    if (matches.isEmpty) {
      final partial = _partialMatches(message, catalog);
      // A partial name can come from an unrelated sentence. Change the cart
      // only for one clear match after an explicit request.
      if (partial.length == 1 && _containsAny(message, _explicitAddTerms)) {
        matches = partial;
      } else if (partial.isNotEmpty) {
        return _t(
          'Did you mean {0}? Send the full product name and I will add it.',
          [partial.map((product) => _name(product)).join(_t(_t(' or ')))],
        );
      }
    }
    if (matches.isEmpty) {
      if (_containsAny(message, _genericOrderTerms)) {
        return _hasArabic(source)
            ? 'تمام. اكتب المنتجات والكميات التي تريدها، مثلاً: ضيف ٢ لبن و١ خبز. سأجهز السلة ثم تختار التوصيل والدفع من Checkout.'
            : 'Great. Tell me the products and quantities you want. Example: add 2 milk and 1 bread. I will prepare the cart, then you confirm delivery and payment in Checkout.';
      }
      if (RegExp(r'^(?:i )?(?:need|want)\s*\d*\s*$').hasMatch(message)) {
        return _t(
          'Tell me the product name after the quantity. For example: “I need 2 bread”.',
        );
      }
      if (!_containsAny(message, _explicitAddTerms)) return null;
      final names = catalog.take(5).map((product) => _name(product)).join(', ');
      return _t('I did not find a product name in your message. Try: {0}.', [
        names,
      ]);
    }
    if (_addProduct == null) {
      return _t('Cart actions are temporarily unavailable. Please try again.');
    }

    final added = <String>[];
    final unavailable = <Product>[];
    final atLimit = <String>[];
    for (final product in matches) {
      if (!product.isActive || !product.inStock) {
        unavailable.add(product);
        continue;
      }
      final available = _remainingQuantity(product);
      if (available <= 0) {
        atLimit.add(_name(product));
        continue;
      }
      final quantity = min(_requestedQuantity(message, product), available);
      for (var i = 0; i < quantity; i++) {
        _addProduct(product);
      }
      added.add(
        quantity == 1 ? _name(product) : '$quantity \u00d7 ${_name(product)}',
      );
    }
    final lines = <String>[];
    if (added.isNotEmpty) {
      lines.add(_t('Added {0} to your cart.', [added.join(', ')]));
    }
    if (atLimit.isNotEmpty) {
      lines.add(
        _t('Your cart already has the maximum of {0}.', [atLimit.join(', ')]),
      );
    }
    if (unavailable.isNotEmpty) {
      lines.add(
        _t('Unavailable: {0}.', [
          unavailable.map((product) => _name(product)).join(', '),
        ]),
      );
      final alternatives = _alternativesFor(unavailable);
      if (alternatives.isNotEmpty) {
        lines.add(_t('Try instead: {0}.', [alternatives.join(', ')]));
      }
    }
    lines.add(
      _t(
        'Open Cart, then Checkout to choose delivery details and confirm your order.',
      ),
    );
    return lines.join('\n');
  }

  Iterable<String> _productNames(Product product) => [
    _name(product),
    product.nameAr,
  ].whereType<String>().map(_normalize).where((name) => name.length > 1);

  Iterable<String> _nameWords(Product product) => _productNames(product)
      .expand((name) => name.split(RegExp(r'\s+')))
      .where((word) => word.length > 2);

  List<Product> _exactMatches(String message, List<Product> products) =>
      products
          .where(
            (product) =>
                _productNames(product).any((name) => _hasTerm(message, name)),
          )
          .toList();

  /// Returns the products with the most name words in the message.
  List<Product> _partialMatches(String message, List<Product> products) {
    var best = 0;
    var matches = <Product>[];
    for (final product in products) {
      final score = _nameWords(
        product,
      ).where((word) => _hasTerm(message, word)).length;
      if (score == 0 || score < best) continue;
      if (score > best) {
        best = score;
        matches = [];
      }
      matches.add(product);
    }
    return matches;
  }

  int _requestedQuantity(String message, Product product) {
    for (final name in [..._productNames(product), ..._nameWords(product)]) {
      final match = RegExp(
        '(\\d+)\\s*(?:x)?\\s*(?:ال)?${RegExp.escape(name)}',
      ).firstMatch(message);
      final number = int.tryParse(match?.group(1) ?? '');
      if (number != null) return max(number, 1);
    }
    return 1;
  }

  int _remainingQuantity(Product product) {
    final inCart = _cartItems()
        .where((item) => item.product.id == product.id)
        .fold<int>(0, (total, item) => total + item.quantity);
    return min(
          product.maxQuantityPerOrder ?? product.stockQuantity,
          product.stockQuantity,
        ) -
        inCart;
  }

  String _removeFromCart(String message) {
    if (_removeProduct == null) {
      return _t('Cart actions are temporarily unavailable. Please try again.');
    }
    final products = _cartItems().map((item) => item.product).toList();
    final exact = _exactMatches(message, products);
    final matches = exact.isNotEmpty
        ? exact
        : _partialMatches(message, products);
    if (matches.isEmpty) {
      return _t('Tell me the product name you want removed from your cart.');
    }
    if (exact.isEmpty && matches.length > 1) {
      return _t(
        'Did you mean {0}? Send the full product name and I will remove it.',
        [matches.map((product) => _name(product)).join(_t(_t(' or ')))],
      );
    }
    for (final product in matches) {
      _removeProduct(product.id);
    }
    return _t('Removed {0} from your cart.', [
      matches.map((product) => _name(product)).join(', '),
    ]);
  }

  String _cartSummaryReply() {
    final items = _cartItems();
    if (items.isEmpty) {
      return _t('Your cart is empty. Tell me what you need and I will add it.');
    }
    final lines = items
        .map(
          (item) => _t('{0} x {1} - EGP {2}', [
            item.quantity,
            _name(item.product),
            item.totalPrice.toStringAsFixed(2),
          ]),
        )
        .join('\n');
    final total = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
    return _t('Your cart:\n{0}\n\nTotal: EGP {1}.', [
      lines,
      total.toStringAsFixed(2),
    ]);
  }

  String _latestOrderReply() {
    final orders = _orders();
    if (orders.isEmpty) {
      return _t(
        'You do not have any orders yet. Open My Orders to track future orders, or I can help you prepare a new cart.',
      );
    }
    final latest = [...orders]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _t(
      'Your latest order {0} is {1}. Open My Orders for tracking and details.',
      [latest.first.id, _orderStatus(latest.first.status)],
    );
  }

  String _recommendProducts() {
    final products = _products()
        .where((product) => product.isActive && product.inStock)
        .take(4)
        .toList();
    if (products.isEmpty) {
      return _t('There are no available products right now.');
    }
    return _t('Available picks:\n{0}', [
      products
          .map(
            (product) => _t('{0} - EGP {1}', [
              _name(product),
              product.price.toStringAsFixed(0),
            ]),
          )
          .join('\n'),
    ]);
  }

  String _productDetailsReply(List<Product> products) => products
      .map((product) {
        final stock = product.isActive && product.inStock
            ? _t('{0} in stock', [product.stockQuantity])
            : _t('currently unavailable');
        return _t('{0} - EGP {1}\n{2}', [
          _name(product),
          product.price.toStringAsFixed(2),
          stock,
        ]);
      })
      .join('\n\n');

  List<String> _alternativesFor(List<Product> unavailable) {
    final categories = unavailable.map((product) => product.categoryId).toSet();
    final ids = unavailable.map((product) => product.id).toSet();
    return _products()
        .where(
          (product) =>
              !ids.contains(product.id) &&
              categories.contains(product.categoryId) &&
              product.isActive &&
              product.inStock,
        )
        .take(3)
        .map((product) => _name(product))
        .toList();
  }

  String _orderStatus(OrderStatus status) => switch (status) {
    OrderStatus.placed => _t('received'),
    OrderStatus.scheduled => _t('scheduled'),
    OrderStatus.preparing => _t('being prepared'),
    OrderStatus.driverAssigned => _t('assigned to a driver'),
    OrderStatus.outForDelivery => _t('out for delivery'),
    OrderStatus.delivered => _t('delivered'),
    OrderStatus.cancelled => _t('cancelled'),
  };

  bool _containsAny(String message, List<String> terms) =>
      terms.any((term) => _hasTerm(message, term));

  /// Matches whole English words, so "add" does not match "address". Arabic
  /// words can carry attached prefixes and suffixes, so only the word start
  /// is checked.
  bool _hasTerm(String message, String term) {
    final escaped = RegExp.escape(term);
    final pattern = _hasArabic(term)
        ? '(?<![\\p{L}\\p{N}])(?:\u0648|\u0641|\u0628)?(?:\u0627\u0644)?$escaped'
        : '(?<![\\p{L}\\p{N}])${escaped}s?(?![\\p{L}\\p{N}])';
    return RegExp(pattern, unicode: true).hasMatch(message);
  }

  bool _hasArabic(String value) => RegExp('[\u0600-\u06ff]').hasMatch(value);

  String _normalize(String value) => _westernDigits(value.toLowerCase())
      .replaceAll(RegExp('[\\u064b-\\u065f\\u0670]'), '')
      .replaceAll('\u0623', '\u0627')
      .replaceAll('\u0625', '\u0627')
      .replaceAll('\u0622', '\u0627')
      .replaceAll('\u0649', '\u064a')
      .replaceAll('\u0629', '\u0647')
      .replaceAll('\u0640', '');

  String _westernDigits(String value) {
    const eastern =
        '\u0660\u0661\u0662\u0663\u0664\u0665\u0666\u0667\u0668\u0669';
    return value.replaceAllMapped(
      RegExp('[\\u0660-\\u0669]'),
      (match) => eastern.indexOf(match.group(0)!).toString(),
    );
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
    '\u0637\u0644\u0628',
  ];
  static const _explicitAddTerms = [
    'add',
    'put',
    'buy',
    'ضيف',
    'اضف',
    'حط',
    'اشتري',
  ];
  static const _removeTerms = [
    'remove',
    'delete',
    'take out',
    '\u0634\u064a\u0644',
    '\u0627\u0645\u0633\u062d',
    '\u0627\u062d\u0630\u0641',
    '\u0627\u0644\u063a\u064a',
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
    '\u0645\u0648\u062c\u0648\u062f \u0641\u064a \u0627\u0644\u0633\u0644\u0647',
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
    '\u0637\u0644\u0628 \u062c\u062f\u064a\u062f',
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
    '\u0627\u0644\u0637\u0644\u0628',
  ];
  static const _recommendTerms = [
    'recommend',
    'suggest',
    'popular',
    'best',
    'offer',
    '\u0627\u0642\u062a\u0631\u0627\u062d',
    '\u0631\u0634\u062d',
    '\u0639\u0631\u0648\u0636',
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
    '\u0628\u0643\u0627\u0645',
  ];
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => const LocalQBotRepository(),
);

final chatProvider = StateNotifierProvider<ChatViewModel, ChatState>(
  (ref) => ChatViewModel(
    ref.watch(chatRepositoryProvider),
    products: () => ref.read(catalogProvider).products,
    orders: () => ref.read(ordersProvider),
    cartItems: () => ref.read(cartProvider),
    addProduct: ref.read(cartProvider.notifier).addProduct,
    removeProduct: ref.read(cartProvider.notifier).removeProduct,
  ),
);
