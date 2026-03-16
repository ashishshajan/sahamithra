import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';

/// Splash Screen — pixel-perfect match to React SplashScreen.
/// Duration: 2800ms. Animated blobs, logo scale-in, progress bar shimmer.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo entry animation
  late AnimationController _entryController;
  late Animation<double> _opacityAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  // Staggered text/bar animations
  late AnimationController _staggerController;
  late Animation<double> _titleOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _barOpacity;
  late Animation<double> _dotsOpacity;
  late Animation<double> _footerOpacity;

  // Progress bar
  late AnimationController _progressController;
  double _progress = 0.0;

  // Blob animations
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();

    // ── Entry (logo) ───────────────────────────────────────────────────────
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _opacityAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _entryController, curve: Curves.easeOut));

    // ── Stagger ────────────────────────────────────────────────────────────
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _titleOpacity = _interval(0.0, 0.3);
    _taglineOpacity = _interval(0.2, 0.5);
    _barOpacity = _interval(0.4, 0.7);
    _dotsOpacity = _interval(0.6, 0.9);
    _footerOpacity = _interval(0.8, 1.0);

    // ── Progress ────────────────────────────────────────────────────────────
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _progressController.addListener(() {
      setState(() => _progress = _progressController.value);
    });

    // ── Blob ────────────────────────────────────────────────────────────────
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat(reverse: true);

    // ── Start sequence ──────────────────────────────────────────────────────
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _entryController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        _staggerController.forward();
        _progressController.forward();
      });
    });

    // Navigate after 2800ms
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) Get.offNamed(AppRoutes.onboarding);
    });
  }

  Animation<double> _interval(double begin, double end) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _staggerController.dispose();
    _progressController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.lightGradient),
        child: Stack(
          children: [
            // ── Animated Blob Backgrounds ─────────────────────────────────
            AnimatedBuilder(
              animation: _blobController,
              builder: (_, __) {
                final t = _blobController.value;
                return Stack(
                  children: [
                    _blob(
                      color: const Color(0xFFD8B4FE), // purple-300
                      left: -96 + (t * 30),
                      top: -96 + (-t * 50),
                      scale: 1 + (t * 0.1),
                    ),
                    _blob(
                      color: const Color(0xFFF9A8D4), // pink-300
                      right: -96 + (-t * 20),
                      top: -96 + (t * 20),
                      scale: 1 + (t * 0.08),
                      delay: 0.3,
                    ),
                    _blob(
                      color: const Color(0xFF93C5FD), // blue-300
                      left: MediaQuery.of(context).size.width / 2 - 192,
                      bottom: -96 + (t * 20),
                      scale: 0.9 + (t * 0.1),
                      delay: 0.6,
                    ),
                  ],
                );
              },
            ),

            // ── Main Content ─────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo
                  AnimatedBuilder(
                    animation: _entryController,
                    builder: (_, child) => Opacity(
                      opacity: _opacityAnim.value,
                      child: Transform.scale(
                        scale: _scaleAnim.value,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: child,
                        ),
                      ),
                    ),
                    child: _logoCard(),
                  ),

                  SizedBox(height: 32.h),

                  // App Name
                  FadeTransition(
                    opacity: _titleOpacity,
                    child: ShaderMask(
                      shaderCallback: (b) =>
                          AppColors.mainGradient.createShader(b),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        'appName'.tr,
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Tagline
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        'appTagline'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 48.h),

                  // Progress Bar
                  FadeTransition(
                    opacity: _barOpacity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 48.w),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'loading'.tr,
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.neutral500),
                              ),
                              ShaderMask(
                                shaderCallback: (b) =>
                                    AppColors.mainGradient.createShader(b),
                                blendMode: BlendMode.srcIn,
                                child: Text(
                                  '${(_progress * 100).round()}%',
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Stack(
                            children: [
                              // Track
                              Container(
                                height: 8.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              // Fill
                              FractionallySizedBox(
                                widthFactor: _progress,
                                child: Container(
                                  height: 8.h,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.mainGradient,
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryPurple
                                            .withOpacity(0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  // Shimmer overlay
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: _ShimmerBar(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Loading dots
                  FadeTransition(
                    opacity: _dotsOpacity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PulseDot(color: AppColors.primaryPurple, delay: 0),
                        SizedBox(width: 8.w),
                        _PulseDot(color: AppColors.primaryPink, delay: 150),
                        SizedBox(width: 8.w),
                        _PulseDot(color: AppColors.primaryBlue, delay: 300),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),

            // ── Footer Credit ─────────────────────────────────────────────
            Positioned(
              bottom: 32.h,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _footerOpacity,
                child: Text(
                  'poweredBy'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoCard() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow
        Container(
          width: 200.r,
          height: 200.r,
          decoration: BoxDecoration(
            gradient: AppColors.mainGradient,
            borderRadius: BorderRadius.circular(32.r),
          ),
          child: Container(
            margin: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
        ),
        // Logo card
        Container(
          width: 192.r,
          height: 192.r,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.3),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.all(24.r),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => ShaderMask(
              shaderCallback: (b) => AppColors.mainGradient.createShader(b),
              blendMode: BlendMode.srcIn,
              child: const Icon(Icons.child_care, size: 100, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _blob({
    Color color = Colors.purple,
    double? left,
    double? right,
    double? top,
    double? bottom,
    double scale = 1.0,
    double delay = 0,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 384.r,
          height: 384.r,
          decoration: BoxDecoration(
            color: color.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: BackdropFilter(
            filter: const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
            child: const SizedBox(),
          ),
        ),
      ),
    );
  }
}

/// Shimmer overlay on the progress bar
class _ShimmerBar extends StatefulWidget {
  @override
  State<_ShimmerBar> createState() => _ShimmerBarState();
}

class _ShimmerBarState extends State<_ShimmerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _anim = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => FractionalTranslation(
        translation: Offset(_anim.value, 0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Color(0x4DFFFFFF),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pulsing dot
class _PulseDot extends StatefulWidget {
  final Color color;
  final int delay;
  const _PulseDot({required this.color, required this.delay});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: 0.3 + (_ctrl.value * 0.7),
        child: Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
