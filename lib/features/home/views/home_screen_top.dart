part of 'home_screen.dart';

extension _HomeTopSections on _HomeScreenState {
  List<Widget> _headerSection() {
    return [
      // =====================================================
      // HEADER
      // =====================================================
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Qebox',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171717),
            ),
          ),
          InkWell(
            onTap: _openAccount,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, color: Color(0xFF171717)),
            ),
          ),
        ],
      ),

      const SizedBox(height: 18),
    ];
  }

  List<Widget> _deliveryAddressSection(Address? selectedAddress) {
    return [
      // =====================================================
      // DELIVERY ADDRESS
      // =====================================================
      InkWell(
        onTap: _openAddressSelection,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
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
                  color: const Color(0xFFFFE6D5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  selectedAddress?.label.toLowerCase() == 'work'
                      ? Icons.work_outline_rounded
                      : selectedAddress?.label.toLowerCase() == 'other'
                      ? Icons.place_outlined
                      : Icons.location_on_outlined,
                  color: const Color(0xFFEE7424),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('Delivering to'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      selectedAddress == null
                          ? tr('Choose address')
                          : tr(selectedAddress.label),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF171717),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      selectedAddress?.addressLine ??
                          tr('Add your delivery address'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF171717),
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 22),
    ];
  }
}
