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
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileCtrl.dispose();
    super.dispose();
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
    final mobile = _mobileCtrl.text.replaceAll(' ', '');
    final lang = LanguageProvider.to;

    if (mobile.length != 10) {
      _showSnack(lang.t('enterValidMobile'), isError: true);
      return;
    }
    if (!_validateIndianMobile(mobile)) {
      _showSnack(lang.t('mobileStartWith'), isError: true);
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
        _showSnack(
          result['message']?.toString() ?? lang.t('loginErrorGeneric'),
          isError: true,
        );
      }
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lang = LanguageProvider.to;
      return Scaffold(
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
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.base.w,
                    vertical: AppSpacing.xl.h,
                  ),
                  children: [
                    _buildTabSwitcher(lang),
                    SizedBox(height: AppSpacing.base.h),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: child,
                      ),
                      child: _activeTab == 'parent'
                          ? _buildParentTab(lang)
                          : _buildGuestTab(lang),
                    ),

                    SizedBox(height: AppSpacing.base.h),

                    _buildFeatureGrid(lang),
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
                vertical: 12.h,
              ),
              child: Row(
                children: [
                  SizedBox(width: 36.r, height: 36.r),
                  const Spacer(),
                  const LanguageSwitcherDark(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl.w,
                0,
                AppSpacing.xl.w,
                AppSpacing.xl.h,
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
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(AppSpacing.base.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppColors.purple.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.purple.withValues(alpha: 0.12),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 64.r,
                              height: 64.r,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: AppSpacing.base.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.t('appName'),
                              style: TextStyle(
                                fontSize: 19.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              lang.t('loginLogoSubtitle'),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
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
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            lang.t('loginHeaderTagline'),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
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
        children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.xl.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF3E8FF), Color(0xFFFCE7F3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(Icons.smartphone_rounded,
                          size: 24.sp, color: AppColors.purple),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.t('guestAccess'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            lang.t('loginGuestSubtitle'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl.h),
                _GuestFeatureTile(
                  icon: Icons.play_circle_outline_rounded,
                  iconColor: AppColors.purple,
                  bgColor: AppColors.purple100,
                  title: lang.t('loginGuestTherapyTitle'),
                  subtitle: lang.t('loginGuestTherapySubtitle'),
                  tileBg: const Color(0xFFFAF5FF),
                ),
                SizedBox(height: 12.h),
                _GuestFeatureTile(
                  icon: Icons.favorite_outline_rounded,
                  iconColor: AppColors.pink600,
                  bgColor: AppColors.pink100,
                  title: lang.t('loginGuestAssessTitle'),
                  subtitle: lang.t('loginGuestAssessSubtitle'),
                  tileBg: const Color(0xFFFDF2F8),
                ),
                SizedBox(height: 12.h),
                _GuestFeatureTile(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.blue600,
                  bgColor: AppColors.blue100,
                  title: lang.t('loginGuestCentersTitle'),
                  subtitle: lang.t('loginGuestCentersSubtitle'),
                  tileBg: const Color(0xFFEFF6FF),
                ),
                SizedBox(height: AppSpacing.xl.h),
                GradientButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.publicDashboard),
                  height: 56.h,
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
                      Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 18.sp),
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
          Row(
            children: [
              Container(
                height: 56.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    bottomLeft: Radius.circular(12.r),
                  ),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Center(
                  child: Text(
                    '+91',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    hintText: '00000 00000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      children: [
        _FeatureCard(
            icon: Icons.favorite,
            label: lang.t('loginFeatureFreeTests'),
            color: AppColors.purple),
        _FeatureCard(
            icon: Icons.video_library,
            label: lang.t('loginFeatureVideos'),
            color: AppColors.pink600),
        _FeatureCard(
            icon: Icons.location_on,
            label: lang.t('loginFeatureCenters'),
            color: AppColors.blue600),
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

  const _GuestFeatureTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.tileBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11.sp, color: AppColors.textTertiary),
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

  const _FeatureCard(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
