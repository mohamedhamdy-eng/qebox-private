part of 'order_details_screen.dart';

extension _OrderDetailsSections on OrderDetailsScreen {
  List<Widget> _statusSection(_StatusStyle statusStyle) {
    return [
      // =====================================================
      // ORDER NUMBER + STATUS
      // =====================================================
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE6D5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFFEE7424),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order number',
                    style: TextStyle(fontSize: 11, color: Color(0xFF777777)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF171717),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: statusStyle.backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusStyle.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: statusStyle.textColor,
                ),
              ),
            ),
          ],
        ),
      ),

      if (order.status == OrderStatus.cancelled &&
          order.cancellationReason != null) ...[
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            'Cancellation reason: ${order.cancellationReason}',
            style: TextStyle(color: Colors.red.shade800),
          ),
        ),
      ],

      const SizedBox(height: 24),
    ];
  }

  List<Widget> _journeySection() {
    return [
      // =====================================================
      // ORDER JOURNEY
      // =====================================================
      const Text(
        'Order journey',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: Color(0xFF171717),
        ),
      ),

      const SizedBox(height: 6),

      const Text(
        'Follow the progress of your order.',
        style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
      ),

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
            _JourneyStep(
              title: 'Order received',
              completed: _isStepCompleted(order.status, OrderStatus.placed),
              current: order.status == OrderStatus.placed,
              isLast: false,
            ),
            _JourneyStep(
              title: 'Scheduled',
              completed: _isStepCompleted(order.status, OrderStatus.scheduled),
              current: order.status == OrderStatus.scheduled,
              isLast: false,
            ),
            _JourneyStep(
              title: 'Preparing',
              completed: _isStepCompleted(order.status, OrderStatus.preparing),
              current: order.status == OrderStatus.preparing,
              isLast: false,
            ),
            _JourneyStep(
              title: 'Driver assigned',
              completed: _isStepCompleted(
                order.status,
                OrderStatus.driverAssigned,
              ),
              current: order.status == OrderStatus.driverAssigned,
              isLast: false,
            ),
            _JourneyStep(
              title: 'Out for delivery',
              completed: _isStepCompleted(
                order.status,
                OrderStatus.outForDelivery,
              ),
              current: order.status == OrderStatus.outForDelivery,
              isLast: false,
            ),
            _JourneyStep(
              title: 'Delivered',
              completed: order.status == OrderStatus.delivered,
              current: order.status == OrderStatus.delivered,
              isLast: true,
            ),
          ],
        ),
      ),

      if (order.status == OrderStatus.cancelled) ...[
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE8E8),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: Color(0xFFE53935)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'This order has been cancelled.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE53935),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      const SizedBox(height: 24),
    ];
  }

  List<Widget> _customerSection() {
    return [
      // =====================================================
      // CUSTOMER DETAILS
      // =====================================================
      const Text(
        'Customer details',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: Color(0xFF171717),
        ),
      ),

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
            _InfoRow(
              icon: Icons.person_outline_rounded,
              title: 'Full name',
              value: order.customerName.trim().isEmpty
                  ? 'Not available'
                  : order.customerName,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            _InfoRow(
              icon: Icons.phone_outlined,
              title: 'Mobile number',
              value: order.customerPhone.trim().isEmpty
                  ? 'Not available'
                  : order.customerPhone,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            _InfoRow(
              icon: Icons.badge_outlined,
              title: 'Customer ID',
              value: order.customerId.trim().isEmpty
                  ? 'Not available'
                  : order.customerId,
            ),
          ],
        ),
      ),

      const SizedBox(height: 24),
    ];
  }

  List<Widget> _deliverySection() {
    return [
      // =====================================================
      // DELIVERY
      // =====================================================
      const Text(
        'Delivery',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: Color(0xFF171717),
        ),
      ),

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
            _InfoRow(
              icon: Icons.schedule_outlined,
              title: 'Delivery time',
              value: _deliveryText(order),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            _InfoRow(
              icon: Icons.location_on_outlined,
              title: 'Delivery address',
              value: _addressText(order),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            _InfoRow(
              icon: Icons.delivery_dining_outlined,
              title: 'Delivery instruction',
              value: order.deliveryInstruction,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            _InfoRow(
              icon: Icons.swap_horiz_rounded,
              title: 'Out-of-stock preference',
              value: _substitutionLabel(order.substitutionPreference),
            ),
          ],
        ),
      ),

      const SizedBox(height: 24),
    ];
  }

  List<Widget> _itemsSection(BuildContext context) {
    return [
      // =====================================================
      // ITEMS
      // =====================================================
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Items',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171717),
            ),
          ),
          Text(
            '${_totalItems(order)} items',
            style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
          ),
        ],
      ),

      const SizedBox(height: 14),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: List.generate(order.items.length, (index) {
            final item = order.items[index];

            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F1ED),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Color(0xFFEE7424),
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.shopping_bag_outlined,
                              color: Color(0xFFEE7424),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF171717),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Qty: ${item.quantity}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF777777),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EGP ${item.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF171717),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'EGP ${item.price.toStringAsFixed(2)} each',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (index != order.items.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1),
                  ),
              ],
            );
          }),
        ),
      ),

      const SizedBox(height: 24),
    ];
  }

  List<Widget> _paymentSection() {
    return [
      // =====================================================
      // PAYMENT
      // =====================================================
      const Text(
        'Payment',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: Color(0xFF171717),
        ),
      ),

      const SizedBox(height: 14),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: _InfoRow(
          icon: Icons.payments_outlined,
          title: 'Payment method',
          value: _paymentText(order.paymentMethod),
        ),
      ),
    ];
  }

  List<Widget> _notesSection() {
    return [
      // =====================================================
      // ORDER NOTES
      // =====================================================
      if (order.orderNote != null && order.orderNote!.trim().isNotEmpty) ...[
        const SizedBox(height: 24),
        const Text(
          'Order notes',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF171717),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.notes_rounded, color: Color(0xFFEE7424)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  order.orderNote!,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF171717),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      const SizedBox(height: 24),
    ];
  }

  List<Widget> _summarySection() {
    return [
      // =====================================================
      // ORDER SUMMARY
      // =====================================================
      const Text(
        'Order summary',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: Color(0xFF171717),
        ),
      ),

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
              value: 'EGP ${order.subtotal.toStringAsFixed(2)}',
            ),
            if (order.discount > 0) ...[
              const SizedBox(height: 12),
              _SummaryRow(
                title: 'Discount',
                value: '- EGP ${order.discount.toStringAsFixed(2)}',
                isDiscount: true,
              ),
            ],
            const SizedBox(height: 12),
            _SummaryRow(
              title: 'Delivery fee',
              value: 'EGP ${order.deliveryFee.toStringAsFixed(2)}',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            _SummaryRow(
              title: 'Total',
              value: 'EGP ${order.total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),

      const SizedBox(height: 20),
    ];
  }
}
