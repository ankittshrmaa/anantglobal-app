import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'api_service.dart';
import 'user_session.dart';
import 'main2.dart';


// ─── COLORS (same as main.dart) ─────────────────────────────────────────────
const Color kPrimary     = Color(0xFF2563EB);
const Color kPrimaryDark = Color(0xFF1D4ED8);
const Color kTextDark    = Color(0xFF1F2937);
const Color kTextLight   = Color(0xFF6B7280);
const Color kTextLighter = Color(0xFF9CA3AF);
const Color kWhite       = Color(0xFFFFFFFF);
const Color kLightGray   = Color(0xFFF9FAFB);
const Color kGray        = Color(0xFFE5E7EB);
const Color kSuccess     = Color(0xFF10B981);
const Color kError       = Color(0xFFEF4444);

// ─── ENTRY POINT (remove this when merging into main.dart) ──────────────────
void main() => runApp(const _TestApp());
class _TestApp extends StatelessWidget {
  const _TestApp();
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignupScreen(),
    );
  }
}

// ─── SIGNUP SCREEN ───────────────────────────────────────────────────────────
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Step control: 0 = form, 1 = OTP verification, 2 = success
  int _step = 0;

  // Controllers
  final _nameController     = TextEditingController();
  final _mobileController   = TextEditingController();
  final _passwordController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  // State
  bool _isLoading       = false;
  bool _passwordVisible = false;
  String? _nameError;
  String? _mobileError;
  String? _passwordError;
  String? _otpError;
  String? _generalError;
  int _resendSeconds    = 30;

  // Holds the OTP shown in dev mode from backend
  String? _devOtp;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    super.dispose();
  }

  // ── Validation ──────────────────────────────────────────────────────────
  bool _validateForm() {
    setState(() {
      _nameError     = _nameController.text.trim().isEmpty ? 'Please enter your full name' : null;
      _mobileError   = _mobileController.text.trim().length != 10 ? 'Enter a valid 10-digit mobile number' : null;
      _passwordError = _passwordController.text.trim().length < 6 ? 'Password must be at least 6 characters' : null;
    });
    return _nameError == null && _mobileError == null && _passwordError == null;
  }

  // ── Send OTP → calls real backend ────────────────────────────────────────
  Future<void> _sendOtp() async {
    if (!_validateForm()) return;
    setState(() { _isLoading = true; _generalError = null; });

    final result = await ApiService.sendOtp(
      name:   _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      if (result.success) {
        _step      = 1;
        _devOtp    = result.data?['dev_otp'];   // shown in UI for dev testing
        _startResendTimer();
      } else {
        _generalError = result.message;
      }
    });
  }

  // ── Resend timer ────────────────────────────────────────────────────────
  void _startResendTimer() {
    setState(() => _resendSeconds = 30);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendSeconds--);
      return _resendSeconds > 0;
    });
  }

  // ── Verify OTP → calls real backend ──────────────────────────────────────
  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _otpError = 'Please enter the complete 6-digit OTP');
      return;
    }
    setState(() { _isLoading = true; _otpError = null; });

    final result = await ApiService.verifyOtpAndRegister(
      name:     _nameController.text.trim(),
      mobile:   _mobileController.text.trim(),
      otp:      otp,
      password: _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      if (result.success) {
        _step = 2;
      } else {
        _otpError = result.message;
      }
    });
  }

  // ── Resend OTP ───────────────────────────────────────────────────────────
  Future<void> _resendOtp() async {
    for (final c in _otpControllers) c.clear();
    setState(() { _otpError = null; _devOtp = null; });

    final result = await ApiService.sendOtp(
      name:   _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
    );

    if (result.success) {
      setState(() => _devOtp = result.data?['dev_otp']);
      _startResendTimer();
    } else {
      setState(() => _otpError = result.message);
    }
  }

  // ── OTP box input handler ────────────────────────────────────────────────
  void _onOtpChanged(String val, int index) {
    if (val.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (val.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGray,
      body: Row(
        children: [
          // ── Left Panel (decorative, hidden on small screens) ─────────────
          if (MediaQuery.of(context).size.width > 800)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E3A8A), kPrimary, Color(0xFF3B82F6)],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background circles
                    Positioned(top: -60, left: -60, child: _bgCircle(300, 0.08)),
                    Positioned(bottom: -80, right: -80, child: _bgCircle(360, 0.08)),
                    Positioned(top: 200, right: -40, child: _bgCircle(180, 0.05)),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          Row(children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.language, color: kWhite, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('ANANT GLOBAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kWhite)),
                              Text('Global Opportunities', style: TextStyle(fontSize: 11, color: Color(0xFFBFDBFE))),
                            ]),
                          ]),

                          const Spacer(),

                          // Main text
                          const Text(
                            'Your journey\nstarts here.',
                            style: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: kWhite, height: 1.2),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Create your account and get access to expert immigration\nguidance, visa assistance, and global opportunities.',
                            style: TextStyle(fontSize: 15, color: Color(0xFFBFDBFE), height: 1.7),
                          ),
                          const SizedBox(height: 48),

                          // Feature pills
                          Wrap(spacing: 10, runSpacing: 10, children: [
                            _featurePill(Icons.airplane_ticket_outlined, 'Visa Guidance'),
                            _featurePill(Icons.school_outlined,          'Study Abroad'),
                            _featurePill(Icons.work_outline,             'Career Help'),
                            _featurePill(Icons.menu_book_outlined,       'IELTS Prep'),
                          ]),

                          const SizedBox(height: 48),

                          // Testimonial
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                            ),
                            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('"AnantGlobal made my Canada study visa process completely stress-free."',
                                style: TextStyle(fontSize: 14, color: kWhite, fontStyle: FontStyle.italic, height: 1.6)),
                              SizedBox(height: 12),
                              Text('— Priya Sharma, Punjab',
                                style: TextStyle(fontSize: 13, color: Color(0xFFBFDBFE), fontWeight: FontWeight.w500)),
                            ]),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Right Panel (form) ───────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _step == 0 ? _buildFormStep()
                         : _step == 1 ? _buildOtpStep()
                         :              _buildSuccessStep(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 0: Main Form ─────────────────────────────────────────────────────
  Widget _buildFormStep() {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text('Create Account', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: kTextDark)),
        const SizedBox(height: 6),
        const Text('Join AnantGlobal and start your global journey', style: TextStyle(fontSize: 15, color: kTextLight)),
        const SizedBox(height: 32),

        // Google Sign Up
        _GoogleButton(),
        const SizedBox(height: 20),

        // Divider
        _orDivider(),
        const SizedBox(height: 20),

        // General error banner
        if (_generalError != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kError.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kError.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.error_outline, color: kError, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(_generalError!, style: const TextStyle(fontSize: 13, color: kError))),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        // Full Name
        _label('Full Name'),
        _inputField(
          controller: _nameController,
          hint: 'Enter your full name',
          icon: Icons.person_outline,
          error: _nameError,
          onChanged: (_) => setState(() { _nameError = null; _generalError = null; }),
        ),
        const SizedBox(height: 16),

        // Mobile Number
        _label('Mobile Number'),
        _mobileField(),
        const SizedBox(height: 16),

        // Password
        _label('Create Password'),
        _passwordField(),
        const SizedBox(height: 28),

        // Send OTP Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: kWhite,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: kWhite, strokeWidth: 2.5))
                : const Text('Send OTP & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 20),

        // Terms
        Center(
          child: Text.rich(
            TextSpan(
              text: 'By continuing, you agree to our ',
              style: const TextStyle(fontSize: 12, color: kTextLight),
              children: [
                TextSpan(text: 'Terms of Service', style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w500)),
                const TextSpan(text: ' and '),
                TextSpan(text: 'Privacy Policy', style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w500)),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 32),
        const Divider(color: kGray),
        const SizedBox(height: 20),

        // Already have account
        Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Already have an account?', style: TextStyle(fontSize: 14, color: kTextLight)),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text('Log In', style: TextStyle(fontSize: 14, color: kPrimary, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ],
    );
  }

  // ── STEP 1: OTP Verification ───────────────────────────────────────────────
  Widget _buildOtpStep() {
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        GestureDetector(
          onTap: () => setState(() { _step = 0; for (final c in _otpControllers) c.clear(); _otpError = null; }),
          child: Row(children: const [
            Icon(Icons.arrow_back_ios, size: 16, color: kPrimary),
            Text('Back', style: TextStyle(fontSize: 14, color: kPrimary, fontWeight: FontWeight.w500)),
          ]),
        ),
        const SizedBox(height: 28),

        // Icon
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.sms_outlined, color: kPrimary, size: 32),
        ),
        const SizedBox(height: 20),

        const Text('Verify your mobile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: kTextDark)),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            text: 'Enter the 6-digit OTP sent to ',
            style: const TextStyle(fontSize: 14, color: kTextLight),
            children: [
              TextSpan(
                text: '+91 ${_mobileController.text}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: kTextDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Dev mode OTP hint — backend prints it and also returns it in response
        if (_devOtp != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: kSuccess.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kSuccess.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.developer_mode, size: 14, color: kSuccess),
              const SizedBox(width: 8),
              Text('Dev OTP: $_devOtp', style: const TextStyle(fontSize: 13, color: kSuccess, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              const Text('(remove in production)', style: TextStyle(fontSize: 11, color: kTextLighter)),
            ]),
          ),
        const SizedBox(height: 32),

        // OTP Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _OtpBox(
            controller: _otpControllers[i],
            focusNode: _otpFocusNodes[i],
            onChanged: (val) => _onOtpChanged(val, i),
            hasError: _otpError != null,
          )),
        ),

        if (_otpError != null) ...[
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.error_outline, size: 14, color: kError),
            const SizedBox(width: 6),
            Text(_otpError!, style: const TextStyle(fontSize: 13, color: kError)),
          ]),
        ],

        const SizedBox(height: 28),

        // Verify Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: kWhite,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: kWhite, strokeWidth: 2.5))
                : const Text('Verify OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 20),

        // Resend
        Center(
          child: _resendSeconds > 0
              ? Text('Resend OTP in ${_resendSeconds}s', style: const TextStyle(fontSize: 14, color: kTextLight))
              : GestureDetector(
                  onTap: _resendOtp,
                  child: const Text('Resend OTP', style: TextStyle(fontSize: 14, color: kPrimary, fontWeight: FontWeight.w600)),
                ),
        ),

        const SizedBox(height: 32),
        const Divider(color: kGray),
        const SizedBox(height: 20),
        Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Already have an account?', style: TextStyle(fontSize: 14, color: kTextLight)),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text('Log In', style: TextStyle(fontSize: 14, color: kPrimary, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ],
    );
  }

  // ── STEP 2: Success ───────────────────────────────────────────────────────
  Widget _buildSuccessStep() {
    return Column(
      key: const ValueKey('success'),
      children: [
        const SizedBox(height: 20),
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: kSuccess.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_outline, color: kSuccess, size: 44),
        ),
        const SizedBox(height: 24),
        const Text('Account Created!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: kTextDark)),
        const SizedBox(height: 10),
        Text(
          'Welcome, ${_nameController.text.trim()}! Your account has been created successfully.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: kTextLight, height: 1.6),
        ),
        const SizedBox(height: 32),

        // Info chips
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: kLightGray, borderRadius: BorderRadius.circular(12), border: Border.all(color: kGray)),
          child: Column(children: [
            _infoRow(Icons.person, 'Name', _nameController.text.trim()),
            const SizedBox(height: 12),
            _infoRow(Icons.phone, 'Mobile', '+91 ${_mobileController.text}'),
            const SizedBox(height: 12),
            _infoRow(Icons.verified, 'Status', 'Verified ✓', valueColor: kSuccess),
          ]),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
  UserSession.login(
    _nameController.text.trim(),
    _mobileController.text.trim(),
  );
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const HomePage2()),
    (route) => false,
  );
}, // Navigate to home/dashboard
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: kWhite,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Go to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: const BorderSide(color: kPrimary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────────
  Widget _mobileField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _mobileError != null ? kError : kGray, width: 1.5),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: kGray)),
            ),
            child: const Text('+91', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextDark)),
          ),
          Expanded(
            child: TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() { _mobileError = null; _generalError = null; }),
              decoration: const InputDecoration(
                hintText: 'Enter 10-digit mobile number',
                hintStyle: TextStyle(color: kTextLighter, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                counterText: '',
              ),
            ),
          ),
        ]),
      ),
      if (_mobileError != null) ...[
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.error_outline, size: 13, color: kError),
          const SizedBox(width: 5),
          Text(_mobileError!, style: const TextStyle(fontSize: 12, color: kError)),
        ]),
      ],
    ]);
  }

  Widget _passwordField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _passwordError != null ? kError : kGray, width: 1.5),
        ),
        child: TextField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          onChanged: (_) => setState(() { _passwordError = null; _generalError = null; }),
          decoration: InputDecoration(
            hintText: 'Create a password (min 6 characters)',
            hintStyle: const TextStyle(color: kTextLighter, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline, color: kTextLight, size: 20),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _passwordVisible = !_passwordVisible),
              child: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: kTextLight, size: 20),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          ),
        ),
      ),
      if (_passwordError != null) ...[
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.error_outline, size: 13, color: kError),
          const SizedBox(width: 5),
          Text(_passwordError!, style: const TextStyle(fontSize: 12, color: kError)),
        ]),
      ],
    ]);
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? error,
    Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: error != null ? kError : kGray, width: 1.5),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: kTextLighter, fontSize: 14),
            prefixIcon: Icon(icon, color: kTextLight, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          ),
        ),
      ),
      if (error != null) ...[
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.error_outline, size: 13, color: kError),
          const SizedBox(width: 5),
          Text(error, style: const TextStyle(fontSize: 12, color: kError)),
        ]),
      ],
    ]);
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kTextDark)),
    );
  }

  Widget _orDivider() {
    return Row(children: [
      const Expanded(child: Divider(color: kGray)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('or continue with email', style: TextStyle(fontSize: 13, color: kTextLight)),
      ),
      const Expanded(child: Divider(color: kGray)),
    ]);
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(children: [
      Icon(icon, size: 16, color: kPrimary),
      const SizedBox(width: 10),
      Text('$label:', style: const TextStyle(fontSize: 14, color: kTextLight)),
      const SizedBox(width: 6),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? kTextDark)),
    ]);
  }

  Widget _bgCircle(double size, double opacity) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  Widget _featurePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: kWhite),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: kWhite, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ─── GOOGLE BUTTON ───────────────────────────────────────────────────────────
class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: kWhite,
          foregroundColor: kTextDark,
          side: const BorderSide(color: kGray, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Google G logo using colored boxes
          SizedBox(
            width: 22, height: 22,
            child: CustomPaint(painter: _GoogleLogoPainter()),
          ),
          const SizedBox(width: 12),
          const Text('Continue with Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kTextDark)),
        ]),
      ),
    );
  }
}

// ─── GOOGLE LOGO PAINTER ─────────────────────────────────────────────────────
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r  = size.width / 2;

    // Draw colored arcs to simulate the Google G
    final colors = [
      const Color(0xFF4285F4), // blue
      const Color(0xFF34A853), // green
      const Color(0xFFFBBC05), // yellow
      const Color(0xFFEA4335), // red
    ];

    final angles = [
      [-0.1, 1.65],
      [1.65, 1.65],
      [3.3, 1.65],
      [4.95, 1.65],
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.72),
        angles[i][0],
        angles[i][1],
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter old) => false;
}

// ─── OTP INPUT BOX ───────────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final bool hasError;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48, height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kTextDark),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: controller.text.isEmpty ? kWhite : kPrimary.withOpacity(0.07),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: hasError ? kError : kGray, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: hasError ? kError : kGray, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kPrimary, width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}