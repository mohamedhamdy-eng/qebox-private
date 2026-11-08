import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address.dart';
import '../viewmodels/address_view_model.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _areaController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _landmarkController = TextEditingController();

  String _selectedLabel = 'Home';
  bool _makeDefault = false;

  @override
  void dispose() {
    _areaController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final addressLine = '${_areaController.text.trim()}, '
        '${_streetController.text.trim()}';

    final newAddress = Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: _selectedLabel,
      addressLine: addressLine,
      building: _buildingController.text.trim().isEmpty
          ? null
          : _buildingController.text.trim(),
      floor: _floorController.text.trim().isEmpty
          ? null
          : _floorController.text.trim(),
      apartment: _apartmentController.text.trim().isEmpty
          ? null
          : _apartmentController.text.trim(),
      landmark: _landmarkController.text.trim().isEmpty
          ? null
          : _landmarkController.text.trim(),
      isDefault: _makeDefault,
    );

    ref.read(addressProvider.notifier).addAddress(newAddress);

    ref.read(addressProvider.notifier).selectAddress(newAddress.id);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F3),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Add Address',
          style: TextStyle(
            color: Color(0xFF171717),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================================
                // ADDRESS LABEL
                // =====================================

                const Text(
                  'Address label',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF171717),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _LabelButton(
                        title: 'Home',
                        icon: Icons.home_outlined,
                        selected: _selectedLabel == 'Home',
                        onTap: () {
                          setState(() {
                            _selectedLabel = 'Home';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _LabelButton(
                        title: 'Work',
                        icon: Icons.work_outline_rounded,
                        selected: _selectedLabel == 'Work',
                        onTap: () {
                          setState(() {
                            _selectedLabel = 'Work';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _LabelButton(
                        title: 'Other',
                        icon: Icons.place_outlined,
                        selected: _selectedLabel == 'Other',
                        onTap: () {
                          setState(() {
                            _selectedLabel = 'Other';
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // =====================================
                // ADDRESS DETAILS
                // =====================================

                const Text(
                  'Address details',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF171717),
                  ),
                ),

                const SizedBox(height: 14),

                _AddressField(
                  controller: _areaController,
                  label: 'Area',
                  hint: 'Example: Smouha',
                  icon: Icons.location_city_outlined,
                  requiredField: true,
                ),

                const SizedBox(height: 14),

                _AddressField(
                  controller: _streetController,
                  label: 'Street',
                  hint: 'Street name',
                  icon: Icons.signpost_outlined,
                  requiredField: true,
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _AddressField(
                        controller: _buildingController,
                        label: 'Building',
                        hint: '12',
                        icon: Icons.apartment_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AddressField(
                        controller: _floorController,
                        label: 'Floor',
                        hint: '3',
                        icon: Icons.stairs_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _AddressField(
                  controller: _apartmentController,
                  label: 'Apartment',
                  hint: 'Apartment number',
                  icon: Icons.door_front_door_outlined,
                ),

                const SizedBox(height: 14),

                _AddressField(
                  controller: _landmarkController,
                  label: 'Landmark',
                  hint: 'Example: Near the supermarket',
                  icon: Icons.flag_outlined,
                ),

                const SizedBox(height: 24),

                // =====================================
                // DEFAULT ADDRESS
                // =====================================

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFE6D5,
                          ),
                          borderRadius: BorderRadius.circular(
                            14,
                          ),
                        ),
                        child: const Icon(
                          Icons.star_outline_rounded,
                          color: Color(0xFFEE7424),
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Make default address',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(
                                  0xFF171717,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              'Use this address automatically for future orders',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(
                                  0xFF777777,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _makeDefault,
                        activeThumbColor: const Color(
                          0xFFEE7424,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _makeDefault = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // =====================================
      // SAVE BUTTON
      // =====================================

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            18,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 15,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF171717,
                ),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    28,
                  ),
                ),
              ),
              child: const Text(
                'Save Address',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// LABEL BUTTON
// =====================================================

class _LabelButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _LabelButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: selected
              ? const Color(
                  0xFFFFE6D5,
                )
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(
                    0xFFEE7424,
                  )
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(
                      0xFFEE7424,
                    )
                  : const Color(
                      0xFF777777,
                    ),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected
                    ? const Color(
                        0xFFEE7424,
                      )
                    : const Color(
                        0xFF171717,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// INPUT FIELD
// =====================================================

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool requiredField;

  const _AddressField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.requiredField = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (requiredField && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFEE7424),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFEE7424),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
