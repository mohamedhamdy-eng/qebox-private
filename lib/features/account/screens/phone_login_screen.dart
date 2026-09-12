import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({
    super.key,
  });

  @override
  State<PhoneLoginScreen> createState() =>
      _PhoneLoginScreenState();
}

class _PhoneLoginScreenState
    extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  bool _isLoading = false;

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
  // CONTINUE
  // =====================================================

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final phone =
        _phoneController.text.trim();

    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    // The next step will open the OTP screen.
    // For now we return the valid phone number.
    Navigator.of(context).pop(phone);
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF9F7F3),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF9F7F3),
        surfaceTintColor:
            Colors.transparent,
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
          padding:
              const EdgeInsets.fromLTRB(
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
                    color:
                        const Color(
                      0xFFFFE6D5,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .phone_android_rounded,
                    color:
                        Color(0xFFEE7424),
                    size: 28,
                  ),
                ),

                const SizedBox(height: 26),

                // =========================================
                // TITLE
                // =========================================

                const Text(
                  'Enter your mobile number',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.1,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF171717),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'We’ll send you a verification code to confirm your number.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color:
                        Color(0xFF777777),
                  ),
                ),

                const SizedBox(height: 30),

                // =========================================
                // PHONE LABEL
                // =========================================

                const Text(
                  'Mobile number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF171717),
                  ),
                ),

                const SizedBox(height: 9),

                // =========================================
                // PHONE FIELD
                // =========================================

                TextFormField(
                  controller:
                      _phoneController,

                  keyboardType:
                      TextInputType.phone,

                  textInputAction:
                      TextInputAction.done,

                  maxLength: 11,

                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly,
                    LengthLimitingTextInputFormatter(
                      11,
                    ),
                  ],

                  validator:
                      _validatePhone,

                  onFieldSubmitted: (_) {
                    _continue();
                  },

                  decoration:
                      InputDecoration(
                    hintText:
                        '01XXXXXXXXX',

                    counterText: '',

                    filled: true,

                    fillColor:
                        Colors.white,

                    prefixIcon:
                        const Icon(
                      Icons.phone_outlined,
                      color:
                          Color(
                        0xFF777777,
                      ),
                    ),

                    contentPadding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                      borderSide:
                          BorderSide.none,
                    ),

                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            Color(
                          0xFFE8E5E0,
                        ),
                      ),
                    ),

                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            Color(
                          0xFFEE7424,
                        ),
                        width: 1.5,
                      ),
                    ),

                    errorBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            Color(
                          0xFFE53935,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Egyptian mobile numbers only',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Color(0xFF999999),
                  ),
                ),

                const Spacer(),

                // =========================================
                // CONTINUE BUTTON
                // =========================================

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child:
                      ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _continue,

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF171717,
                      ),

                      foregroundColor:
                          Colors.white,

                      disabledBackgroundColor:
                          const Color(
                        0xFF999999,
                      ),

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style:
                                TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}