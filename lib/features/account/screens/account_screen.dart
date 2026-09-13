import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../addresses/screens/address_selection_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../providers/customer_provider.dart';

class AccountScreen extends ConsumerStatefulWidget {
  final bool closeAfterAuthentication;

  const AccountScreen({
    super.key,
    this.closeAfterAuthentication = false,
  });

  @override
  ConsumerState<AccountScreen> createState() =>
      _AccountScreenState();
}

class _AccountScreenState
    extends ConsumerState<AccountScreen> {
  bool _isSignUp = false;

  bool _signInOtpSent = false;
  bool _signUpOtpSent = false;

  bool _isLoading = false;

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final _signInPhoneController =
      TextEditingController();
  final _signInOtpController =
      TextEditingController();

  final _signUpNameController =
      TextEditingController();
  final _signUpPhoneController =
      TextEditingController();
  final _signUpOtpController =
      TextEditingController();

  // =====================================================
  // VALIDATION
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
  // SIGN IN - SEND OTP
  // =====================================================

  Future<void> _sendSignInOtp() async {
    FocusScope.of(context).unfocus();

    if (!_signInFormKey.currentState!.validate()) {
      return;
    }

    final phone =
        _signInPhoneController.text.trim();

    final exists = ref
        .read(customerProvider.notifier)
        .isPhoneRegistered(phone);

    if (!exists) {
      _showMessage(
        'No account found with this mobile number. Please Sign Up.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _signInOtpSent = true;
    });

    _showMessage(
      'Verification code sent to $phone',
    );
  }

  // =====================================================
  // SIGN IN - VERIFY
  // =====================================================

  Future<void> _verifySignIn() async {
    FocusScope.of(context).unfocus();

    final otp =
        _signInOtpController.text.trim();

    final otpError = _validateOtp(otp);

    if (otpError != null) {
      _showMessage(otpError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    if (!mounted) return;

    if (otp != '123456') {
      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Invalid verification code',
      );
      return;
    }

    final customer = ref
        .read(customerProvider.notifier)
        .signIn(
          phone:
              _signInPhoneController.text.trim(),
        );

    setState(() {
      _isLoading = false;
    });

    if (customer == null) {
      _showMessage(
        'Account not found',
      );
      return;
    }

    await _authenticationCompleted();
  }

  // =====================================================
  // SIGN UP - SEND OTP
  // =====================================================

  Future<void> _sendSignUpOtp() async {
    FocusScope.of(context).unfocus();

    if (!_signUpFormKey.currentState!.validate()) {
      return;
    }

    final phone =
        _signUpPhoneController.text.trim();

    final exists = ref
        .read(customerProvider.notifier)
        .isPhoneRegistered(phone);

    if (exists) {
      _showMessage(
        'This mobile number already has an account. Please Sign In.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _signUpOtpSent = true;
    });

    _showMessage(
      'Verification code sent to $phone',
    );
  }

  // =====================================================
  // SIGN UP - VERIFY
  // =====================================================

  Future<void> _verifySignUp() async {
    FocusScope.of(context).unfocus();

    final otp =
        _signUpOtpController.text.trim();

    final otpError = _validateOtp(otp);

    if (otpError != null) {
      _showMessage(otpError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    if (!mounted) return;

    if (otp != '123456') {
      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Invalid verification code',
      );
      return;
    }

    final customer = ref
        .read(customerProvider.notifier)
        .signUp(
          name:
              _signUpNameController.text.trim(),
          phone:
              _signUpPhoneController.text.trim(),
        );

    setState(() {
      _isLoading = false;
    });

    if (customer == null) {
      _showMessage(
        'This mobile number already has an account',
      );
      return;
    }

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

  void _logout() {
    ref
        .read(customerProvider.notifier)
        .logout();

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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
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
    final customerState =
        ref.watch(customerProvider);

    return Scaffold(
      backgroundColor:
          const Color(0xFFF9F7F3),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF9F7F3),
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: Text(
          customerState.isLoggedIn
              ? 'My Account'
              : 'Account',
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

  Widget _buildAuthentication() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        40,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFFFE6D5),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 29,
              color: Color(0xFFEE7424),
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Welcome to Qebox',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171717),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Sign in to your account or create a new one.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF777777),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 26),

          // =============================================
          // SIGN IN / SIGN UP SWITCH
          // =============================================

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFF0EDE8),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _AuthTab(
                    title: 'Sign In',
                    selected: !_isSignUp,
                    onTap: () {
                      setState(() {
                        _isSignUp = false;
                      });
                    },
                  ),
                ),

                Expanded(
                  child: _AuthTab(
                    title: 'Sign Up',
                    selected: _isSignUp,
                    onTap: () {
                      setState(() {
                        _isSignUp = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          if (_isSignUp)
            _buildSignUp()
          else
            _buildSignIn(),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'Development OTP: 123456',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF999999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SIGN IN
  // =====================================================

  Widget _buildSignIn() {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
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
            controller:
                _signInPhoneController,
            enabled: !_signInOtpSent,
            keyboardType:
                TextInputType.phone,
            maxLength: 11,
            inputFormatters: [
              FilteringTextInputFormatter
                  .digitsOnly,
              LengthLimitingTextInputFormatter(
                11,
              ),
            ],
            validator: _validatePhone,
            decoration: _inputDecoration(
              hint: '01XXXXXXXXX',
              icon:
                  Icons.phone_outlined,
            ).copyWith(
              counterText: '',
            ),
          ),

          if (!_signInOtpSent) ...[
            const SizedBox(height: 22),

            _MainButton(
              title:
                  'Send verification code',
              loading: _isLoading,
              onPressed: _sendSignInOtp,
            ),
          ],

          if (_signInOtpSent) ...[
            const SizedBox(height: 20),

            const Text(
              'Verification code',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xFF171717),
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller:
                  _signInOtpController,
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
              decoration: _inputDecoration(
                hint: '000000',
                icon:
                    Icons.lock_outline_rounded,
              ).copyWith(
                counterText: '',
              ),
            ),

            const SizedBox(height: 22),

            _MainButton(
              title: 'Sign In',
              loading: _isLoading,
              onPressed: _verifySignIn,
            ),

            const SizedBox(height: 8),

            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _signInOtpSent =
                        false;
                    _signInOtpController
                        .clear();
                  });
                },
                child: const Text(
                  'Change mobile number',
                  style: TextStyle(
                    color:
                        Color(0xFFEE7424),
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // SIGN UP
  // =====================================================

  Widget _buildSignUp() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
            controller:
                _signUpNameController,
            enabled: !_signUpOtpSent,
            keyboardType:
                TextInputType.name,
            textCapitalization:
                TextCapitalization.words,
            validator: _validateName,
            decoration: _inputDecoration(
              hint: 'Enter your full name',
              icon:
                  Icons.person_outline_rounded,
            ),
          ),

          const SizedBox(height: 18),

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
            controller:
                _signUpPhoneController,
            enabled: !_signUpOtpSent,
            keyboardType:
                TextInputType.phone,
            maxLength: 11,
            inputFormatters: [
              FilteringTextInputFormatter
                  .digitsOnly,
              LengthLimitingTextInputFormatter(
                11,
              ),
            ],
            validator: _validatePhone,
            decoration: _inputDecoration(
              hint: '01XXXXXXXXX',
              icon:
                  Icons.phone_outlined,
            ).copyWith(
              counterText: '',
            ),
          ),

          if (!_signUpOtpSent) ...[
            const SizedBox(height: 22),

            _MainButton(
              title:
                  'Create account',
              loading: _isLoading,
              onPressed: _sendSignUpOtp,
            ),
          ],

          if (_signUpOtpSent) ...[
            const SizedBox(height: 20),

            const Text(
              'Verification code',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xFF171717),
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller:
                  _signUpOtpController,
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
              decoration: _inputDecoration(
                hint: '000000',
                icon:
                    Icons.lock_outline_rounded,
              ).copyWith(
                counterText: '',
              ),
            ),

            const SizedBox(height: 22),

            _MainButton(
              title:
                  'Verify & Create Account',
              loading: _isLoading,
              onPressed: _verifySignUp,
            ),

            const SizedBox(height: 8),

            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _signUpOtpSent = false;
                    _signUpOtpController
                        .clear();
                  });
                },
                child: const Text(
                  'Change details',
                  style: TextStyle(
                    color:
                        Color(0xFFEE7424),
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // LOGGED IN ACCOUNT
  // =====================================================

  Widget _buildLoggedInAccount() {
    final customer =
        ref.watch(customerProvider).customer!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        40,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFFFE6D5,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color:
                        Color(0xFFEE7424),
                    size: 30,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        customer.name,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Color(0xFF171717),
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        customer.phone,
                        style:
                            const TextStyle(
                          fontSize: 13,
                          color:
                              Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _AccountInfoCard(
            title: 'Personal information',
            children: [
              _InfoRow(
                title: 'Full name',
                value: customer.name,
              ),
              _InfoRow(
                title: 'Mobile',
                value: customer.phone,
              ),
              _InfoRow(
                title: 'Customer ID',
                value: customer.id,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _AccountMenuItem(
            icon:
                Icons.location_on_outlined,
            title: 'Addresses',
            subtitle:
                'Manage your delivery addresses',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return const AddressSelectionScreen();
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          _AccountMenuItem(
            icon:
                Icons.receipt_long_outlined,
            title: 'My Orders',
            subtitle:
                'View your current and previous orders',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return const OrdersScreen();
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          _AccountMenuItem(
            icon:
                Icons.favorite_border_rounded,
            title: 'My Favorites',
            subtitle:
                'View products you saved',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return const FavoritesScreen();
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          _AccountMenuItem(
            icon:
                Icons.account_balance_wallet_outlined,
            title: 'Wallet',
            subtitle:
                'Qebox wallet balance',
            onTap: () {
              _showMessage(
                'Wallet will be connected later',
              );
            },
          ),

          const SizedBox(height: 12),

          _AccountMenuItem(
            icon:
                Icons.stars_outlined,
            title: 'Points & Loyalty',
            subtitle:
                'Your Qebox rewards',
            onTap: () {
              _showMessage(
                'Loyalty will be connected later',
              );
            },
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(
                Icons.logout_rounded,
              ),
              label: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(
                  0xFFE53935,
                ),
                side: const BorderSide(
                  color: Color(
                    0xFFE53935,
                  ),
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

      prefixIcon: Icon(
        icon,
        color: const Color(
          0xFF777777,
        ),
      ),

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
    );
  }
}

// =====================================================
// AUTH TAB
// =====================================================

class _AuthTab extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _AuthTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14),
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),
        padding:
            const EdgeInsets.symmetric(
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(14),
        ),
        alignment:
            Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.w800,
            color: selected
                ? const Color(
                    0xFF171717,
                  )
                : const Color(
                    0xFF777777,
                  ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// MAIN BUTTON
// =====================================================

class _MainButton extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPressed;

  const _MainButton({
    required this.title,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed:
            loading ? null : onPressed,
        style:
            ElevatedButton.styleFrom(
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
                BorderRadius.circular(
              18,
            ),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

// =====================================================
// ACCOUNT INFORMATION
// =====================================================

class _AccountInfoCard
    extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _AccountInfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF171717),
            ),
          ),

          const SizedBox(height: 14),

          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              title,
              style:
                  const TextStyle(
                fontSize: 12,
                color:
                    Color(0xFF777777),
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xFF171717),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ACCOUNT MENU
// =====================================================

class _AccountMenuItem
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(20),
      child: Container(
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    const Color(
                  0xFFFFE6D5,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: Icon(
                icon,
                color:
                    const Color(
                  0xFFEE7424,
                ),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          Color(
                        0xFF171717,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      fontSize: 11,
                      color:
                          Color(
                        0xFF777777,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons
                  .arrow_forward_ios_rounded,
              size: 15,
              color:
                  Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }
}