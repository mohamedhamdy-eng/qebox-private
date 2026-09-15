enum OrderStatus {
  placed,
  scheduled,
  preparing,
  driverAssigned,
  outForDelivery,
  delivered,
  cancelled,
}

enum OrderPaymentMethod {
  cash,
  card,
  wallet,
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  double get total {
    return price * quantity;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
    };
  }
}

class CustomerOrder {
  final String id;

  // =====================================================
  // CUSTOMER SNAPSHOT
  // بيانات العميل وقت إنشاء الأوردر
  // =====================================================

  final String customerId;
  final String customerName;
  final String customerPhone;

  // =====================================================
  // ITEMS
  // =====================================================

  final List<OrderItem> items;

  // =====================================================
  // ADDRESS
  // =====================================================

  final String addressLabel;
  final String addressLine;

  final String? building;
  final String? floor;
  final String? apartment;
  final String? landmark;

  // =====================================================
  // DELIVERY
  // =====================================================

  final DateTime deliveryStart;
  final DateTime deliveryEnd;

  // =====================================================
  // PAYMENT
  // =====================================================

  final OrderPaymentMethod paymentMethod;

  // =====================================================
  // NOTES / PROMO
  // =====================================================

  final String? orderNote;
  final String? promoCode;
  final String substitutionPreference;
  final String deliveryInstruction;
  final String? cancellationReason;

  // =====================================================
  // PRICES
  // =====================================================

  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;

  // =====================================================
  // STATUS
  // =====================================================

  final OrderStatus status;

  // =====================================================
  // CREATED DATE
  // =====================================================

  final DateTime createdAt;

  const CustomerOrder({
    required this.id,

    // Customer data
    this.customerId = '',
    this.customerName = '',
    this.customerPhone = '',
    required this.items,
    required this.addressLabel,
    required this.addressLine,
    this.building,
    this.floor,
    this.apartment,
    this.landmark,
    required this.deliveryStart,
    required this.deliveryEnd,
    required this.paymentMethod,
    this.orderNote,
    this.promoCode,
    this.substitutionPreference = 'contactMe',
    this.deliveryInstruction = 'Call on arrival',
    this.cancellationReason,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    this.status = OrderStatus.placed,
    required this.createdAt,
  });

  CustomerOrder copyWith({
    OrderStatus? status,
    String? cancellationReason,
  }) {
    return CustomerOrder(
      id: id,

      // Customer data
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,

      items: items,

      addressLabel: addressLabel,
      addressLine: addressLine,

      building: building,
      floor: floor,
      apartment: apartment,
      landmark: landmark,

      deliveryStart: deliveryStart,
      deliveryEnd: deliveryEnd,

      paymentMethod: paymentMethod,

      orderNote: orderNote,
      promoCode: promoCode,
      substitutionPreference: substitutionPreference,
      deliveryInstruction: deliveryInstruction,
      cancellationReason: cancellationReason ?? this.cancellationReason,

      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,

      status: status ?? this.status,

      createdAt: createdAt,
    );
  }

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      addressLabel: json['address_label']?.toString() ?? '',
      addressLine: json['address_line']?.toString() ?? '',
      building: json['building']?.toString(),
      floor: json['floor']?.toString(),
      apartment: json['apartment']?.toString(),
      landmark: json['landmark']?.toString(),
      deliveryStart: DateTime.parse(json['delivery_start'].toString()),
      deliveryEnd: DateTime.parse(json['delivery_end'].toString()),
      paymentMethod: OrderPaymentMethod.values.firstWhere(
        (value) => value.name == json['payment_method'],
        orElse: () => OrderPaymentMethod.cash,
      ),
      orderNote: json['order_note']?.toString(),
      promoCode: json['promo_code']?.toString(),
      substitutionPreference:
          json['substitution_preference']?.toString() ?? 'contactMe',
      deliveryInstruction:
          json['delivery_instruction']?.toString() ?? 'Call on arrival',
      cancellationReason: json['cancellation_reason']?.toString(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      status: OrderStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => OrderStatus.placed,
      ),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'address_label': addressLabel,
      'address_line': addressLine,
      'building': building,
      'floor': floor,
      'apartment': apartment,
      'landmark': landmark,
      'delivery_start': deliveryStart.toIso8601String(),
      'delivery_end': deliveryEnd.toIso8601String(),
      'payment_method': paymentMethod.name,
      'order_note': orderNote,
      'promo_code': promoCode,
      'substitution_preference': substitutionPreference,
      'delivery_instruction': deliveryInstruction,
      'cancellation_reason': cancellationReason,
      'subtotal': subtotal,
      'discount': discount,
      'delivery_fee': deliveryFee,
      'total': total,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
