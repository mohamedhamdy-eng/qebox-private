import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/address_view_model.dart';
import 'add_address_screen.dart';

class AddressSelectionScreen extends ConsumerWidget {
  const AddressSelectionScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final addressState = ref.watch(addressProvider);

    final selectedAddress = addressState.selectedAddress;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F3),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Delivery Address',
          style: TextStyle(
            color: Color(0xFF171717),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ==========================================
              // ADD NEW ADDRESS
              // ==========================================

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return const AddAddressScreen();
                        },
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add_rounded,
                  ),
                  label: const Text(
                    'Add new address',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(
                      0xFFEE7424,
                    ),
                    side: const BorderSide(
                      color: Color(
                        0xFFEE7424,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        28,
                      ),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // ADDRESS LIST
              // ==========================================

              Expanded(
                child: addressState.addresses.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              size: 70,
                              color: Color(
                                0xFFCCCCCC,
                              ),
                            ),
                            SizedBox(
                              height: 14,
                            ),
                            Text(
                              'No addresses added yet.',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(
                                  0xFF777777,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: addressState.addresses.length,
                        separatorBuilder: (
                          context,
                          index,
                        ) {
                          return const SizedBox(
                            height: 14,
                          );
                        },
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          final address = addressState.addresses[index];

                          final isSelected = selectedAddress?.id == address.id;

                          return InkWell(
                            borderRadius: BorderRadius.circular(
                              22,
                            ),
                            onTap: () {
                              ref
                                  .read(
                                    addressProvider.notifier,
                                  )
                                  .selectAddress(
                                    address.id,
                                  );

                              Navigator.pop(
                                context,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(
                                16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  22,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(
                                          0xFFEE7424,
                                        )
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // ==================================
                                  // ICON
                                  // ==================================

                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFFE6D5,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        15,
                                      ),
                                    ),
                                    child: Icon(
                                      _getAddressIcon(
                                        address.label,
                                      ),
                                      color: const Color(
                                        0xFFEE7424,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 14,
                                  ),

                                  // ==================================
                                  // ADDRESS INFO
                                  // ==================================

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                address.label,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(
                                                    0xFF171717,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (address.isDefault) ...[
                                              const SizedBox(
                                                width: 7,
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 7,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFFE6D5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'DEFAULT',
                                                  style: TextStyle(
                                                    color: Color(
                                                      0xFFEE7424,
                                                    ),
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          address.addressLine,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            height: 1.3,
                                            color: Color(
                                              0xFF777777,
                                            ),
                                          ),
                                        ),
                                        if (address.building != null) ...[
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            _buildAddressDetails(
                                              building: address.building,
                                              floor: address.floor,
                                              apartment: address.apartment,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(
                                                0xFF999999,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 8,
                                  ),

                                  // ==================================
                                  // SELECTED ICON
                                  // ==================================

                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: isSelected
                                        ? const Color(
                                            0xFFEE7424,
                                          )
                                        : const Color(
                                            0xFFCCCCCC,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAddressIcon(
    String label,
  ) {
    switch (label.toLowerCase()) {
      case 'work':
        return Icons.work_outline_rounded;

      case 'other':
        return Icons.place_outlined;

      case 'home':
      default:
        return Icons.home_outlined;
    }
  }

  String _buildAddressDetails({
    String? building,
    String? floor,
    String? apartment,
  }) {
    final parts = <String>[];

    if (building != null && building.isNotEmpty) {
      parts.add(
        'Building $building',
      );
    }

    if (floor != null && floor.isNotEmpty) {
      parts.add(
        'Floor $floor',
      );
    }

    if (apartment != null && apartment.isNotEmpty) {
      parts.add(
        'Apartment $apartment',
      );
    }

    return parts.join(' • ');
  }
}
