import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'language_switcher.dart';
import 'logo_widget.dart';

/// Gradient purple-pink-blue header used on inner screens
/// that show the full gradient branding (e.g. Assessment Menu, CDMC, etc.)
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    this.onBack,
    required this.title,
    this.subtitle,
    this.showLogo = true,
    this.showLanguageSwitcher = true,
    this.trailing,
  });

  final VoidCallback? onBack;
  final String title;
  final String? subtitle;
  final bool showLogo;
  final bool showLanguageSwitcher;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top nav row
              Row(
                children: [
                  if (onBack != null)
                    GestureDetector(
                      onTap: onBack ?? () => Get.back(),
                      child: Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: AppColors.white20,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 36.r),

                  SizedBox(width: 8.w),

                  if (showLogo)
                    const Expanded(
                      child: LogoWidget(
                        size: LogoSize.small,
                        showText: true,
                        withBackground: true,
                      ),
                    )
                  else
                    const Spacer(),

                  if (trailing != null) trailing!,
                  if (showLanguageSwitcher) ...[
                    SizedBox(width: 8.w),
                    const LanguageSwitcher(),
                  ],
                ],
              ),

              SizedBox(height: 16.h),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4.h),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
