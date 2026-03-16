import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Sizes map: small=40, medium=56, large=80 (matches sizeClasses in Logo.tsx)
enum LogoSize { small, medium, large }

/// Mirrors /components/Logo.tsx
/// Renders the SAHAMITHRA logo image with optional gradient text title.
/// withBackground: wraps logo in white/translucent card for dark headers.
class LogoWidget extends StatelessWidget {
  const LogoWidget({
    super.key,
    this.size = LogoSize.medium,
    this.showText = true,
    this.withBackground = false,
    this.onBack,
  });

  final LogoSize size;
  final bool showText;
  final bool withBackground;
  final VoidCallback? onBack;

  double get _imgSize {
    switch (size) {
      case LogoSize.small:
        return 40.r;
      case LogoSize.medium:
        return 56.r;
      case LogoSize.large:
        return 80.r;
    }
  }

  double get _fontSize {
    switch (size) {
      case LogoSize.small:
        return 14.sp;
      case LogoSize.medium:
        return 16.sp;
      case LogoSize.large:
        return 22.sp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onBack != null) ...[
          GestureDetector(
            onTap: onBack,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.sp,
              color: withBackground ? Colors.white : AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 8.w),
        ],
        _buildLogoImage(),
        if (showText) ...[
          SizedBox(width: 10.w),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: Text(
              'SAHAMITHRA',
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.w700,
                color: withBackground ? Colors.white : Colors.white,
                // withBackground shows plain white; no-bg shows gradient
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogoImage() {
    final imgWidget = Image.asset(
      'assets/images/logo.png',
      width: _imgSize,
      height: _imgSize,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _placeholderLogo(),
    );

    if (withBackground) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.sm.r),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: imgWidget,
      );
    }
    return imgWidget;
  }

  Widget _placeholderLogo() {
    // Gradient circle fallback when asset is not found
    return Container(
      width: _imgSize,
      height: _imgSize,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          'S',
          style: TextStyle(
            color: Colors.white,
            fontSize: (_imgSize * 0.5).sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
