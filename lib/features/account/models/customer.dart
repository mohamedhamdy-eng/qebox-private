class Customer {
  final String id;
  final String name;
  final String phone;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json,
  ) {
    return Customer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }
}