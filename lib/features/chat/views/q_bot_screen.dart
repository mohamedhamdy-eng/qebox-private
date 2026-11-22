import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/viewmodels/cart_view_model.dart';
import '../../cart/views/cart_screen.dart';
import '../models/chat_message.dart';
import '../viewmodels/chat_view_model.dart';
import '../../../core/l10n/app_language.dart';

class QBotScreen extends ConsumerStatefulWidget {
  const QBotScreen({super.key, this.closeAsPanel = false});

  final bool closeAsPanel;

  @override
  ConsumerState<QBotScreen> createState() => _QBotScreenState();
}

class _QBotScreenState extends ConsumerState<QBotScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  static const _prompts = [
    (
      'Restock my kitchen and household items',
      'Restock common must-haves',
      Icons.shopping_bag_rounded,
    ),
    (
      'Fresh fruit and vegetable deals this week',
      'Find ways to save',
      Icons.local_offer_rounded,
    ),
    (
      'Mediterranean diet meal ideas',
      'Shop for dietary needs',
      Icons.eco_rounded,
    ),
    (
      'Help with my shopping list or recipe',
      'Instantly find items',
      Icons.document_scanner_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? prompt]) async {
    final text = prompt ?? _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    await ref.read(chatProvider.notifier).send(text);
    if (!mounted || !_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    final cartCount = ref
        .watch(cartProvider)
        .fold<int>(0, (total, item) => total + item.quantity);
    final hasConversation = state.messages.length > 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: tr('Close Q Bot'),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, size: 30),
        ),
        titleSpacing: 0,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFFFFE6D5),
              child: Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFFEE7424),
                size: 21,
              ),
            ),
            SizedBox(width: 9),
            Text('Q Bot', style: TextStyle(fontWeight: FontWeight.w900)),
            SizedBox(width: 8),
            _BetaBadge(),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              end: 14,
              top: 10,
              bottom: 10,
            ),
            child: Material(
              color: const Color(0xFF198A36),
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shopping_cart_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: hasConversation
                ? _Conversation(state: state, controller: _scrollController)
                : _WelcomePrompts(onSelected: _send),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
            child: Text(
              tr(
                'This experience is powered by AI, so it might make mistakes. Double-check important details.',
              ),
              style: const TextStyle(fontSize: 11, color: Color(0xFF777777)),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 8, 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE8E1D8)),
                boxShadow: const [
                  BoxShadow(color: Color(0x0C000000), blurRadius: 12),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: tr('Shopping image support coming soon'),
                    onPressed: () => _showComingSoon(tr('Image search')),
                    icon: const Icon(Icons.camera_alt_rounded),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: state.isTyping ? null : (_) => _send(),
                      decoration: InputDecoration(
                        hintText: tr('Type here, or paste your shopping list'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: tr('Send'),
                    onPressed: state.isTyping ? null : _send,
                    icon: const Icon(Icons.arrow_upward_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF171717),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('{0} will be available soon.', [feature]))),
    );
  }
}

class _BetaBadge extends StatelessWidget {
  const _BetaBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF2E8),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      tr('Beta'),
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
    ),
  );
}

class _WelcomePrompts extends StatelessWidget {
  const _WelcomePrompts({required this.onSelected});
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 64, 24, 20),
    children: [
      const Text(
        "Hi, let's get shopping",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 38),
      ..._QBotScreenState._prompts.map(
        (prompt) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSelected(tr(prompt.$1)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE6D5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(prompt.$3, color: const Color(0xFFEE7424)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr(prompt.$1),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tr(prompt.$2),
                            style: const TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _Conversation extends StatelessWidget {
  const _Conversation({required this.state, required this.controller});
  final ChatState state;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) => ListView.builder(
    controller: controller,
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
    itemCount: state.messages.length + (state.isTyping ? 1 : 0),
    itemBuilder: (context, index) {
      if (index == state.messages.length) return const _TypingBubble();
      return _MessageBubble(message: state.messages[index]);
    },
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.role == ChatRole.user;
    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: mine ? const Color(0xFF171717) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            height: 1.35,
            color: mine ? Colors.white : const Color(0xFF171717),
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();
  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        tr('Q Bot is thinking…'),
        style: const TextStyle(color: Color(0xFF777777)),
      ),
    ),
  );
}
