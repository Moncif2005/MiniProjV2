import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:minipr/theme/app_colors.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──
  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _orbController;
  late final AnimationController _featuresController;
  late final AnimationController _exitController;

  // ── Background gradient shift ──
  late final Animation<double> _bgAnim;

  // ── Logo: scale + fade ──
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoGlow;

  // ── Text: slide up + fade ──
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;

  // ── Feature chips ──
  late final Animation<double> _featuresFade;
  late final Animation<Offset> _featuresSlide;

  // ── Orbs floating ──
  late final Animation<double> _orbFloat;

  // ── Exit ──
  late final Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _featuresController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // BG
    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);

    // Logo
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _logoGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    // Text
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Features
    _featuresFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _featuresController, curve: Curves.easeOut),
    );
    _featuresSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _featuresController, curve: Curves.easeOutCubic),
    );

    // Orbs
    _orbFloat = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOut),
    );

    // Exit
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // 1. BG fades in
    _bgController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    // 2. Logo pops in
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 150));

    // 3. Text slides up
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    // 4. Feature chips appear
    await _featuresController.forward();
    await Future.delayed(const Duration(milliseconds: 1800));

    // 5. Exit fade
    await _exitController.forward();

    // 6. Navigate
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthWrapper(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _orbController.dispose();
    _featuresController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _exitFade,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _bgController,
          _logoController,
          _textController,
          _orbController,
          _featuresController,
        ]),
        builder: (context, _) {
          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                // ── Animated gradient background ──
                _AnimatedBackground(progress: _bgAnim.value),

                // ── Floating orbs ──
                _FloatingOrbs(orbFloat: _orbFloat.value),

                // ── Centered content ──
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: _LogoWidget(glowProgress: _logoGlow.value),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App name
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: const Text(
                          'Formanova',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    FadeTransition(
                      opacity: _taglineFade,
                      child: SlideTransition(
                        position: _taglineSlide,
                        child: Text(
                          'Learn · Grow · Connect',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.75),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Feature highlights
                    FadeTransition(
                      opacity: _featuresFade,
                      child: SlideTransition(
                        position: _featuresSlide,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              _FeatureRow(
                                icon: Icons.school_rounded,
                                label: 'Expert-led courses',
                                delay: 0,
                                progress: _featuresController.value,
                              ),
                              const SizedBox(height: 12),
                              _FeatureRow(
                                icon: Icons.verified_rounded,
                                label: 'Earn certificates',
                                delay: 1,
                                progress: _featuresController.value,
                              ),
                              const SizedBox(height: 12),
                              _FeatureRow(
                                icon: Icons.work_rounded,
                                label: 'Connect with recruiters',
                                delay: 2,
                                progress: _featuresController.value,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Bottom shimmer bar ──
                Positioned(
                  bottom: 48,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _taglineFade,
                    child: Center(
                      child: _ShimmerDots(progress: _orbFloat.value),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Feature row chip ───────────────────────────────────────────────────────────
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int delay;
  final double progress;
  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.delay,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final threshold = delay * 0.2;
    final localProgress = ((progress - threshold) / 0.6).clamp(0.0, 1.0);
    return Opacity(
      opacity: localProgress,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - localProgress)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Animated gradient background ──────────────────────────────────────────────
class _AnimatedBackground extends StatelessWidget {
  final double progress;
  const _AnimatedBackground({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(
              AppColors.primary,
              const Color(0xFF0F0F23),
              progress * 0.3,
            )!,
            Color.lerp(
              const Color(0xFF4F39F6),
              AppColors.darkPrimary,
              progress * 0.5,
            )!,
            Color.lerp(
              const Color(0xFF0F0F23),
              AppColors.darkBg,
              progress,
            )!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// ── Floating decorative orbs ───────────────────────────────────────────────────
class _FloatingOrbs extends StatelessWidget {
  final double orbFloat;
  const _FloatingOrbs({required this.orbFloat});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // Top-left large orb
        Positioned(
          top: size.height * 0.08 + orbFloat * 18,
          left: -60,
          child: _Orb(
            radius: 160,
            color: AppColors.primary.withOpacity(0.22),
          ),
        ),
        // Top-right small orb
        Positioned(
          top: size.height * 0.15 - orbFloat * 12,
          right: -40,
          child: _Orb(
            radius: 100,
            color: const Color(0xFF4F39F6).withOpacity(0.18),
          ),
        ),
        // Bottom-right orb
        Positioned(
          bottom: size.height * 0.12 + orbFloat * 14,
          right: -50,
          child: _Orb(
            radius: 140,
            color: AppColors.primary.withOpacity(0.15),
          ),
        ),
        // Bottom-left small accent
        Positioned(
          bottom: size.height * 0.2 - orbFloat * 10,
          left: -30,
          child: _Orb(
            radius: 80,
            color: const Color(0xFF2B7FFF).withOpacity(0.20),
          ),
        ),
        // Center sparkle
        Positioned(
          top: size.height * 0.38 + orbFloat * 6,
          right: size.width * 0.12,
          child: _Orb(
            radius: 40,
            color: Colors.white.withOpacity(0.06),
          ),
        ),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final double radius;
  final Color color;
  const _Orb({required this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// ── Logo widget with glow ─────────────────────────────────────────────────────
class _LogoWidget extends StatelessWidget {
  final double glowProgress;
  const _LogoWidget({required this.glowProgress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.gradientBlue,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.5 * glowProgress),
            blurRadius: 32 * glowProgress,
            spreadRadius: 4 * glowProgress,
          ),
          BoxShadow(
            color: const Color(0xFF4F39F6).withOpacity(0.3 * glowProgress),
            blurRadius: 64 * glowProgress,
            spreadRadius: 8 * glowProgress,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle inner highlight
            Positioned(
              top: -10,
              left: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),
            // Icon
            const Icon(
              Icons.school_rounded,
              size: 52,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer loading dots ───────────────────────────────────────────────────────
class _ShimmerDots extends StatelessWidget {
  final double progress; // -1 to 1
  const _ShimmerDots({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        // Each dot pulses offset in phase
        final phase = (progress + 1) / 2; // 0..1
        final dotPhase = (phase + i * 0.33) % 1.0;
        final scale = 0.6 + 0.4 * math.sin(dotPhase * math.pi);
        final opacity = 0.4 + 0.6 * math.sin(dotPhase * math.pi);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
