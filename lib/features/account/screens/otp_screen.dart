import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  final String phone;

  const OtpScreen({
    super.key,
    required this.phone,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  bool _isLoading = false;

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
  // VERIFY OTP
  // =====================================================

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
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
    // Later this will be replaced by real OTP verification
    // =====================================================

    if (otp != '123456') {
      setState(() {
        _isLoading = false;
      });

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

    setState(() {
      _isLoading = false;
    });

    // OTP verified successfully.
    // Next step: customer name screen.
    Navigator.of(context).pop(true);
  }

  // =====================================================
  // RESEND OTP
  // =====================================================

  void _resendOtp() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'A new verification code was sent to ${widget.phone}',
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // =========================================
                // ICON
                // =========================================

                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE6D5),
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFFEE7424),
                    size: 28,
                  ),
                ),

                const SizedBox(height: 26),

                // =========================================
                // TITLE
                // =========================================

                const Text(
                  'Verify your number',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF171717),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Enter the 6-digit code sent to ${widget.phone}',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF777777),
                  ),
                ),

                const SizedBox(height: 30),

                // =========================================
                // OTP LABEL
                // =========================================

                const Text(
                  'Verification code',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF171717),
                  ),
                ),

                const SizedBox(height: 9),

                // =========================================
                // OTP FIELD
                // =========================================

                TextFormField(
                  controller: _otpController,

                  keyboardType:
                      TextInputType.number,

                  textInputAction:
                      TextInputAction.done,

                  maxLength: 6,

                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly,
                    LengthLimitingTextInputFormatter(
                      6,
                    ),
                  ],

                  validator: _validateOtp,

                  onFieldSubmitted: (_) {
                    _verifyOtp();
                  },

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 22,
                    letterSpacing: 8,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF171717),
                  ),

                  decoration: InputDecoration(
                    hintText: '000000',

                    hintStyle: const TextStyle(
                      letterSpacing: 8,
                      color: Color(0xFFCCCCCC),
                    ),

                    counterText: '',

                    filled: true,

                    fillColor: Colors.white,

                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                      borderSide:
                          BorderSide.none,
                    ),

                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                      borderSide:
                          const BorderSide(
                        color: Color(0xFFE8E5E0),
                      ),
                    ),

                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                      borderSide:
                          const BorderSide(
                        color: Color(0xFFEE7424),
                        width: 1.5,
                      ),
                    ),

                    errorBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                      borderSide:
                          const BorderSide(
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // =========================================
                // RESEND
                // =========================================

                Center(
                  child: TextButton(
                    onPressed: _resendOtp,
                    child: const Text(
                      'Resend code',
                      style: TextStyle(
                        color: Color(0xFFEE7424),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // =========================================
                // VERIFY BUTTON
                // =========================================

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _verifyOtp,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF171717),

                      foregroundColor:
                          Colors.white,

                      disabledBackgroundColor:
                          const Color(0xFF999999),

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 8),

                // =========================================
                // TEMP DEVELOPMENT NOTE
                // Remove when real OTP is connected
                // =========================================

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
            ),
          ),
        ),
      ),
    );
  }
}