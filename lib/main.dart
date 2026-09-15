import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/account/repositories/customer_repository.dart';
import 'features/account/repositories/phone_auth_repository.dart';
import 'features/account/viewmodels/customer_view_model.dart';
import 'features/addresses/repositories/address_repository.dart';
import 'features/addresses/viewmodels/address_view_model.dart';
import 'features/cart/repositories/cart_repository.dart';
import 'features/cart/viewmodels/cart_view_model.dart';
import 'features/chat/widgets/q_bot_launcher.dart';
import 'features/favorites/repositories/favorites_repository.dart';
import 'features/favorites/viewmodels/favorites_view_model.dart';
import 'features/orders/repositories/orders_repository.dart';
import 'features/orders/viewmodels/orders_view_model.dart';
import 'features/onboarding/repositories/onboarding_repository.dart';
import 'features/onboarding/viewmodels/onboarding_view_model.dart';
import 'views/splash_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        customerProvider.overrideWith(
          (ref) => CustomerViewModel(LocalCustomerRepository(preferences)),
        ),
        phoneAuthRepositoryProvider.overrideWithValue(
          FirebasePhoneAuthRepository(FirebaseAuth.instance),
        ),
        cartProvider.overrideWith(
          (ref) => CartViewModel(LocalCartRepository(preferences)),
        ),
        addressProvider.overrideWith((ref) {
          final viewModel = AddressViewModel(
            LocalAddressRepository(preferences),
            ref.read(customerProvider).customer?.id,
          );
          ref.listen<CustomerState>(customerProvider, (previous, next) {
            viewModel.switchCustomer(next.customer?.id);
          });
          return viewModel;
        }),
        favoritesProvider.overrideWith(
          (ref) => FavoritesViewModel(
            LocalFavoritesRepository(preferences),
          ),
        ),
        onboardingProvider.overrideWith(
          (ref) => OnboardingViewModel(
            LocalOnboardingRepository(preferences),
          ),
        ),
        ordersProvider.overrideWith((ref) {
          final viewModel = OrdersViewModel(
            LocalOrdersRepository(preferences),
            ref.read(customerProvider).customer?.id,
          );
          ref.listen<CustomerState>(customerProvider, (previous, next) {
            viewModel.switchCustomer(next.customer?.id);
          });
          return viewModel;
        }),
      ],
      child: const QeboxPrivateApp(),
    ),
  );
}

class QeboxPrivateApp extends ConsumerWidget {
  const QeboxPrivateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Qebox Private',
      theme: ThemeData(
        useMaterial3: true,
      ),
      builder: (context, child) => QBotLauncher(
        navigatorKey: rootNavigatorKey,
        child: child ?? const SizedBox.shrink(),
      ),
      home: SplashScreen(
        onboardingCompleted: ref.watch(onboardingProvider),
      ),
    );
  }
}
