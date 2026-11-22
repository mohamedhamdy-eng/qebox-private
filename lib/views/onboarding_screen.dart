import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/views/home_screen.dart';
import '../features/onboarding/viewmodels/onboarding_view_model.dart';
import '../core/l10n/app_language.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  Future<void> goToHome(BuildContext context, WidgetRef ref) async {
    await ref.read(onboardingProvider.notifier).complete();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 18),

                      // Top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Qebox',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              goToHome(context, ref);
                            },
                            child: Text(
                              tr('Skip'),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Product image
                      Container(
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDE7),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/grocery-box.png',
                                width: 260,
                                height: 240,
                                fit: BoxFit.contain,
                              ),
                            ),
                            PositionedDirectional(
                              top: 18,
                              start: 18,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEE7424),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tr('25% OFF FRESH'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          tr('A SMARTER WAY TO SHOP'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: Color(0xFFEE7424),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          tr('Everything you need.\nOne Qebox.'),
                          style: const TextStyle(
                            fontSize: 34,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF171717),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          tr(
                            'Fresh groceries, daily essentials and members-only savings—delivered to your door.',
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _Feature(
                              icon: Icons.eco_outlined,
                              text: tr('Fresh daily'),
                            ),
                          ),
                          Expanded(
                            child: _Feature(
                              icon: Icons.bolt_outlined,
                              text: tr('Fast delivery'),
                            ),
                          ),
                          Expanded(
                            child: _Feature(
                              icon: Icons.local_offer_outlined,
                              text: tr('Big savings'),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            goToHome(context, ref);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF171717),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            tr('Explore Qebox  →'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Feature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: const Color(0xFFEE7424)),
        const SizedBox(height: 7),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
