part of 'account_screen.dart';

extension _AccountProfileView on _AccountScreenState {
  Widget _buildLoggedInAccount() {
    final customer = ref.watch(customerProvider).customer!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE6D5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFFEE7424),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF171717),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        customer.phone,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _AccountInfoCard(
            title: 'Personal information',
            children: [
              _InfoRow(title: 'Full name', value: customer.name),
              _InfoRow(title: 'Mobile', value: customer.phone),
              _InfoRow(title: 'Customer ID', value: customer.id),
            ],
          ),
          const SizedBox(height: 16),
          _AccountMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Addresses',
            subtitle: 'Manage your delivery addresses',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return const AddressSelectionScreen();
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _AccountMenuItem(
            icon: Icons.receipt_long_outlined,
            title: 'My Orders',
            subtitle: 'View your current and previous orders',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return const OrdersScreen();
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _AccountMenuItem(
            icon: Icons.favorite_border_rounded,
            title: 'My Favorites',
            subtitle: 'View products you saved',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return const FavoritesScreen();
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _AccountMenuItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Wallet',
            subtitle: 'Qebox wallet balance',
            onTap: () {
              _showMessage('Wallet will be connected later');
            },
          ),
          const SizedBox(height: 12),
          _AccountMenuItem(
            icon: Icons.stars_outlined,
            title: 'Points & Loyalty',
            subtitle: 'Your Qebox rewards',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const RewardsScreen()));
            },
          ),
          const SizedBox(height: 12),
          _AccountMenuItem(
            icon: Icons.smart_toy_outlined,
            title: 'Q Bot',
            subtitle: 'Ask your Qebox AI assistant',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const QBotScreen()));
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE53935),
                side: const BorderSide(color: Color(0xFFE53935)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
