import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'language_switcher.dart';

/// Mirrors /components/StandardHeader.tsx
///
/// White top bar with:
///  - Optional back button (rounded-xl bg-gray-100)
///  - Language switcher (dark variant)
///  - Logo + title section with gradient divider tagline
class StandardHeader extends StatelessWidget {
  const StandardHeader({
    super.key,
    this.onBack,
    this.showLogo = true,
    this.title,
    this.subtitle,
  });

  final VoidCallback? onBack;
  final bool showLogo;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Top nav bar ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.base.w,
              vertical: 12.h,
            ),
            child: Row(
              children: [
                // Back button or spacer
                if (onBack != null)
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16.sp,
                        color: AppColors.neutral700,
                      ),
                    ),
                  )
                else
                  SizedBox(width: 36.r),

                const Spacer(),
                const LanguageSwitcherDark(),
              ],
            ),
          ),

          // ─── Logo + title section ─────────────────────────────────────────
          if (showLogo)
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
                      // Logo card with glow
                      Stack(
                        children: [
                          // Gradient glow
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ).asBlur(opacity: 0.2),
                          ),
                          // White card
                          Container(
                            padding: EdgeInsets.all(AppSpacing.base.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppColors.purple.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.purple.withOpacity(0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 64.r,
                              height: 64.r,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64.r,
                                height: 64.r,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Center(
                                  child: Text(
                                    'S',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: AppSpacing.base.w),

                      // Title + subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title ?? 'SAHAMITHRA',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              subtitle ?? 'സഹമിത്ര',
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

                  // Tagline with gradient dividers (only when showing default logo)
                  if (title == null) ...[
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFE9D5FF),
                                  Color(0xFFFBCFE8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            'Empowering parents, nurturing potential',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFFFBCFE8),
                                  Color(0xFFE9D5FF),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

          // Bottom divider
          Container(height: 1, color: AppColors.neutral200),
        ],
      ),
    );
  }
}

extension _BlurWidget on Widget {
  Widget asBlur({double opacity = 0.2}) {
    return Opacity(opacity: opacity, child: this);
  }
}
