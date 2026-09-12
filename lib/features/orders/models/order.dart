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

    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,

    this.status = OrderStatus.placed,

    required this.createdAt,
  });

  CustomerOrder copyWith({
    OrderStatus? status,
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

      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,

      status: status ?? this.status,

      createdAt: createdAt,
    );
  }
}