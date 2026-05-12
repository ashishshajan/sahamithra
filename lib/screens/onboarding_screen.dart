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

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentSlide = 0;
  late final PageController _pageController;

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
    _pageController = PageController(initialPage: _currentSlide);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToSlide(int index) async {
    if (index < 0 || index >= _slides.length) return;
    if (!_pageController.hasClients) return;
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
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
                    18.h,
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

                // ─── Slide content (fills down to dots) + dots ───────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (index) {
                            if (!mounted) return;
                            setState(() => _currentSlide = index);
                          },
                          itemCount: _slides.length,
                          itemBuilder: (context, pageIndex) {
                            final slide = _slides[pageIndex];
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final h = constraints.maxHeight;
                                final w = constraints.maxWidth;
                                final shortest = w < h ? w : h;
                                // Scale down on short viewports; cap on very tall/narrow.
                                final vScale = (h / 520).clamp(0.62, 1.0);
                                final iconD =
                                    (shortest * 0.26).clamp(72.0, 128.0);
                                final iconGlyph = (iconD * 0.48).clamp(28.0, 64.0);
                                final gapSm = (10 * vScale).clamp(6.0, 14.0);
                                final gapMd = (18 * vScale).clamp(10.0, 24.0);
                                final titleSize = (22 * vScale).clamp(17.0, 24.0);
                                final bodySize = (14 * vScale).clamp(12.0, 15.0);
                                final featureSize =
                                    (13 * vScale).clamp(11.0, 14.0);
                                final cardPad =
                                    (AppSpacing.base * vScale).clamp(10.0, 16.0);

                                return SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xl.w,
                                    vertical: (AppSpacing.sm * vScale).h,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: h,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Icon circle
                                        Center(
                                          child: Container(
                                            width: iconD,
                                            height: iconD,
                                            decoration: BoxDecoration(
                                              gradient: slide.gradient,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.purple
                                                      .withOpacity(0.38),
                                                  blurRadius: 24,
                                                  offset: const Offset(0, 7),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              slide.icon,
                                              size: iconGlyph,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: gapMd),

                                        // Title
                                        Text(
                                          lang.t(slide.titleKey),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: titleSize.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                            height: 1.3,
                                          ),
                                        ),

                                        SizedBox(height: gapSm),

                                        // Description
                                        Text(
                                          lang.t(slide.descriptionKey),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: bodySize.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.textSecondary,
                                            height: 1.55,
                                          ),
                                        ),

                                        SizedBox(height: gapMd),

                                        // Feature list card
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(cardPad.r),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.xl2.r,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.06),
                                                blurRadius: 16,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: List.generate(
                                              slide.featureKeys.length,
                                              (i) => Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: i <
                                                          slide.featureKeys.length -
                                                              1
                                                      ? (gapSm * 0.85)
                                                      : 0,
                                                ),
                                                child: _FeatureItem(
                                                  text: lang.t(
                                                    slide.featureKeys[i],
                                                  ),
                                                  fontSize: featureSize.sp,
                                                  vScale: vScale,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Dots sit flush under slide region (all screen sizes)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, bottom: 8.h),
                        child: Row(
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
                      ),
                    ],
                  ),
                ),

                // ─── Footer: button ─────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl.w,
                    0,
                    AppSpacing.xl.w,
                    16.h,
                  ),
                  child: Column(
                    children: [
                      // Next / Get Started button
                      GradientButton(
                        onPressed: _handleNext,
                        height: 52.h,
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

                      SizedBox(height: 14.h),

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
  const _FeatureItem({
    required this.text,
    required this.fontSize,
    this.vScale = 1.0,
  });

  final String text;
  final double fontSize;
  final double vScale;

  @override
  Widget build(BuildContext context) {
    final dim = (20 * vScale).clamp(16.0, 22.0);
    final inner = (12 * vScale).clamp(10.0, 14.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: dim.r,
          height: dim.r,
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
            size: inner.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(width: (11 * vScale).clamp(8.0, 12.0).w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
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
