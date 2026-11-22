import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ChatRepository {
  Future<String> sendMessage(String message);
}

/// Sends messages to the askQBot function, which keeps the Gemini key on the
/// server. Guests and failed calls receive the built-in answers.
class FirebaseQBotRepository implements ChatRepository {
  FirebaseQBotRepository({
    required FirebaseFunctions functions,
    required FirebaseAuth auth,
    ChatRepository fallback = const LocalQBotRepository(),
  }) : _functions = functions,
       _auth = auth,
       _fallback = fallback;

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;
  final ChatRepository _fallback;

  @override
  Future<String> sendMessage(String message) async {
    if (_auth.currentUser == null) return _fallback.sendMessage(message);
    try {
      final result = await _functions
          .httpsCallable('askQBot')
          .call<Map<Object?, Object?>>({'message': message});
      final answer = result.data['answer']?.toString().trim() ?? '';
      if (answer.isNotEmpty) return answer;
    } on FirebaseFunctionsException {
      // The built-in answers below keep Q Bot useful during an outage.
    }
    return _fallback.sendMessage(message);
  }
}

class LocalQBotRepository implements ChatRepository {
  const LocalQBotRepository();

  @override
  Future<String> sendMessage(String message) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final text = message.toLowerCase().trim();

    if (RegExp('[؀-ۿ]').hasMatch(text)) {
      return 'أنا Q Bot. أقدر أساعدك في المنتجات، السلة، الأوردرات، التوصيل، الدفع، والكوبونات. اكتب اسم المنتج والكمية التي تريدها وسأجهز السلة.';
    }

    if (_contains(text, ['order', 'track', 'delivery status'])) {
      return 'You can track an order from Account → My Orders. Open the order to see its current status and delivery details.';
    }
    if (_contains(text, ['cancel', 'cancellation'])) {
      return 'Open Account → My Orders, select an order, then choose Cancel order. Cancellation is available before preparation starts.';
    }
    if (_contains(text, ['late', 'driver', 'where is'])) {
      return 'Please check the order timeline first. If the delivery window has passed, share the order number with customer support.';
    }
    if (_contains(text, ['payment', 'card', 'cash', 'wallet'])) {
      return 'Qebox currently accepts cash on delivery.';
    }
    if (_contains(text, ['promo', 'discount', 'coupon', 'offer'])) {
      return 'Enter your promo code during checkout. Q Bot will show whether it is valid and any minimum-order requirement.';
    }
    if (_contains(text, ['address', 'location', 'floor', 'apartment'])) {
      return 'Manage saved addresses from Account → Addresses. Add the building, floor, and apartment so delivery is easier.';
    }
    if (_contains(text, ['out of stock', 'replace', 'substitution'])) {
      return 'At checkout, choose whether unavailable items should be replaced automatically, removed, or confirmed with you first.';
    }
    if (_contains(text, ['hello', 'hi', 'hey'])) {
      return 'Hello! I’m Q Bot, your Qebox AI assistant. How can I help with your shopping or order today?';
    }
    return 'I can help with orders, delivery, cancellation, payments, promo codes, addresses, and unavailable items. What would you like to know?';
  }

  bool _contains(String text, List<String> terms) {
    return terms.any(text.contains);
  }
}
