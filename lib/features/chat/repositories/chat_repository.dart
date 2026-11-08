import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class ChatRepository {
  Future<String> sendMessage(String message);
}

class GeminiQBotRepository implements ChatRepository {
  GeminiQBotRepository({
    required this.apiKey,
    this.model = 'gemini-2.5-flash',
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _client;

  @override
  Future<String> sendMessage(String message) async {
    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$model:generateContent',
    );
    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          body: jsonEncode({
            'systemInstruction': {
              'parts': [
                {
                  'text': 'You are Q Bot, the friendly Qebox grocery shopping '
                      'assistant. Give concise, helpful answers about shopping, '
                      'products, orders, delivery, checkout, promotions, and '
                      'accounts. Never invent an order status, price, refund, or '
                      'policy. Never claim that you added, removed, or changed '
                      'cart items; cart actions are handled by the app. Tell the '
                      'customer when staff assistance is needed.',
                },
              ],
            },
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': message},
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.4,
              'maxOutputTokens': 350,
            },
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gemini request failed (${response.statusCode}).');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = body['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini returned no answer.');
    }
    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final answer = parts
        ?.map(
            (part) => (part as Map<String, dynamic>)['text']?.toString() ?? '')
        .join('\n')
        .trim();
    if (answer == null || answer.isEmpty) {
      throw Exception('Gemini returned an empty answer.');
    }
    return answer;
  }
}

class LocalQBotRepository implements ChatRepository {
  const LocalQBotRepository();

  @override
  Future<String> sendMessage(String message) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final text = message.toLowerCase().trim();

    if (RegExp('[\u0600-\u06ff]').hasMatch(text)) {
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
      return 'Qebox supports the payment methods shown during checkout. Card and wallet services depend on the configured payment provider.';
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
