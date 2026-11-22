import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneVerificationSession {
  const PhoneVerificationSession({
    required this.verificationId,
    this.automaticallyVerifiedUserId,
  });

  final String verificationId;
  final String? automaticallyVerifiedUserId;
}

abstract interface class PhoneAuthRepository {
  Future<PhoneVerificationSession> sendCode(String phoneNumber);

  Future<String> verifyCode({
    required String verificationId,
    required String smsCode,
  });

  Future<void> signOut();

  /// Starts an anonymous session for debug-only logins.
  Future<void> ensureDevelopmentSession();
}

class FirebasePhoneAuthRepository implements PhoneAuthRepository {
  FirebasePhoneAuthRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Future<PhoneVerificationSession> sendCode(String phoneNumber) {
    final completer = Completer<PhoneVerificationSession>();

    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        try {
          final result = await _firebaseAuth.signInWithCredential(credential);
          final userId = result.user?.uid;
          if (!completer.isCompleted && userId != null) {
            completer.complete(
              PhoneVerificationSession(
                verificationId: credential.verificationId ?? '',
                automaticallyVerifiedUserId: userId,
              ),
            );
          }
        } on FirebaseAuthException catch (error) {
          if (!completer.isCompleted) completer.completeError(error);
        }
      },
      verificationFailed: (error) {
        if (!completer.isCompleted) completer.completeError(error);
      },
      codeSent: (verificationId, resendToken) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneVerificationSession(verificationId: verificationId),
          );
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneVerificationSession(verificationId: verificationId),
          );
        }
      },
    );

    return completer.future;
  }

  @override
  Future<String> verifyCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _firebaseAuth.signInWithCredential(credential);
    final userId = result.user?.uid;
    if (userId == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'Firebase did not return an authenticated user.',
      );
    }
    return userId;
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  @override
  Future<void> ensureDevelopmentSession() async {
    if (_firebaseAuth.currentUser == null) {
      await _firebaseAuth.signInAnonymously();
    }
  }
}

final phoneAuthRepositoryProvider = Provider<PhoneAuthRepository>(
  (ref) => throw UnimplementedError(
    'phoneAuthRepositoryProvider must be overridden in main.',
  ),
);
