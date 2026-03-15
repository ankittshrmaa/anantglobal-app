import 'package:flutter/material.dart';
import 'main.dart';

// ─── COLORS ──────────────────────────────────────────────────────────────────
const Color kPrimary     = Color(0xFF2563EB);
const Color kPrimaryDark = Color(0xFF1D4ED8);
const Color kWhite       = Color(0xFFFFFFFF);

// ─── SPLASH SCREEN ───────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── Animation controllers ─────────────────────────────────────────────────
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  // ── Animations ────────────────────────────────────────────────────────────
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineOpacity;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // Logo — scale up + fade in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5)),
    );

    // Text — fade in + slide up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0),
      ),
    );

    // Progress bar
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  // ── Animation sequence ────────────────────────────────────────────────────
  Future<void> _startSequence() async {
    // Step 1 — Logo appears
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // Step 2 — Text slides up
    await Future.delayed(const Duration(milliseconds: 700));
    _textController.forward();

    // Step 3 — Progress bar fills
    await Future.delayed(const Duration(milliseconds: 400));
    _progressController.forward();

    // Step 4 — Navigate to HomePage
    await Future.delayed(const Duration(milliseconds: 2600));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A),
              kPrimary,
              Color(0xFF3B82F6),
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Background decorative circles ───────────────────────────
            Positioned(
              top: -80, left: -80,
              child: _bgCircle(280, 0.07),
            ),
            Positioned(
              bottom: -100, right: -100,
              child: _bgCircle(350, 0.07),
            ),
            Positioned(
              top: 100, right: -60,
              child: _bgCircle(200, 0.04),
            ),
            Positioned(
              bottom: 200, left: -40,
              child: _bgCircle(150, 0.04),
            ),

            // ── Main content ─────────────────────────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // ── Logo icon ──────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (_, __) => Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.language_rounded,
                            color: kWhite,
                            size: 58,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Brand name + tagline ───────────────────────────────
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (_, __) => FadeTransition(
                      opacity: _textOpacity,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(children: [
                          const Text(
                            'ANANT GLOBAL',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: kWhite,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeTransition(
                            opacity: _taglineOpacity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: const Text(
                                'Your Global Opportunity Starts Here',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFBFDBFE),
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),

                  const SizedBox(height: 64),

                  // ── Progress bar ───────────────────────────────────────
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (_, __) => Opacity(
                      opacity: _progressValue.value == 0 ? 0 : 1,
                      child: Column(children: [
                        SizedBox(
                          width: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progressValue.value,
                              minHeight: 3,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(kWhite),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getLoadingText(_progressValue.value),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            // ── Version tag at bottom ─────────────────────────────────────
            Positioned(
              bottom: 32,
              left: 0, right: 0,
              child: Center(
                child: Text(
                  'v0.1',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.3),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading text changes as progress fills ────────────────────────────────
  String _getLoadingText(double value) {
    if (value < 0.3) return 'Initializing...';
    if (value < 0.6) return 'Loading resources...';
    if (value < 0.9) return 'Almost ready...';
    return 'Welcome!';
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
}