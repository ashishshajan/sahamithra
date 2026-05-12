import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../providers/language_provider.dart';

/// Language toggle chip matching the web LanguageSwitcher component.
/// Shows "EN | ML" with the active language highlighted via gradient.
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lang = LanguageProvider.to;
      final isEn = lang.isEnglish;

      return Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LangTab(
              label: 'EN',
              active: isEn,
              onTap: () => lang.setLanguage('en'),
            ),
            Container(
              width: 1,
              height: 20.h,
              color: Colors.white.withOpacity(0.3),
            ),
            _LangTab(
              label: 'ML',
              active: !isEn,
              onTap: () => lang.setLanguage('ml'),
            ),
          ],
        ),
      );
    });
  }
}

/// Variant for white/light backgrounds (e.g. StandardHeader)
class LanguageSwitcherDark extends StatelessWidget {
  const LanguageSwitcherDark({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lang = LanguageProvider.to;
      final isEn = lang.isEnglish;

      return Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LangTabDark(
              label: 'EN',
              active: isEn,
              onTap: () => lang.setLanguage('en'),
            ),
            Container(
              width: 1,
              height: 20.h,
              color: AppColors.neutral300,
            ),
            _LangTabDark(
              label: 'ML',
              active: !isEn,
              onTap: () => lang.setLanguage('ml'),
            ),
          ],
        ),
      );
    });
  }
}

class _LangTab extends StatelessWidget {
  const _LangTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.purple : Colors.white.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _LangTabDark extends StatelessWidget {
  const _LangTabDark({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: active ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
