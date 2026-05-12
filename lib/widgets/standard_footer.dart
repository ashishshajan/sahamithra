import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/language_provider.dart';

/// Mirrors /components/StandardFooter.tsx
/// White bar with gradient text "SAHAMITHRA - Empowering Families, Supporting Children"
/// and subtitle "Kozhikode District, Kerala"
class StandardFooter extends StatelessWidget {
  const StandardFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lang = LanguageProvider.to;
      final _ = lang.language;

      return Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.only(bottom: AppSpacing.xs.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 1, color: AppColors.neutral200),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md.w,
                  vertical: AppSpacing.sm.h,
                ),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        lang.t('footerTagline'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      lang.t('footerLocation'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Bottom navigation footer for the Dashboard
/// Matches the fixed mobile footer with Home/Schedule/Progress/Profile
class DashboardNavBar extends StatelessWidget {
  const DashboardNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lang = LanguageProvider.to;
      final _ = lang.language;

      final items = [
        _NavItem(icon: Icons.home_rounded, label: lang.t('home')),
        _NavItem(icon: Icons.calendar_month_rounded, label: lang.t('schedule')),
        _NavItem(icon: Icons.trending_up_rounded, label: lang.t('progress')),
        _NavItem(icon: Icons.person_rounded, label: lang.t('profile')),
      ];

      return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.neutral200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64.h,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final active = i == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (active)
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                          child: Icon(
                            item.icon,
                            size: 24.sp,
                            color: Colors.white,
                          ),
                        )
                      else
                        Icon(
                          item.icon,
                          size: 24.sp,
                          color: AppColors.textTertiary,
                        ),
                      SizedBox(height: 4.h),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                          color: active
                              ? AppColors.purple
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
    });
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}
