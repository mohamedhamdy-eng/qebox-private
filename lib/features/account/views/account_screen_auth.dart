part of 'account_screen.dart';

extension _AccountAuthViews on _AccountScreenState {
  Widget _buildAuthentication() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6D5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 29,
              color: Color(0xFFEE7424),
            ),
          ),

          const SizedBox(height: 22),

          Text(
            tr('Welcome to Qebox'),
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171717),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            tr('Sign in to your account or create a new one.'),
            style: const TextStyle(
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
              color: const Color(0xFFF0EDE8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _AuthTab(
                    title: tr('Sign In'),
                    selected: !_isSignUp,
                    onTap: () {
                      _applyState(() {
                        _isSignUp = false;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _AuthTab(
                    title: tr('Sign Up'),
                    selected: _isSignUp,
                    onTap: () {
                      _applyState(() {
                        _isSignUp = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          if (_isSignUp) _buildSignUp() else _buildSignIn(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSignIn() {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Mobile number'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _signInPhoneController,
            enabled: !_signInOtpSent,
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
            ).copyWith(counterText: ''),
          ),
          if (!_signInOtpSent) ...[
            const SizedBox(height: 22),
            _MainButton(
              title: tr('Send verification code'),
              loading: _isLoading,
              onPressed: _sendSignInOtp,
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 10),
              _DevelopmentLoginButton(
                label: 'Login with development account',
                onPressed: _loginWithDevelopmentAccount,
              ),
            ],
          ],
          if (_signInOtpSent) ...[
            const SizedBox(height: 20),
            Text(
              tr('Verification code'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _signInOtpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: _inputDecoration(
                hint: '000000',
                icon: Icons.lock_outline_rounded,
              ).copyWith(counterText: ''),
            ),
            const SizedBox(height: 22),
            _MainButton(
              title: tr('Sign In'),
              loading: _isLoading,
              onPressed: _verifySignIn,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  _applyState(() {
                    _signInOtpSent = false;
                    _signInOtpController.clear();
                  });
                },
                child: Text(
                  tr('Change mobile number'),
                  style: const TextStyle(
                    color: Color(0xFFEE7424),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSignUp() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Full name'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _signUpNameController,
            enabled: !_signUpOtpSent,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            validator: _validateName,
            decoration: _inputDecoration(
              hint: tr('Enter your full name'),
              icon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            tr('Mobile number'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _signUpPhoneController,
            enabled: !_signUpOtpSent,
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
            ).copyWith(counterText: ''),
          ),
          if (!_signUpOtpSent) ...[
            const SizedBox(height: 22),
            _MainButton(
              title: tr('Create account'),
              loading: _isLoading,
              onPressed: _sendSignUpOtp,
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 10),
              _DevelopmentLoginButton(
                label: 'Continue for testing (no SMS)',
                onPressed: () => _continueWithoutSms(signUp: true),
              ),
            ],
          ],
          if (_signUpOtpSent) ...[
            const SizedBox(height: 20),
            Text(
              tr('Verification code'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _signUpOtpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: _inputDecoration(
                hint: '000000',
                icon: Icons.lock_outline_rounded,
              ).copyWith(counterText: ''),
            ),
            const SizedBox(height: 22),
            _MainButton(
              title: tr('Verify & Create Account'),
              loading: _isLoading,
              onPressed: _verifySignUp,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  _applyState(() {
                    _signUpOtpSent = false;
                    _signUpOtpController.clear();
                  });
                },
                child: Text(
                  tr('Change details'),
                  style: const TextStyle(
                    color: Color(0xFFEE7424),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
