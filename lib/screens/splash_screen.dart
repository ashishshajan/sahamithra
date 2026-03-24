import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/language_provider.dart';
import '../routes/app_routes.dart';

/// Mirrors /components/SplashScreen.tsx
///
/// Design:
///  - Gradient background: from-purple-50 via-pink-50 to-blue-50 (diagonal)
///  - 3 animated blob circles (purple/pink/blue, mix-blend-multiply, 30% opacity)
///  - Logo card: white rounded-3xl + shadow-2xl + gradient glow
///  - App name: text-5xl font-bold gradient text (fade+slide in, delay 200ms)
///  - Tagline: text-base text-gray-600 (delay 400ms)
///  - Progress bar: gradient fill + shimmer (delay 600ms)
///  - Loading dots: 3 pulsing circles (delay 800ms)
///  - Footer: "Powered by NHM Kozhikode & CRC Kerala" (delay 1000ms)
///  - Total duration: 2800ms then navigate
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _progressController;
  late AnimationController _blobController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;
  late Animation<double> _logoScale;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _progressOpacity;
  late Animation<double> _dotsOpacity;
  late Animation<double> _footerOpacity;
  late Animation<double> _shimmer;

  double _progress = 0.0;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    // Entry animations
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Logo: scale + opacity + slide (delay 100ms)
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Title (delay 200ms = interval 0.2 of 1s)
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    // Tagline (delay 400ms)
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
            begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Progress bar (delay 600ms)
    _progressOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Dots (delay 800ms)
    _dotsOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    // Footer (delay 1000ms)
    _footerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(1.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _shimmer = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Start after 100ms (matches web setTimeout 100ms)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _isLoaded = true);
        _entryController.forward();
      }
    });

    // Progress bar: 0→100 in ~1500ms (30ms × 50 increments = 1500ms)
    Future.delayed(const Duration(milliseconds: 100), () {
      _animateProgress();
    });

    // Navigate after 2800ms
    Future.delayed(const Duration(milliseconds: 2800), () async {
      if (mounted) {
        final utils = GlobalUtils();
        if (utils.isLoggedIn && utils.token != null) {
          // Attempt to refresh user data on launch
          final initResult = await NetworkHelper().getInit();
          if (initResult['success']) {
            print('Get init response inside splash screen ${initResult['data']}');
              final initData = initResult['data'];
              if (initData is Map<String, dynamic>) {
                await utils.setInitUserAndFirstChild(initData);
              } else if (initData is Map) {
                await utils.setUserData(initData.cast<String, dynamic>());
              }
            Get.offAllNamed(AppRoutes.dashboard);
          }
          else{
            Get.offAllNamed(AppRoutes.login);
          }

        } else {
          Get.offAllNamed(AppRoutes.onboarding);
        }
      }
    });
  }

  void _animateProgress() {
    const totalDuration = 1500; // ms
    const steps = 50;
    const interval = totalDuration ~/ steps;

    var current = 0;
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: interval));
      if (!mounted) return false;
      current++;
      setState(() => _progress = current / steps);
      return current < steps;
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _progressController.dispose();
    _blobController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.to;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFAF5FF), // purple-50
              Color(0xFFFDF2F8), // pink-50
              Color(0xFFEFF6FF), // blue-50
            ],
          ),
        ),
        child: Stack(
          children: [
            // ─── Animated background blobs ─────────────────────────────────
            _AnimatedBlob(
              controller: _blobController,
              color: const Color(0xFFD8B4FE), // purple-300
              alignment: const Alignment(-1.2, -1.2),
              phase: 0.0,
            ),
            _AnimatedBlob(
              controller: _blobController,
              color: const Color(0xFFF9A8D4), // pink-300
              alignment: const Alignment(1.2, -1.2),
              phase: 0.33,
            ),
            _AnimatedBlob(
              controller: _blobController,
              color: const Color(0xFF93C5FD), // blue-300
              alignment: const Alignment(0, 1.3),
              phase: 0.66,
            ),

            // ─── Main content ───────────────────────────────────────────────
            SafeArea(
              child: Center(
                child: Column(
                  children: [
                    const Spacer(),
                    // Logo
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: SlideTransition(
                        position: _logoSlide,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: _buildLogoCard(),
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // App name
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                          child: Obx(
                            () => Text(
                              lang.t('appName'),
                              style: TextStyle(
                                fontSize: 40.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Tagline
                    FadeTransition(
                      opacity: _taglineOpacity,
                      child: SlideTransition(
                        position: _taglineSlide,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Obx(
                            () => Text(
                              lang.t('appTagline'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 48.h),

                    // Progress bar
                    FadeTransition(
                      opacity: _progressOpacity,
                      child: _buildProgressSection(lang),
                    ),

                    SizedBox(height: 24.h),

                    // Loading dots
                    FadeTransition(
                      opacity: _dotsOpacity,
                      child: _buildLoadingDots(),
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ),

            // Footer
            Positioned(
              bottom: 32.h,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _entryController,
                builder: (_, child) => Opacity(
                  opacity: _entryController.value,
                  child: child,
                ),
                child: Text(
                  'Powered by NHM Kozhikode & CRC Kerala',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoCard() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow
        Container(
          width: 200.r,
          height: 200.r,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ).asBlur(0.4),

        // White card
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF9FAFB)],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              width: 144.r,
              height: 144.r,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 144.r,
                height: 144.r,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 64.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(LanguageProvider lang) {
    return SizedBox(
      width: 256.w,
      child: Column(
        children: [
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  lang.t('loading'),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.purplePinkGradient.createShader(bounds),
                child: Text(
                  '${(_progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Track
          Container(
            height: 8.h,
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 256.w * _progress,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                  // Shimmer overlay
                  AnimatedBuilder(
                    animation: _shimmer,
                    builder: (_, __) {
                      return Positioned(
                        left: (256.w * _progress) * (_shimmer.value),
                        child: Container(
                          width: 80.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulsingDot(color: AppColors.purple, delay: 0),
        SizedBox(width: 8.w),
        _PulsingDot(color: AppColors.pink, delay: 150),
        SizedBox(width: 8.w),
        _PulsingDot(color: AppColors.blue, delay: 300),
      ],
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  const _AnimatedBlob({
    required this.controller,
    required this.color,
    required this.alignment,
    required this.phase,
  });

  final AnimationController controller;
  final Color color;
  final Alignment alignment;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final t = (controller.value + phase) % 1.0;
        final dx = math.sin(t * 2 * math.pi) * 30;
        final dy = math.cos(t * 3 * math.pi) * 20;
        final scale = 0.9 + math.sin(t * 2 * math.pi) * 0.1;

        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.scale(
              scale: scale,
              child: child!,
            ),
          ),
        );
      },
      child: Opacity(
        opacity: 0.30,
        child: Container(
          width: 300.r,
          height: 300.r,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, required this.delay});
  final Color color;
  final int delay;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 8.r,
        height: 8.r,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

extension _BlurWidget on Widget {
  Widget asBlur(double opacity) => Opacity(opacity: opacity, child: this);
}
