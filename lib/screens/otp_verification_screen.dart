import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/language_switcher.dart';
import '../widgets/standard_footer.dart';
import '../routes/app_routes.dart';

/// Mirrors /components/OTPVerificationScreen.tsx
///
/// Standalone 6-digit OTP verification screen.
/// Receives: arguments = { 'mobile': String }
/// On success navigates to:
///   - AppRoutes.dashboard   (existing user — user_type: "Existing")
///   - AppRoutes.registration (new user     — user_type: "New")
class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _resendTimer = 30;
  bool _canResend = false;
  Timer? _timer;
  String _mobileNumber = '';

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _mobileNumber = args?['mobile'] as String? ?? '';

    _startResendTimer();
    _setupBackspaceHandlers();

    // Auto-focus first box after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _setupBackspaceHandlers() {
    for (int i = 0; i < 6; i++) {
      final index = i;
      _focusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[index].text.isEmpty &&
            index > 0) {
          _controllers[index - 1].clear();
          _focusNodes[index - 1].requestFocus();
          setState(() {});
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() {
      _resendTimer = 30;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  String get _otpValue => _controllers.map((c) => c.text).join();
  bool get _isComplete => _otpValue.length == 6;

  void _onDigitChanged(int index, String value) {
    // Accept only a single digit; discard non-numeric input
    if (value.isNotEmpty && !RegExp(r'^\d$').hasMatch(value)) {
      _controllers[index].clear();
      return;
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == 5) {
      _focusNodes[index].unfocus();
    }
    setState(() {});
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  Future<void> _handleVerify() async {
    if (!_isComplete || _isLoading) return;

    setState(() => _isLoading = true);

    // Call verifyOtp API
    final result = await NetworkHelper().verifyOtp(_mobileNumber, _otpValue);

    if (!mounted) return;

    if (result['success']) {
      final data = result['data'];
      final userType = data?['user_type']; // "New" or "Existing"
      final accessToken = data?['access_token'];
      final refreshToken = data?['refresh_token'];
      final isExistingUser = userType == "Existing";

      // ── Save Session Data ──────────────────────────────────────────────────
      final utils = GlobalUtils();
      await utils.setPhoneNumber(_mobileNumber);

      if (isExistingUser && accessToken != null) {
        await utils.setToken(accessToken);
        if (refreshToken != null && refreshToken is String) {
          await utils.setRefreshToken(refreshToken);
        }
        await utils.setLoggedIn(true);

        // Fetch Init Data for Existing User
        final initResult = await NetworkHelper().getInit();
        if (initResult['success']) {
          final initData = initResult['data'];
          if (initData is Map<String, dynamic>) {
            await utils.setInitUserAndFirstChild(initData);
          } else if (initData is Map) {
            await utils.setUserData(initData.cast<String, dynamic>());
          }
        }
      }

      setState(() => _isLoading = false);

      _showSnack(
        isExistingUser
            ? 'Welcome back! 🎉 Logging you in...'
            : (data?['message'] ?? 'OTP verified! ✅ Setting up your account...'),
        isError: false,
      );

      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;

      if (isExistingUser) {
        Get.offAllNamed(
          AppRoutes.dashboard,
          arguments: {
            'mobile': _mobileNumber,
            'token': accessToken,
          },
        );
      } else {
        Get.offAllNamed(
          AppRoutes.registration,
          arguments: {
            'mobile': _mobileNumber,
          },
        );
      }
    } else {
      setState(() => _isLoading = false);
      _showSnack(result['message'] ?? 'Verification failed', isError: true);
    }
  }

  Future<void> _handleResend() async {
    if (!_canResend || _isLoading) return;

    setState(() => _isLoading = true);

    // Trigger verifyMobile API service again
    final result = await NetworkHelper().verifyMobile(_mobileNumber);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      for (final c in _controllers) c.clear();
      
      _startResendTimer();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNodes[0].requestFocus();
      });
      
      _showSnack('OTP resent successfully!', isError: false);
    } else {
      _showSnack(result['message'] ?? 'Failed to resend OTP', isError: true);
    }
    
    setState(() {});
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

  /// Masks the phone number: 9876543210 → 98XXX X3210
  String _maskMobile(String number) {
    if (number.length == 10) {
      return '${number.substring(0, 2)}XXX X${number.substring(6)}';
    }
    return number;
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ── Gradient header ────────────────────────────────────────────────
          _buildGradientHeader(),

          // ── Scrollable content ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.base.w,
                vertical: AppSpacing.base.h,
              ),
              child: Column(
                children: [
                  SizedBox(height: AppSpacing.sm.h),
                  _buildOtpCard(),
                  SizedBox(height: AppSpacing.xl.h),
                  _buildInfoCard(),
                  SizedBox(height: AppSpacing.xl.h),
                ],
              ),
            ),
          ),

          // ── Footer ─────────────────────────────────────────────────────────
          const StandardFooter(),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildGradientHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Back + Language row
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.base.w,
                vertical: 12.h,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const LanguageSwitcher(),
                ],
              ),
            ),

            // Logo + Title section
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl.w,
                0,
                AppSpacing.xl.w,
                AppSpacing.xl.h,
              ),
              child: Column(
                children: [
                  // Logo card
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 48.r,
                      height: 48.r,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Text(
                            'S',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // App name
                  Obx(
                    () => Text(
                      LanguageProvider.to.t('appName'),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    'OTP Verification',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── OTP Card ───────────────────────────────────────────────────────────────
  Widget _buildOtpCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header ────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: AppColors.purple100,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(
                  Icons.shield_rounded,
                  size: 20.sp,
                  color: AppColors.purple,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Enter the code sent to your mobile',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: AppSpacing.xl.h),
          Container(height: 1, color: AppColors.neutral100),
          SizedBox(height: AppSpacing.xl.h),

          // ── Mobile number display ──────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(
                  'OTP sent to',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _maskMobile(_mobileNumber),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.xl.h),

          // ── Boxes row ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) => _buildOtpBox(index)),
          ),

          SizedBox(height: AppSpacing.xl.h),

          // ── Resend section ─────────────────────────────────────────────────
          Center(
            child: _canResend
                ? TextButton(
                    onPressed: _handleResend,
                    child: Text(
                      'Resend Code',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.purple,
                      ),
                    ),
                  )
                : RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textTertiary,
                      ),
                      children: [
                        const TextSpan(text: 'Resend code in '),
                        TextSpan(
                          text: '0:$_resendTimer',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const TextSpan(text: 's'),
                      ],
                    ),
                  ),
          ),

          SizedBox(height: AppSpacing.xl.h),

          // ── Verify button ──────────────────────────────────────────────────
          GradientButton(
            onPressed: _isComplete && !_isLoading ? _handleVerify : null,
            isLoading: _isLoading,
            child: Text(
              'Verify & Login',
              style: AppTextStyles.button,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 51.r,
      height: 54.r,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.purple,
        ),
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) => _onDigitChanged(index, value),
      ),
    );
  }

  // ── Info Card ──────────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.purple, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'For your security, please do not share this OTP with anyone.',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.purple,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
