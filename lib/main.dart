import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/l10n/app_language.dart';
import 'core/theme/qebox_theme.dart';
import 'core/config/app_environment.dart';
import 'features/account/repositories/customer_repository.dart';
import 'features/account/repositories/phone_auth_repository.dart';
import 'features/account/viewmodels/customer_view_model.dart';
import 'features/addresses/repositories/address_repository.dart';
import 'features/addresses/viewmodels/address_view_model.dart';
import 'features/cart/repositories/cart_repository.dart';
import 'features/cart/viewmodels/cart_view_model.dart';
import 'features/checkout/repositories/coupon_repository.dart';
import 'features/checkout/viewmodels/checkout_view_model.dart';
import 'features/chat/repositories/chat_repository.dart';
import 'features/chat/viewmodels/chat_view_model.dart';
import 'features/chat/widgets/q_bot_launcher.dart';
import 'features/favorites/repositories/favorites_repository.dart';
import 'features/favorites/viewmodels/favorites_view_model.dart';
import 'features/orders/repositories/orders_repository.dart';
import 'features/orders/viewmodels/orders_view_model.dart';
import 'features/products/repositories/catalog_repository.dart';
import 'features/products/viewmodels/catalog_view_model.dart';
import 'features/onboarding/repositories/onboarding_repository.dart';
import 'features/onboarding/viewmodels/onboarding_view_model.dart';
import 'views/splash_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseApp = await _initializeFirebase();
  final firebaseAuth = FirebaseAuth.instanceFor(app: firebaseApp);
  final firestore = FirebaseFirestore.instanceFor(app: firebaseApp);
  if (AppFirebaseOptions.environment == AppEnvironment.development &&
      firebaseAuth.currentUser == null) {
    try {
      await firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Anonymous Firebase sign-in failed: ${error.code} - ${error.message}',
      );
    }
  }
  final preferences = await SharedPreferences.getInstance();
  final functions = FirebaseFunctions.instanceFor(app: firebaseApp);

  runApp(
    ProviderScope(
      overrides: [
        languageProvider.overrideWith((ref) => LanguageViewModel(preferences)),
        customerProvider.overrideWith(
          (ref) => CustomerViewModel(
            FirestoreCustomerRepository(
              local: LocalCustomerRepository(preferences),
              firestore: firestore,
              auth: firebaseAuth,
            ),
          ),
        ),
        phoneAuthRepositoryProvider.overrideWithValue(
          FirebasePhoneAuthRepository(firebaseAuth),
        ),
        cartProvider.overrideWith((ref) {
          final viewModel = CartViewModel(LocalCartRepository(preferences));
          ref.listen<CatalogState>(catalogProvider, (previous, next) {
            if (next.productsConfirmed && next.bundlesConfirmed) {
              viewModel.syncWithCatalog(
                products: next.products,
                bundles: next.bundles,
              );
            }
          }, fireImmediately: true);
          return viewModel;
        }),
        addressProvider.overrideWith((ref) {
          final viewModel = AddressViewModel(
            FirestoreAddressRepository(
              local: LocalAddressRepository(preferences),
              firestore: firestore,
              auth: firebaseAuth,
            ),
            ref.read(customerProvider).customer?.id,
          );
          ref.listen<CustomerState>(customerProvider, (previous, next) {
            viewModel.switchCustomer(next.customer?.id);
          });
          return viewModel;
        }),
        favoritesProvider.overrideWith((ref) {
          final viewModel = FavoritesViewModel(
            FirestoreFavoritesRepository(
              local: LocalFavoritesRepository(preferences),
              firestore: firestore,
              auth: firebaseAuth,
            ),
          );
          ref.listen<CustomerState>(customerProvider, (previous, next) {
            unawaited(viewModel.syncCustomer(next.customer?.id));
          }, fireImmediately: true);
          return viewModel;
        }),
        onboardingProvider.overrideWith(
          (ref) => OnboardingViewModel(LocalOnboardingRepository(preferences)),
        ),
        ordersProvider.overrideWith((ref) {
          final viewModel = OrdersViewModel(
            FirestoreOrdersRepository(
              local: LocalOrdersRepository(preferences),
              firestore: firestore,
              auth: firebaseAuth,
              functions: functions,
            ),
            ref.read(customerProvider).customer?.id,
          );
          ref.listen<CustomerState>(customerProvider, (previous, next) {
            viewModel.switchCustomer(next.customer?.id);
          });
          return viewModel;
        }),
        catalogProvider.overrideWith(
          (ref) => CatalogViewModel(FirestoreCatalogRepository(firestore)),
        ),
        couponRepositoryProvider.overrideWithValue(
          CallableCouponRepository(functions),
        ),
        chatRepositoryProvider.overrideWithValue(
          FirebaseQBotRepository(functions: functions, auth: firebaseAuth),
        ),
      ],
      child: const QeboxPrivateApp(),
    ),
  );
}

Future<FirebaseApp> _initializeFirebase() async {
  final options = AppFirebaseOptions.currentPlatform;
  const developmentAppName = 'qebox-development';

  if (AppFirebaseOptions.environment == AppEnvironment.development) {
    for (final app in Firebase.apps) {
      if (app.name == developmentAppName) return app;
    }
    return Firebase.initializeApp(name: developmentAppName, options: options);
  }

  return Firebase.initializeApp(options: options);
}

class QeboxPrivateApp extends ConsumerWidget {
  const QeboxPrivateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Qebox Private',
      theme: buildQeboxTheme(),
      locale: ref.watch(languageProvider),
      supportedLocales: supportedAppLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => LanguageScope(
        child: QBotLauncher(
          navigatorKey: rootNavigatorKey,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      home: SplashScreen(onboardingCompleted: ref.watch(onboardingProvider)),
    );
  }
}
