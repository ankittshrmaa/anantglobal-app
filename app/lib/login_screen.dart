import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'signup_screen.dart';
import 'api_service.dart';
import 'user_session.dart';
import 'main2.dart';

// ─── COLORS (same across all screens) ───────────────────────────────────────
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

// ─── LOGIN SCREEN ────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController  = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading       = false;
  bool _passwordVisible = false;
  bool _rememberMe      = false;

  String? _mobileError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validation ──────────────────────────────────────────────────────────
  bool _validate() {
    bool valid = true;
    setState(() {
      _mobileError  = _mobileController.text.trim().length != 10
          ? 'Enter a valid 10-digit mobile number' : null;
      _passwordError = _passwordController.text.trim().length < 6
          ? 'Password must be at least 6 characters' : null;
      _generalError = null;
    });
    if (_mobileError != null || _passwordError != null) valid = false;
    return valid;
  }

  // ── Login → calls real backend ───────────────────────────────────────────
  Future<void> _login() async {
    if (!_validate()) return;
    setState(() { _isLoading = true; _generalError = null; });

    final result = await ApiService.login(
      mobile:   _mobileController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result.success) {
      // Show welcome snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: kWhite, size: 18),
            const SizedBox(width: 10),
            Text('Welcome back, ${result.data?['name'] ?? ''}!',
              style: const TextStyle(fontWeight: FontWeight.w500)),
          ]),
          backgroundColor: kSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
      // Go back to main page
      UserSession.login(result.data?['name'] ?? '', result.data?['mobile'] ?? '');
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const HomePage2()),
  (route) => false,
);
    }
     else {
      setState(() => _generalError = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: kLightGray,
      body: Row(
        children: [
          // ── Left decorative panel ─────────────────────────────────────
          if (isWide)
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
                    Positioned(top: -60,  left: -60,  child: _bgCircle(300, 0.08)),
                    Positioned(bottom: -80, right: -80, child: _bgCircle(360, 0.08)),
                    Positioned(top: 200,  right: -40,  child: _bgCircle(180, 0.05)),
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

                          const Text(
                            'Welcome\nback.',
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: kWhite, height: 1.2),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Log in to track your visa applications,\nconsultations, and global opportunities.',
                            style: TextStyle(fontSize: 15, color: Color(0xFFBFDBFE), height: 1.7),
                          ),
                          const SizedBox(height: 48),

                          // Stats row
                          Row(children: [
                            _statPill('3+',  'Years'),
                            const SizedBox(width: 16),
                            _statPill('98%', 'Success'),
                            const SizedBox(width: 16),
                            _statPill('6+',  'Countries'),
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
                              Text('"Got my UK study visa in just 3 weeks with AnantGlobal\'s help."',
                                style: TextStyle(fontSize: 14, color: kWhite, fontStyle: FontStyle.italic, height: 1.6)),
                              SizedBox(height: 12),
                              Text('— Rahul Verma, Delhi',
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

          // ── Right panel — Login form ───────────────────────────────────
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Back to home (mobile only)
                      if (!isWide) ...[
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(children: const [
                            Icon(Icons.arrow_back_ios, size: 15, color: kPrimary),
                            Text('Home', style: TextStyle(fontSize: 14, color: kPrimary, fontWeight: FontWeight.w500)),
                          ]),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Header
                      const Text('Log In', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: kTextDark)),
                      const SizedBox(height: 6),
                      const Text('Welcome back! Enter your details to continue.', style: TextStyle(fontSize: 15, color: kTextLight)),
                      const SizedBox(height: 32),

                      // Google button
                      _GoogleButton(),
                      const SizedBox(height: 20),

                      // Divider
                      _orDivider(),
                      const SizedBox(height: 20),

                      // General error
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

                      // Mobile Number
                      _fieldLabel('Mobile Number'),
                      _mobileField(),
                      const SizedBox(height: 16),

                      // Password
                      _fieldLabel('Password'),
                      _passwordField(),
                      const SizedBox(height: 12),

                      // Remember me + Forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            SizedBox(
                              width: 20, height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                activeColor: kPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                side: const BorderSide(color: kGray, width: 1.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Remember me', style: TextStyle(fontSize: 13, color: kTextLight)),
                          ]),
                          GestureDetector(
                            onTap: () {},
                            child: const Text('Forgot Password?', style: TextStyle(fontSize: 13, color: kPrimary, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: kWhite,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: kWhite, strokeWidth: 2.5))
                              : const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Divider
                      const Divider(color: kGray),
                      const SizedBox(height: 20),

                      // ── Create Account button ─────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kGray),
                        ),
                        child: Column(children: [
                          const Text("Don't have an account?", style: TextStyle(fontSize: 14, color: kTextLight)),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                // Navigate to SignupScreen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kPrimary,
                                side: const BorderSide(color: kPrimary, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Create New Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile input field ───────────────────────────────────────────────────
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
            decoration: const BoxDecoration(border: Border(right: BorderSide(color: kGray))),
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

  // ── Password field ───────────────────────────────────────────────────────
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
            hintText: 'Enter your password',
            hintStyle: const TextStyle(color: kTextLighter, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline, color: kTextLight, size: 20),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _passwordVisible = !_passwordVisible),
              child: Icon(
                _passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: kTextLight, size: 20,
              ),
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

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kTextDark)),
  );

  Widget _orDivider() => Row(children: [
    const Expanded(child: Divider(color: kGray)),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text('or continue with mobile', style: TextStyle(fontSize: 13, color: kTextLight)),
    ),
    const Expanded(child: Divider(color: kGray)),
  ]);

  Widget _bgCircle(double size, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(opacity)),
  );

  Widget _statPill(String value, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
    ),
    child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kWhite)),
      Text(label,  style: const TextStyle(fontSize: 11, color: Color(0xFFBFDBFE))),
    ]),
  );
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
          SizedBox(width: 22, height: 22, child: CustomPaint(painter: _GoogleLogoPainter())),
          const SizedBox(width: 12),
          const Text('Continue with Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kTextDark)),
        ]),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;
    final colors = [const Color(0xFF4285F4), const Color(0xFF34A853), const Color(0xFFFBBC05), const Color(0xFFEA4335)];
    final angles = [[-0.1, 1.65], [1.65, 1.65], [3.3, 1.65], [4.95, 1.65]];
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      paint.color = colors[i];
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.72), angles[i][0], angles[i][1], false, paint);
    }
  }
  @override
  bool shouldRepaint(_GoogleLogoPainter old) => false;
}