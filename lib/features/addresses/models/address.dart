class Address {
  final String id;
  final String label;
  final String addressLine;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? landmark;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.addressLine,
    this.building,
    this.floor,
    this.apartment,
    this.landmark,
    this.isDefault = false,
  });

  Address copyWith({
    String? id,
    String? label,
    String? addressLine,
    String? building,
    String? floor,
    String? apartment,
    String? landmark,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      addressLine: addressLine ?? this.addressLine,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      landmark: landmark ?? this.landmark,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      addressLine: json['address_line']?.toString() ?? '',
      building: json['building']?.toString(),
      floor: json['floor']?.toString(),
      apartment: json['apartment']?.toString(),
      landmark: json['landmark']?.toString(),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'address_line': addressLine,
      'building': building,
      'floor': floor,
      'apartment': apartment,
      'landmark': landmark,
      'is_default': isDefault,
    };
  }
}
