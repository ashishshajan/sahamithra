import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/language_switcher.dart';
import '../widgets/standard_footer.dart';
import '../core/global_utils.dart';
import '../routes/app_routes.dart';

/// Mirrors /components/LoginScreen.tsx
///
/// Design: white header + gradient-50 bg
/// Two tabs: Guest | Parent
/// Guest tab: shows feature highlights + "Explore as Guest" button
/// Parent tab: mobile input (+91 prefix) + OTP flow
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _activeTab = 'guest'; // 'guest' | 'parent'
  final TextEditingController _mobileCtrl = TextEditingController();
  final FocusNode _mobileFocusNode = FocusNode();
  final GlobalKey _mobileFieldKey = GlobalKey();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mobileFocusNode.addListener(_handleMobileFocusChange);

    // Allow callers to pre-select a tab (e.g. open Parent login directly).
    final rawArgs = Get.arguments;
    if (rawArgs is Map) {
      final initialTab = (rawArgs['initialTab'] ?? rawArgs['tab'])?.toString();
      if (initialTab == 'parent' || initialTab == 'guest') {
        _activeTab = initialTab!;
      }
    }
  }

  @override
  void dispose() {
    _mobileFocusNode.removeListener(_handleMobileFocusChange);
    _mobileFocusNode.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  void _handleMobileFocusChange() {
    setState(() {});
    if (_mobileFocusNode.hasFocus) {
      // Wait until keyboard opens, then keep the focused field visible.
      Future.delayed(const Duration(milliseconds: 250), _scrollMobileFieldIntoView);
    }
  }

  void _scrollMobileFieldIntoView() {
    final fieldContext = _mobileFieldKey.currentContext;
    if (fieldContext == null) return;

    Scrollable.ensureVisible(
      fieldContext,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: 0.25,
    );
  }

  bool _validateIndianMobile(String number) {
    final regex = RegExp(r'^[6-9]\d{9}$');
    return regex.hasMatch(number);
  }

  void _handleTabChange(String tab) {
    setState(() {
      _activeTab = tab;
      _mobileCtrl.clear();
      _isLoading = false;
    });
  }

  void _handleLogin() async {
    FocusScope.of(context).unfocus();
    final mobile = _mobileCtrl.text.replaceAll(' ', '');
    final lang = LanguageProvider.to;

    if (mobile.length != 10) {
      _showErrorAndRefocus(lang.t('enterValidMobile'));
      return;
    }
    if (!_validateIndianMobile(mobile)) {
      _showErrorAndRefocus(lang.t('mobileStartWith'));
      return;
    }

    setState(() => _isLoading = true);

    final result = await NetworkHelper().verifyMobile(mobile);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        _showSnack(lang.t('otpSentSuccess'), isError: false);
        Get.toNamed(AppRoutes.otpVerification, arguments: {'mobile': mobile});
      } else {
        _showErrorAndRefocus(
          result['message']?.toString() ?? lang.t('loginErrorGeneric'),
        );
      }
    }
  }

  void _showErrorAndRefocus(String msg) {
    _showSnack(msg, isError: true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      _mobileFocusNode.requestFocus();
    });
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.fromLTRB(
          16.r,
          16.r,
          16.r,
          16.r + keyboardBottom,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lang = LanguageProvider.to;
      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            _buildHeader(lang),

            Expanded(
              child: Container(
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
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.base.w,
                    AppSpacing.xl.h,
                    AppSpacing.base.w,
                    AppSpacing.xl.h,
                  ),
                  children: [
                    _buildTabSwitcher(lang),
                    SizedBox(height: AppSpacing.base.h),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) {
                        final slideAnim = Tween<Offset>(
                          begin: const Offset(0.02, 0),
                          end: Offset.zero,
                        ).animate(anim);
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: slideAnim,
                            child: child,
                          ),
                        );
                      },
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: _activeTab == 'parent'
                            ? _buildParentTab(lang)
                            : _buildGuestTab(lang),
                      ),
                    ),

                    SizedBox(height: AppSpacing.base.h),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      offset: _activeTab == 'guest'
                          ? Offset(0, -14.h / 200)
                          : Offset.zero,
                      child: _buildFeatureGrid(lang),
                    ),
                  ],
                ),
              ),
            ),

            _buildBottomFooter(),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(LanguageProvider lang) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.base.w,
                vertical: 8.h,
              ),
              child: Row(
                children: [
                  SizedBox(width: 32.r, height: 32.r),
                  const Spacer(),
                  const LanguageSwitcherDark(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg.w,
                0,
                AppSpacing.lg.w,
                AppSpacing.lg.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.2,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(AppSpacing.sm.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: AppColors.purple.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.purple.withValues(alpha: 0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 48.r,
                              height: 48.r,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: AppSpacing.sm.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.t('appName'),
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              lang.t('loginLogoSubtitle'),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Color(0xFFE9D5FF),
                              Color(0xFFFBCFE8),
                              Colors.transparent,
                            ]),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Text(
                            lang.t('loginHeaderTagline'),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textTertiary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.transparent,
                              Color(0xFFFBCFE8),
                              Color(0xFFE9D5FF),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.neutral200),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher(LanguageProvider lang) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _TabButton(
            icon: Icons.smartphone_rounded,
            label: lang.t('loginTabGuest'),
            active: _activeTab == 'guest',
            onTap: () => _handleTabChange('guest'),
          ),
          SizedBox(width: 8.w),
          _TabButton(
            icon: Icons.account_circle_rounded,
            label: lang.t('loginTabParent'),
            active: _activeTab == 'parent',
            onTap: () => _handleTabChange('parent'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestTab(LanguageProvider lang) {
    const pad = AppSpacing.xl;
    final gapTiles = 8.h;
    final gapHeader = 12.h;
    final gapBeforeCta = 14.h;
    final ctaH = 50.h;

    return Container(
      key: const ValueKey('guest'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 5,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(pad.r, pad.r, pad.r, pad.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GuestFeatureTile(
                  icon: Icons.smartphone_rounded,
                  iconColor: AppColors.purple,
                  bgColor: AppColors.purple100,
                  title: lang.t('guestAccess'),
                  subtitle: lang.t('loginGuestSubtitle'),
                  tileBg: Colors.white,
                ),
                SizedBox(height: gapTiles),
                _GuestFeatureTile(
                  icon: Icons.play_circle_outline_rounded,
                  iconColor: AppColors.purple,
                  bgColor: AppColors.purple100,
                  title: lang.t('loginGuestTherapyTitle'),
                  subtitle: lang.t('loginGuestTherapySubtitle'),
                  tileBg: const Color(0xFFFAF5FF),
                ),
                SizedBox(height: gapTiles),
                _GuestFeatureTile(
                  icon: Icons.favorite_outline_rounded,
                  iconColor: AppColors.pink600,
                  bgColor: AppColors.pink100,
                  title: lang.t('loginGuestAssessTitle'),
                  subtitle: lang.t('loginGuestAssessSubtitle'),
                  tileBg: const Color(0xFFFDF2F8),
                ),
                SizedBox(height: gapBeforeCta),
                GradientButton(
                  onPressed: () async {
                    await GlobalUtils().setGuestUser(true);
                    Get.toNamed(AppRoutes.publicDashboard);
                  },
                  height: ctaH,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          lang.t('loginGuestCta'),
                          style: AppTextStyles.button,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 17.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentTab(LanguageProvider lang) {
    return Container(
      key: const ValueKey('parent'),
      padding: EdgeInsets.all(AppSpacing.xl.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.t('loginMobileLabel'), style: AppTextStyles.h3),
          SizedBox(height: 8.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 56.h,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _mobileFocusNode.hasFocus
                    ? AppColors.purple.withValues(alpha: 0.55)
                    : AppColors.neutral200,
                width: _mobileFocusNode.hasFocus ? 1.5 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.w, right: 12.w),
                  child: Text(
                    '+91',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 26.h,
                  color: AppColors.neutral200,
                ),
                Expanded(
                  child: Container(
                    key: _mobileFieldKey,
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _mobileCtrl,
                      focusNode: _mobileFocusNode,
                      keyboardType: TextInputType.phone,
                      onTap: _scrollMobileFieldIntoView,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: '00000 00000',
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(
                          12.w,
                          14.h,
                          14.w,
                          14.h,
                        ),
                        filled: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl.h),
          GradientButton(
            onPressed: _isLoading ? null : _handleLogin,
            height: 56.h,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(lang.t('loginSendOtp'), style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(LanguageProvider lang) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _FeatureCard(
            icon: Icons.favorite,
            label: lang.t('loginFeatureFreeTests'),
            color: AppColors.purple,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _FeatureCard(
            icon: Icons.video_library,
            label: lang.t('loginFeatureVideos'),
            color: AppColors.pink600,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _FeatureCard(
            icon: Icons.location_on,
            label: lang.t('loginFeatureCenters'),
            color: AppColors.blue600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomFooter() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(AppSpacing.base.r),
      child: const StandardFooter(),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            gradient: active ? AppColors.primaryGradient : null,
            color: active ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 20.sp,
                  color: active ? Colors.white : AppColors.textTertiary),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestFeatureTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final Color tileBg;
  final EdgeInsetsGeometry? tilePadding;

  const _GuestFeatureTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.tileBg,
    this.tilePadding,
  });

  @override
  Widget build(BuildContext context) {
    const lineHeight = 1.3;
    final fontSize = 14.sp;
    final titleStyle = AppTextStyles.bodyMedium.copyWith(
      fontSize: fontSize,
      height: lineHeight,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      leadingDistribution: TextLeadingDistribution.even,
    );
    final subtitleStyle = AppTextStyles.bodyMedium.copyWith(
      fontSize: fontSize,
      height: lineHeight,
      fontWeight: FontWeight.w400,
      color: AppColors.textTertiary,
      leadingDistribution: TextLeadingDistribution.even,
    );

    StrutStyle strutFor(TextStyle s) => StrutStyle(
          fontSize: s.fontSize,
          height: s.height,
          fontWeight: s.fontWeight,
          leadingDistribution: s.leadingDistribution,
          forceStrutHeight: true,
        );

    return Container(
      width: double.infinity,
      padding: tilePadding ?? EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  softWrap: true,
                  style: titleStyle,
                  strutStyle: strutFor(titleStyle),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  softWrap: true,
                  style: subtitleStyle,
                  strutStyle: strutFor(subtitleStyle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22.sp),
          SizedBox(height: 3.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                height: 1.15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
