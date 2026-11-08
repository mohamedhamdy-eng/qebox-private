part of 'checkout_screen.dart';

extension _CheckoutPricingSections on _CheckoutScreenState {
  List<Widget> _promoSection(
    CheckoutState checkoutState,
    double subtotal,
    double discount,
    String? promoMessage,
  ) {
    return [
      // ==================================
      // SAVE ON YOUR ORDER
      // ==================================
      const _SectionTitle(title: 'Save on your order'),

      const SizedBox(height: 6),

      const Text(
        'Have a promo code? Apply it here.',
        style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
      ),

      const SizedBox(height: 14),

      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    enabled: checkoutState.promoCode.isEmpty,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      prefixIcon: const Icon(
                        Icons.local_offer_outlined,
                        color: Color(0xFFEE7424),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F7F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: checkoutState.promoCode.isEmpty
                        ? () async {
                            await ref
                                .read(checkoutProvider.notifier)
                                .applyPromoCode(
                                  code: _promoController.text,
                                  subtotal: subtotal,
                                );
                          }
                        : () {
                            ref
                                .read(checkoutProvider.notifier)
                                .removePromoCode();

                            _promoController.clear();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: checkoutState.promoCode.isEmpty
                          ? const Color(0xFF171717)
                          : const Color(0xFFEE7424),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      checkoutState.promoCode.isEmpty ? 'Apply' : 'Remove',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            if (promoMessage != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  promoMessage,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: discount > 0
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE53935),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      const SizedBox(height: 28),
    ];
  }

  List<Widget> _paymentSection(CheckoutState checkoutState) {
    return [
      // ==================================
      // PAYMENT METHOD
      // ==================================
      const _SectionTitle(title: 'Payment method'),

      const SizedBox(height: 6),

      const Text(
        'Qebox currently accepts cash on delivery.',
        style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
      ),

      const SizedBox(height: 14),

      _PaymentOption(
        title: 'Cash on delivery',
        subtitle: 'Pay when your order arrives',
        icon: Icons.payments_outlined,
        selected: checkoutState.paymentMethod == PaymentMethod.cash,
        onTap: () {
          ref
              .read(checkoutProvider.notifier)
              .selectPaymentMethod(PaymentMethod.cash);
        },
      ),

      const SizedBox(height: 28),
    ];
  }

  List<Widget> _orderNotesSection(String orderNote) {
    return [
      // ==================================
      // ORDER NOTES
      // ==================================
      const _SectionTitle(title: 'Order notes'),

      const SizedBox(height: 14),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: orderNote.trim().isEmpty
            ? const Row(
                children: [
                  Icon(Icons.notes_rounded, color: Color(0xFF999999)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No order notes added',
                      style: TextStyle(fontSize: 13, color: Color(0xFF777777)),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, color: Color(0xFFEE7424)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      orderNote,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF171717),
                      ),
                    ),
                  ),
                ],
              ),
      ),

      const SizedBox(height: 28),
    ];
  }

  List<Widget> _orderSummarySection(
    double subtotal,
    double discount,
    double total,
  ) {
    return [
      // ==================================
      // ORDER SUMMARY
      // ==================================
      const _SectionTitle(title: 'Order summary'),

      const SizedBox(height: 14),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            _SummaryRow(
              title: 'Subtotal',
              value: 'EGP ${subtotal.toStringAsFixed(2)}',
            ),
            if (discount > 0) ...[
              const SizedBox(height: 12),
              _SummaryRow(
                title: 'Discount',
                value: '- EGP ${discount.toStringAsFixed(2)}',
                isDiscount: true,
              ),
            ],
            const SizedBox(height: 12),
            const _SummaryRow(title: 'Delivery fee', value: 'EGP 20.00'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            _SummaryRow(
              title: 'Total',
              value: 'EGP ${total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    ];
  }
}
