import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer.dart';
import '../providers/customer_provider.dart';

class CustomerDetailsScreen extends ConsumerStatefulWidget {
  const CustomerDetailsScreen({
    super.key,
  });

  @override
  ConsumerState<CustomerDetailsScreen> createState() =>
      _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState
    extends ConsumerState<CustomerDetailsScreen> {
  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _otpController =
      TextEditingController();

  final GlobalKey<FormState> _detailsFormKey =
      GlobalKey<FormState>();

  final GlobalKey<FormState> _otpFormKey =
      GlobalKey<FormState>();

  bool _otpSent = false;
  bool _isSendingOtp = false;
  bool _isVerifying = false;

  // =====================================================
  // NAME VALIDATION
  // =====================================================

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your full name';
    }

    if (name.length < 3) {
      return 'Please enter a valid name';
    }

    return null;
  }

  // =====================================================
  // PHONE VALIDATION
  // =====================================================

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'Please enter your mobile number';
    }

    final phoneRegex = RegExp(
      r'^(010|011|012|015)[0-9]{8}$',
    );

    if (!phoneRegex.hasMatch(phone)) {
      return 'Please enter a valid Egyptian mobile number';
    }

    return null;
  }

  // =====================================================
  // OTP VALIDATION
  // =====================================================

  String? _validateOtp(String? value) {
    final otp = value?.trim() ?? '';

    if (otp.isEmpty) {
      return 'Please enter the verification code';
    }

    if (otp.length != 6) {
      return 'Verification code must be 6 digits';
    }

    return null;
  }

  // =====================================================
  // SEND OTP
  // =====================================================

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    if (!_detailsFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSendingOtp = true;
    });

    // TEMPORARY
    // Later this will call the real OTP service.
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSendingOtp = false;
      _otpSent = true;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Verification code sent to ${_phoneController.text.trim()}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =====================================================
  // VERIFY AND CONTINUE
  // =====================================================

  Future<void> _verifyAndContinue() async {
    FocusScope.of(context).unfocus();

    if (!_otpFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) {
      return;
    }

    final otp = _otpController.text.trim();

    // =====================================================
    // TEMPORARY MOCK OTP
    // Real OTP will replace this later.
    // =====================================================

    if (otp != '123456') {
      setState(() {
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid verification code',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final name =
        _nameController.text.trim();

    final phone =
        _phoneController.text.trim();

    final customer = Customer(
      // TEMPORARY LOCAL ID
      // Backend will generate the real customer ID later.
      id: 'CUST-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
    );

    ref
        .read(customerProvider.notifier)
        .setCustomer(customer);

    if (!mounted) {
      return;
    }

    setState(() {
      _isVerifying = false;
    });

    Navigator.of(context).pop(true);
  }

  // =====================================================
  // CHANGE DETAILS
  // =====================================================

  void _changeDetails() {
    setState(() {
      _otpSent = false;
      _otpController.clear();
    });
  }

  // =====================================================
  // RESEND OTP
  // =====================================================

  Future<void> _resendOtp() async {
    setState(() {
      _isSendingOtp = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSendingOtp = false;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A new verification code has been sent',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();

    super.dispose();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F3),
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF171717),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            10,
            24,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===================================================
              // HEADER
              // ===================================================

              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6D5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 28,
                  color: Color(0xFFEE7424),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Your details',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171717),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter your details so we can confirm your order and contact you when needed.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF777777),
                ),
              ),

              const SizedBox(height: 30),

              // ===================================================
              // CUSTOMER DETAILS
              // ===================================================

              Form(
                key: _detailsFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Full name',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF171717),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _nameController,
                      enabled: !_otpSent,
                      keyboardType: TextInputType.name,
                      textCapitalization:
                          TextCapitalization.words,
                      validator: _validateName,
                      decoration: _inputDecoration(
                        hint: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Mobile number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF171717),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _phoneController,
                      enabled: !_otpSent,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      validator: _validatePhone,
                      decoration: _inputDecoration(
                        hint: '01XXXXXXXXX',
                        icon: Icons.phone_outlined,
                      ).copyWith(
                        counterText: '',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===================================================
              // SEND OTP
              // ===================================================

              if (!_otpSent)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        _isSendingOtp ? null : _sendOtp,
                    style: _buttonStyle(),
                    child: _isSendingOtp
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Send verification code',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),

              // ===================================================
              // OTP AREA
              // ===================================================

              if (_otpSent) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4EC),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFFEE7424),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'We sent a verification code to ${_phoneController.text.trim()}',
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: Color(0xFF171717),
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: _changeDetails,
                        child: const Text(
                          'Change',
                          style: TextStyle(
                            color: Color(0xFFEE7424),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Form(
                  key: _otpFormKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verification code',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF171717),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _otpController,
                        keyboardType:
                            TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly,
                          LengthLimitingTextInputFormatter(
                            6,
                          ),
                        ],
                        validator: _validateOtp,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                          color: Color(0xFF171717),
                        ),
                        decoration: _inputDecoration(
                          hint: '000000',
                          icon: Icons.lock_outline_rounded,
                        ).copyWith(
                          counterText: '',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: TextButton(
                    onPressed:
                        _isSendingOtp
                            ? null
                            : _resendOtp,
                    child: const Text(
                      'Resend code',
                      style: TextStyle(
                        color: Color(0xFFEE7424),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        _isVerifying
                            ? null
                            : _verifyAndContinue,
                    style: _buttonStyle(),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify & Continue',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    'Development code: 123456',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF999999),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // INPUT STYLE
  // =====================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF777777),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE8E5E0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFEE7424),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE53935),
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE8E5E0),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF171717),
      foregroundColor: Colors.white,
      disabledBackgroundColor:
          const Color(0xFF999999),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}