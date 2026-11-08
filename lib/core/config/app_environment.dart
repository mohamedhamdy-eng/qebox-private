import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;

import '../../firebase_options.dart';

enum AppEnvironment { development, production }

abstract final class AppFirebaseOptions {
  static const _environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: kReleaseMode ? 'production' : 'development',
  );

  static AppEnvironment get environment => _environment == 'production'
      ? AppEnvironment.production
      : AppEnvironment.development;

  static FirebaseOptions get currentPlatform {
    if (environment == AppEnvironment.production) {
      return DefaultFirebaseOptions.currentPlatform;
    }

    return const FirebaseOptions(
      apiKey: 'AIzaSyCPEjF0P8fBtAAwuuTQbM-9a1w-3AyHpWI',
      appId: '1:351461836187:android:45b864ca9bd85229f60d3e',
      messagingSenderId: '351461836187',
      projectId: 'qeboxprivate-dev',
      authDomain: 'qeboxprivate-dev.firebaseapp.com',
      storageBucket: 'qeboxprivate-dev.firebasestorage.app',
    );
  }
}
