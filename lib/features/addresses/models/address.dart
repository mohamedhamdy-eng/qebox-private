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
}