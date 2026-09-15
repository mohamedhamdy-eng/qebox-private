import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/viewmodels/customer_view_model.dart';
import '../../orders/viewmodels/orders_view_model.dart';

class RewardOption {
  const RewardOption(
      this.id, this.name, this.description, this.points, this.icon);
  final String id;
  final String name;
  final String description;
  final int points;
  final IconData icon;
}

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  final Set<String> _redeemed = {};

  static const rewards = [
    RewardOption(
        'delivery',
        'Free grocery delivery',
        'Your next standard delivery is on us.',
        300,
        Icons.local_shipping_outlined),
    RewardOption('voucher25', 'EGP 25 off your basket',
        'Use it on an order of EGP 150 or more.', 500, Icons.sell_outlined),
    RewardOption('fresh', 'Fresh fruit & veg box',
        'A seasonal selection for your kitchen.', 1500, Icons.eco_outlined),
    RewardOption(
        'pantry',
        'Everyday pantry trio',
        'Milk, snacks and cooking essentials.',
        2500,
        Icons.inventory_2_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final customer = ref.watch(customerProvider).customer;
    final earned = ref.watch(ordersProvider).fold<double>(
          0,
          (total, order) => total + order.total,
        );
    final spent = rewards
        .where((reward) => _redeemed.contains(reward.id))
        .fold<int>(0, (total, reward) => total + reward.points);
    final points = (500 + earned.floor() - spent).clamp(0, 999999);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF2),
        surfaceTintColor: Colors.transparent,
        title: const Text('Q Rewards',
            style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: Text('$points pts',
                  style: const TextStyle(
                      color: Color(0xFFEE7424), fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF171717), Color(0xFF343434)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x28000000),
                    blurRadius: 18,
                    offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFFEE7424),
                      child: Text('Q',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900)),
                    ),
                    SizedBox(width: 10),
                    Text('QEBOX REWARDS',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                    child: _MemberCode(value: customer?.id ?? 'QEBOX-GUEST')),
                const SizedBox(height: 18),
                const Text('Scan. Shop. Get rewarded.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                const Text('Show your Q at checkout to collect points.',
                    style: TextStyle(color: Color(0xFFCCCCCC))),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6D5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded,
                    color: Color(0xFFEE7424), size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$points available points',
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                      const Text('One point is earned for each EGP spent.',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF777777))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text('Pick your next reward',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text('Turn your points into everyday savings.',
              style: TextStyle(color: Color(0xFF777777))),
          const SizedBox(height: 15),
          ...rewards.map((reward) {
            final claimed = _redeemed.contains(reward.id);
            final locked = reward.points > points && !claimed;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEDE7DF)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE6D5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(reward.icon, color: const Color(0xFFEE7424)),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(reward.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(reward.description,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF777777))),
                          const SizedBox(height: 6),
                          Text('${reward.points} pts',
                              style: const TextStyle(
                                  color: Color(0xFFEE7424),
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: locked || claimed
                          ? null
                          : () => setState(() => _redeemed.add(reward.id)),
                      child: Text(claimed
                          ? 'Claimed'
                          : locked
                              ? 'Locked'
                              : 'Redeem'),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MemberCode extends StatelessWidget {
  const _MemberCode({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    final seed = value.codeUnits.fold<int>(0, (total, code) => total + code);
    return Container(
      width: 136,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          SizedBox(
            height: 92,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9),
              itemCount: 81,
              itemBuilder: (_, index) => Container(
                margin: const EdgeInsets.all(1),
                color:
                    ((index * 17 + seed) % 5) < 2 ? Colors.black : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(value.length > 14 ? value.substring(0, 14) : value,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
