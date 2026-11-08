part of 'checkout_screen.dart';

extension _CheckoutSections on _CheckoutScreenState {
  List<Widget> _deliveryAddressSection(
    CheckoutState checkoutState,
    Address? selectedAddress,
  ) {
    return [
      // ==================================
      // DELIVERY ADDRESS
      // ==================================
      const _SectionTitle(title: 'Delivery address'),

      const SizedBox(height: 14),

      InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const AddressSelectionScreen();
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              _ContainerIcon(icon: _getAddressIcon(selectedAddress?.label)),
              const SizedBox(width: 14),
              Expanded(
                child: selectedAddress == null
                    ? const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add delivery address',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF171717),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Choose where you want your order delivered',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  selectedAddress.label,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF171717),
                                  ),
                                ),
                              ),
                              if (selectedAddress.isDefault) ...[
                                const SizedBox(width: 7),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE6D5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'DEFAULT',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFEE7424),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedAddress.addressLine,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              color: Color(0xFF777777),
                            ),
                          ),
                          if (_buildAddressDetails(
                            selectedAddress,
                          ).isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _buildAddressDetails(selectedAddress),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF999999),
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 28),

      const _SectionTitle(title: 'Order preferences'),
      const SizedBox(height: 6),
      const Text(
        'Tell us how to handle replacements and delivery.',
        style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
      ),
      const SizedBox(height: 14),
      _PreferenceDropdown<SubstitutionPreference>(
        title: 'If an item is out of stock',
        value: checkoutState.substitutionPreference,
        items: const {
          SubstitutionPreference.replaceAutomatically: 'Replace automatically',
          SubstitutionPreference.contactMe: 'Contact me first',
          SubstitutionPreference.removeItem: 'Remove the item',
        },
        onChanged: (preference) => ref
            .read(checkoutProvider.notifier)
            .selectSubstitutionPreference(preference),
      ),
      const SizedBox(height: 12),
      _PreferenceDropdown<String>(
        title: 'Delivery instruction',
        value: checkoutState.deliveryInstruction,
        items: const {
          'Call on arrival': 'Call on arrival',
          'Leave at the door': 'Leave at the door',
          'Leave with doorman': 'Leave with doorman',
          'Do not ring the bell': 'Do not ring the bell',
        },
        onChanged: (instruction) => ref
            .read(checkoutProvider.notifier)
            .selectDeliveryInstruction(instruction),
      ),
      const SizedBox(height: 28),
    ];
  }

  List<Widget> _deliveryTimeSection(DeliveryScheduleState deliverySchedule) {
    return [
      // ==================================
      // DELIVERY TIME
      // ==================================
      const _SectionTitle(title: 'Delivery time'),

      const SizedBox(height: 6),

      const Text(
        'Choose when you want your order delivered.',
        style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
      ),

      const SizedBox(height: 14),

      InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const DeliveryScheduleScreen();
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: deliverySchedule.isComplete
                  ? const Color(0xFFEE7424)
                  : Colors.transparent,
              width: 1.3,
            ),
          ),
          child: Row(
            children: [
              const _ContainerIcon(icon: Icons.calendar_month_outlined),
              const SizedBox(width: 14),
              Expanded(
                child: deliverySchedule.isComplete
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selected delivery time',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF777777),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _deliveryDateLabel(deliverySchedule),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF171717),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            deliverySchedule.selectedTimeSlot!.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEE7424),
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose delivery time',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF171717),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Today, tomorrow or the next available day',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF999999),
              ),
            ],
          ),
        ),
      ),

      if (deliverySchedule.isComplete) ...[
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4EC),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFEE7424),
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your order will be prepared based on your selected delivery slot. Live tracking will start when your delivery begins.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Color(0xFF777777),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      const SizedBox(height: 28),
    ];
  }
}
