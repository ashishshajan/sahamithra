import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/language_switcher.dart';
import '../widgets/logo_widget.dart';
import '../widgets/standard_footer.dart';
import '../routes/app_routes.dart';

/// Mirrors /components/OnboardingScreen.tsx
///
/// 4 slides with icon, title, description, feature list, dot indicators, next/skip.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _currentSlide = 0;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;

  static const List<_SlideData> _slides = [
    _SlideData(
      icon: Icons.assignment_turned_in_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      titleKey: 'assessmentsTitle',
      descriptionKey: 'assessmentsDesc',
      featureKeys: [
        'onboardingS1F1',
        'onboardingS1F2',
        'onboardingS1F3',
        'onboardingS1F4',
      ],
    ),
    _SlideData(
      icon: Icons.play_circle_filled_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      titleKey: 'therapyTitle',
      descriptionKey: 'therapyDesc',
      featureKeys: [
        'onboardingS2F1',
        'onboardingS2F2',
        'onboardingS2F3',
        'onboardingS2F4',
      ],
    ),
    _SlideData(
      icon: Icons.emoji_events_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      titleKey: 'trackingTitle',
      descriptionKey: 'trackingDesc',
      featureKeys: [
        'onboardingS3F1',
        'onboardingS3F2',
        'onboardingS3F3',
        'onboardingS3F4',
      ],
    ),
    _SlideData(
      icon: Icons.groups_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      titleKey: 'cdmcTitle',
      descriptionKey: 'cdmcDesc',
      featureKeys: [
        'onboardingS4F1',
        'onboardingS4F2',
        'onboardingS4F3',
        'onboardingS4F4',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _goToSlide(int index) {
    _slideController.reverse().then((_) {
      setState(() => _currentSlide = index);
      _slideController.forward();
    });
  }

  void _handleNext() {
    if (_currentSlide < _slides.length - 1) {
      _goToSlide(_currentSlide + 1);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentSlide];

    return Obx(() {
      final lang = LanguageProvider.to;

      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFAF5FF),
                Color(0xFFFDF2F8),
                Color(0xFFEFF6FF),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ─── Header ─────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl.w,
                    24.h,
                    AppSpacing.xl.w,
                    0,
                  ),
                  child: Row(
                    children: [
                      // Logo in white card
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const LogoWidget(
                          size: LogoSize.small,
                          showText: false,
                        ),
                      ),
                      const Spacer(),
                      const LanguageSwitcherDark(),
                      SizedBox(width: 12.w),
                    ],
                  ),
                ),

                // ─── Slide content ───────────────────────────────────────────
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl.w,
                        vertical: AppSpacing.xl.h,
                      ),
                      child: Column(
                        children: [
                          // Icon circle
                          Container(
                            width: 128.r,
                            height: 128.r,
                            decoration: BoxDecoration(
                              gradient: slide.gradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.purple.withOpacity(0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              slide.icon,
                              size: 64.sp,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 32.h),

                          // Title
                          Text(
                            lang.t(slide.titleKey),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Description
                          Text(
                            lang.t(slide.descriptionKey),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),

                          SizedBox(height: 32.h),

                          // Feature list card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(AppSpacing.xl.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xl2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: List.generate(
                                slide.featureKeys.length,
                                (i) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: i < slide.featureKeys.length - 1
                                        ? 12.h
                                        : 0,
                                  ),
                                  child: _FeatureItem(
                                    text: lang.t(slide.featureKeys[i]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── Footer: dots + button ────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl.w,
                    0,
                    AppSpacing.xl.w,
                    24.h,
                  ),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => GestureDetector(
                            onTap: () => _goToSlide(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: i == _currentSlide ? 32.w : 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                gradient: i == _currentSlide
                                    ? AppColors.purplePinkGradient
                                    : null,
                                color: i == _currentSlide
                                    ? null
                                    : AppColors.neutral300,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Next / Get Started button
                      GradientButton(
                        onPressed: _handleNext,
                        height: 56.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentSlide < _slides.length - 1
                                  ? lang.t('next')
                                  : lang.t('getStarted'),
                              style: AppTextStyles.button,
                            ),
                            if (_currentSlide < _slides.length - 1) ...[
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      const StandardFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.r,
          height: 20.r,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: 12.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.icon,
    required this.gradient,
    required this.titleKey,
    required this.descriptionKey,
    required this.featureKeys,
  });

  final IconData icon;
  final LinearGradient gradient;
  final String titleKey;
  final String descriptionKey;
  final List<String> featureKeys;
}
