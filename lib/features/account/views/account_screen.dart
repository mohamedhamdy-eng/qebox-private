import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../addresses/views/address_selection_screen.dart';
import '../../favorites/views/favorites_screen.dart';
import '../../chat/views/q_bot_screen.dart';
import '../../orders/views/orders_screen.dart';
import '../../rewards/views/rewards_screen.dart';
import '../repositories/phone_auth_repository.dart';
import '../viewmodels/customer_view_model.dart';
import '../../../core/l10n/app_language.dart';

part 'account_screen_auth.dart';
part 'account_screen_profile.dart';
part 'account_screen_widgets.dart';

class AccountScreen extends ConsumerStatefulWidget {
  final bool closeAfterAuthentication;

  const AccountScreen({super.key, this.closeAfterAuthentication = false});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  void _applyState(VoidCallback change) => setState(change);

  bool _isSignUp = false;

  bool _signInOtpSent = false;
  bool _signUpOtpSent = false;

  bool _isLoading = false;
  String? _signInVerificationId;
  String? _signUpVerificationId;

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final _signInPhoneController = TextEditingController();
  final _signInOtpController = TextEditingController();

  final _signUpNameController = TextEditingController();
  final _signUpPhoneController = TextEditingController();
  final _signUpOtpController = TextEditingController();

  // =====================================================
  // VALIDATION
  // =====================================================

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return tr('Please enter your full name');
    }

    if (name.length < 3) {
      return tr('Please enter a valid name');
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return tr('Please enter your mobile number');
    }

    final phoneRegex = RegExp(r'^(010|011|012|015)[0-9]{8}$');

    if (!phoneRegex.hasMatch(phone)) {
      return tr('Please enter a valid Egyptian mobile number');
    }

    return null;
  }

  String? _validateOtp(String? value) {
    final otp = value?.trim() ?? '';

    if (otp.isEmpty) {
      return tr('Please enter the verification code');
    }

    if (otp.length != 6) {
      return tr('Verification code must be 6 digits');
    }

    return null;
  }

  String _toInternationalPhone(String phone) {
    return '+20${phone.substring(1)}';
  }

  String _firebaseErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      if (error.message?.contains('BILLING_NOT_ENABLED') == true) {
        return 'Real SMS verification requires Firebase billing. '
            'Use the configured test phone number while developing.';
      }
      switch (error.code) {
        case 'invalid-phone-number':
          return tr('The mobile number is invalid.');
        case 'invalid-verification-code':
          return tr('Invalid verification code.');
        case 'session-expired':
          return tr('The verification code expired. Please request a new one.');
        case 'too-many-requests':
          return tr('Too many attempts. Please try again later.');
        case 'quota-exceeded':
          return tr(
            'The SMS limit has been reached. Please try again tomorrow.',
          );
        case 'network-request-failed':
          return tr('Check your internet connection and try again.');
      }
      return error.message ?? tr('Phone authentication failed.');
    }
    return tr('Phone authentication failed. Please try again.');
  }

  // =====================================================
  // SIGN IN - SEND OTP
  // =====================================================

  Future<void> _sendSignInOtp() async {
    FocusScope.of(context).unfocus();

    if (!_signInFormKey.currentState!.validate()) {
      return;
    }

    final phone = _signInPhoneController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final session = await ref
          .read(phoneAuthRepositoryProvider)
          .sendCode(_toInternationalPhone(phone));
      if (!mounted) return;

      if (session.automaticallyVerifiedUserId != null) {
        ref
            .read(customerProvider.notifier)
            .authenticateWithFirebase(
              userId: session.automaticallyVerifiedUserId!,
              phone: phone,
            );
        setState(() => _isLoading = false);
        await _authenticationCompleted();
        return;
      }

      setState(() {
        _isLoading = false;
        _signInOtpSent = true;
        _signInVerificationId = session.verificationId;
      });
      _showMessage(tr('Verification code sent to {0}', [phone]));
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(_firebaseErrorMessage(error));
    }
  }

  // =====================================================
  // SIGN IN - VERIFY
  // =====================================================

  Future<void> _verifySignIn() async {
    FocusScope.of(context).unfocus();

    final otp = _signInOtpController.text.trim();

    final otpError = _validateOtp(otp);

    if (otpError != null) {
      _showMessage(otpError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final verificationId = _signInVerificationId;
    if (verificationId == null) {
      setState(() => _isLoading = false);
      _showMessage(tr('Please request a new verification code.'));
      return;
    }

    try {
      final userId = await ref
          .read(phoneAuthRepositoryProvider)
          .verifyCode(verificationId: verificationId, smsCode: otp);
      if (!mounted) return;
      ref
          .read(customerProvider.notifier)
          .authenticateWithFirebase(
            userId: userId,
            phone: _signInPhoneController.text.trim(),
          );
      setState(() => _isLoading = false);
      await _authenticationCompleted();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(_firebaseErrorMessage(error));
    }
  }

  // =====================================================
  // SIGN UP - SEND OTP
  // =====================================================

  Future<void> _sendSignUpOtp() async {
    FocusScope.of(context).unfocus();

    if (!_signUpFormKey.currentState!.validate()) {
      return;
    }

    final phone = _signUpPhoneController.text.trim();

    final exists = ref.read(customerProvider.notifier).isPhoneRegistered(phone);

    if (exists) {
      _showMessage(
        tr('This mobile number already has an account. Please Sign In.'),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final session = await ref
          .read(phoneAuthRepositoryProvider)
          .sendCode(_toInternationalPhone(phone));
      if (!mounted) return;

      if (session.automaticallyVerifiedUserId != null) {
        ref
            .read(customerProvider.notifier)
            .authenticateWithFirebase(
              userId: session.automaticallyVerifiedUserId!,
              phone: phone,
              name: _signUpNameController.text,
            );
        setState(() => _isLoading = false);
        await _authenticationCompleted();
        return;
      }

      setState(() {
        _isLoading = false;
        _signUpOtpSent = true;
        _signUpVerificationId = session.verificationId;
      });
      _showMessage(tr('Verification code sent to {0}', [phone]));
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(_firebaseErrorMessage(error));
    }
  }

  // =====================================================
  // SIGN UP - VERIFY
  // =====================================================

  Future<void> _verifySignUp() async {
    FocusScope.of(context).unfocus();

    final otp = _signUpOtpController.text.trim();

    final otpError = _validateOtp(otp);

    if (otpError != null) {
      _showMessage(otpError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final verificationId = _signUpVerificationId;
    if (verificationId == null) {
      setState(() => _isLoading = false);
      _showMessage(tr('Please request a new verification code.'));
      return;
    }

    try {
      final userId = await ref
          .read(phoneAuthRepositoryProvider)
          .verifyCode(verificationId: verificationId, smsCode: otp);
      if (!mounted) return;
      ref
          .read(customerProvider.notifier)
          .authenticateWithFirebase(
            userId: userId,
            phone: _signUpPhoneController.text.trim(),
            name: _signUpNameController.text.trim(),
          );
      setState(() => _isLoading = false);
      await _authenticationCompleted();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(_firebaseErrorMessage(error));
    }
  }

  Future<void> _continueWithoutSms({required bool signUp}) async {
    FocusScope.of(context).unfocus();
    final form = signUp
        ? _signUpFormKey.currentState
        : _signInFormKey.currentState;
    if (form?.validate() != true) return;

    final phone = signUp
        ? _signUpPhoneController.text.trim()
        : _signInPhoneController.text.trim();
    final name = signUp ? _signUpNameController.text.trim() : null;
    await ref.read(phoneAuthRepositoryProvider).ensureDevelopmentSession();
    if (!mounted) return;
    ref
        .read(customerProvider.notifier)
        .authenticateWithFirebase(
          userId: 'DEV-$phone',
          phone: phone,
          name: name,
        );
    await _authenticationCompleted();
  }

  Future<void> _loginWithDevelopmentAccount() async {
    await ref.read(phoneAuthRepositoryProvider).ensureDevelopmentSession();
    if (!mounted) return;
    ref
        .read(customerProvider.notifier)
        .authenticateWithFirebase(
          userId: 'DEV-QEBOX-ACCOUNT',
          phone: '01000000000',
          name: 'Qebox Tester',
        );
    await _authenticationCompleted();
  }

  // =====================================================
  // AUTH COMPLETED
  // =====================================================

  Future<void> _authenticationCompleted() async {
    if (!mounted) return;

    if (widget.closeAfterAuthentication) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _signInOtpSent = false;
      _signUpOtpSent = false;
    });
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> _logout() async {
    await ref.read(phoneAuthRepositoryProvider).signOut();
    if (!mounted) return;
    ref.read(customerProvider.notifier).logout();

    _signInPhoneController.clear();
    _signInOtpController.clear();

    _signUpNameController.clear();
    _signUpPhoneController.clear();
    _signUpOtpController.clear();

    setState(() {
      _isSignUp = false;
      _signInOtpSent = false;
      _signUpOtpSent = false;
    });
  }

  // =====================================================
  // MESSAGE
  // =====================================================

  Future<void> _chooseLanguage() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(tr(tr('Language'))),
        children: [
          for (final (code, label) in [
            ('device', tr(tr('Use device language'))),
            ('en', 'English'),
            ('ar', 'العربية'),
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, code),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(label),
              ),
            ),
        ],
      ),
    );
    if (choice == null) return;
    ref
        .read(languageProvider.notifier)
        .select(choice == 'device' ? null : Locale(choice));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _signInPhoneController.dispose();
    _signInOtpController.dispose();

    _signUpNameController.dispose();
    _signUpPhoneController.dispose();
    _signUpOtpController.dispose();

    super.dispose();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F3),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: tr(tr('Language')),
            icon: const Icon(Icons.language_rounded, color: Color(0xFF171717)),
            onPressed: _chooseLanguage,
          ),
        ],
        title: Text(
          customerState.isLoggedIn ? tr('My Account') : tr('Account'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF171717),
          ),
        ),
      ),
      body: SafeArea(
        child: customerState.isLoggedIn
            ? _buildLoggedInAccount()
            : _buildAuthentication(),
      ),
    );
  }

  // =====================================================
  // AUTH SCREEN
  // =====================================================

  // =====================================================
  // SIGN IN
  // =====================================================

  // =====================================================
  // SIGN UP
  // =====================================================

  // =====================================================
  // LOGGED IN ACCOUNT
  // =====================================================

  // =====================================================
  // INPUT
  // =====================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: const Color(0xFF777777)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE8E5E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFEE7424), width: 1.5),
      ),
    );
  }
}
