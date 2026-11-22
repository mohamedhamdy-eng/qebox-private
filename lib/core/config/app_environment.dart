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

  /// The computer that runs the Firebase emulators, for example
  /// `--dart-define=EMULATOR_HOST=192.168.1.20`. Ignored in release builds.
  static const emulatorHost = kReleaseMode
      ? ''
      : String.fromEnvironment('EMULATOR_HOST');

  static bool get usesEmulators => emulatorHost.isNotEmpty;

  /// The ports in firebase.json.
  static const authEmulatorPort = 9098;
  static const firestoreEmulatorPort = 8086;
  static const functionsEmulatorPort = 5002;

  static FirebaseOptions get currentPlatform {
    if (environment == AppEnvironment.production && !usesEmulators) {
      return DefaultFirebaseOptions.currentPlatform;
    }

    return FirebaseOptions(
      apiKey: 'AIzaSyCPEjF0P8fBtAAwuuTQbM-9a1w-3AyHpWI',
      appId: '1:351461836187:android:45b864ca9bd85229f60d3e',
      messagingSenderId: '351461836187',
      // demo- projects exist only on the emulators.
      projectId: usesEmulators ? 'demo-qebox' : 'qeboxprivate-dev',
      authDomain: 'qeboxprivate-dev.firebaseapp.com',
      storageBucket: 'qeboxprivate-dev.firebasestorage.app',
    );
  }
}
