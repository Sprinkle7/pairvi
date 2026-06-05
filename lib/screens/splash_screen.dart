import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_translations.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_logo.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _footerController;
  late final AnimationController _exitController;
  late final AnimationController _shimmerController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _footerOpacity;
  late final Animation<Offset> _footerSlide;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();

    _logoController   = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _textController   = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _footerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _exitController   = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = CurvedAnimation(parent: _logoController, curve: Curves.easeOut);

    _textOpacity = CurvedAnimation(parent: _textController, curve: Curves.easeOut);
    _textSlide   = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _footerOpacity = CurvedAnimation(parent: _footerController, curve: Curves.easeOut);
    _footerSlide   = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _footerController, curve: Curves.easeOutCubic),
    );

    _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    await _logoController.forward();
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    await Future.wait([_textController.forward(), _footerController.forward()]);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    _shimmerController.stop();
    await _exitController.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, _) => const MainShell(),
        transitionDuration: const Duration(milliseconds: 650),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _footerController.dispose();
    _exitController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) => Opacity(
          opacity: 1 - _exitController.value,
          child: child,
        ),
        child: Container(
          decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
          child: SafeArea(
            child: Stack(
              children: [
                // Decorative pulsing orbs
                Positioned(
                  top: -90,
                  right: -70,
                  child: _PulsingOrb(size: 260, opacity: 0.10, delay: Duration.zero),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: _PulsingOrb(size: 80, opacity: 0.06, delay: const Duration(milliseconds: 600)),
                ),
                Positioned(
                  bottom: 160,
                  left: -50,
                  child: _PulsingOrb(size: 190, opacity: 0.09, delay: const Duration(milliseconds: 300)),
                ),
                Positioned(
                  bottom: 80,
                  right: -30,
                  child: _PulsingOrb(size: 120, opacity: 0.07, delay: const Duration(milliseconds: 900)),
                ),
                Positioned(
                  top: 200,
                  left: 30,
                  child: _PulsingOrb(size: 50, opacity: 0.08, delay: const Duration(milliseconds: 450)),
                ),

                // Main content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo with glow ring
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: _LogoWithGlow(shimmer: _shimmer),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // App name + tagline
                      FadeTransition(
                        opacity: _textOpacity,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              Text(
                                S.of(context, 'appName'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Decorative divider
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 24, height: 1.5, color: AppTheme.gold.withValues(alpha: 0.6)),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.gold.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  Container(width: 24, height: 1.5, color: AppTheme.gold.withValues(alpha: 0.6)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                S.of(context, 'appTagline'),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 15,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Credit: Advocate Islamuddin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: FadeTransition(
                    opacity: _footerOpacity,
                    child: SlideTransition(
                      position: _footerSlide,
                      child: const AppFooter(light: true),
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

// ── Logo with animated shimmer glow ring ─────────────────────────────────────

class _LogoWithGlow extends StatelessWidget {
  const _LogoWithGlow({required this.shimmer});

  final Animation<double> shimmer;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            gradient: SweepGradient(
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.3),
                AppTheme.gold.withValues(alpha: 0.5),
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
              transform: GradientRotation(shimmer.value),
            ),
          ),
          child: child,
        );
      },
      child: const AppLogo(size: 120, borderRadius: 28, showShadow: true),
    );
  }
}

// ── Self-contained pulsing orb ────────────────────────────────────────────────

class _PulsingOrb extends StatefulWidget {
  const _PulsingOrb({
    required this.size,
    required this.opacity,
    required this.delay,
  });

  final double size;
  final double opacity;
  final Duration delay;

  @override
  State<_PulsingOrb> createState() => _PulsingOrbState();
}

class _PulsingOrbState extends State<_PulsingOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _scale = Tween<double>(begin: 0.80, end: 1.20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _fade = Tween<double>(begin: widget.opacity * 0.5, end: widget.opacity).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
