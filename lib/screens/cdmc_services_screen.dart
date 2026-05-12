import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_header.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/CDMCServicesScreen.tsx
class CDMCServicesScreen extends StatelessWidget {
  const CDMCServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lang = LanguageProvider.to;

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            GradientHeader(
              onBack: () => Get.back(),
              title: lang.t('cdmcSvcHeaderTitle'),
              subtitle: lang.t('cdmcSvcHeaderSubtitle'),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.base.r),
                children: [
                  // Info banner
                  Container(
                    padding: EdgeInsets.all(AppSpacing.base.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF3E8FF),
                          Color(0xFFFCE7F3),
                          Color(0xFFDBEAFE),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xl2),
                      border: Border.all(color: AppColors.purple100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.business_rounded,
                            size: 22.sp, color: AppColors.purple),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lang.t('cdmcSvcBannerTitle'),
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              SizedBox(height: 4.h),
                              Text(lang.t('cdmcSvcBannerDesc'),
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      color: AppColors.textSecondary,
                                      height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.base.h),

                  Text(lang.t('cdmcSvcAvailable'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        letterSpacing: 1.0,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(height: 10.h),

                  // Service cards
                  _ServiceCard(
                    icon: Icons.medical_services_rounded,
                    iconColor: AppColors.purple,
                    bgColor: AppColors.purple100,
                    title: lang.t('cdmcSvc1Title'),
                    subtitle: lang.t('cdmcSvc1Subtitle'),
                    items: [
                      lang.t('cdmcSvc1Item1'),
                      lang.t('cdmcSvc1Item2'),
                      lang.t('cdmcSvc1Item3'),
                      lang.t('cdmcSvc1Item4'),
                    ],
                    bulletColor: AppColors.purple,
                    btnLabel: lang.t('cdmcSvc1Btn'),
                  ),
                  SizedBox(height: 12.h),
                  _ServiceCard(
                    icon: Icons.favorite_rounded,
                    iconColor: AppColors.pink600,
                    bgColor: AppColors.pink100,
                    title: lang.t('cdmcSvc2Title'),
                    subtitle: lang.t('cdmcSvc2Subtitle'),
                    items: [
                      lang.t('cdmcSvc2Item1'),
                      lang.t('cdmcSvc2Item2'),
                      lang.t('cdmcSvc2Item3'),
                      lang.t('cdmcSvc2Item4'),
                    ],
                    bulletColor: AppColors.pink600,
                    btnLabel: lang.t('cdmcSvc2Btn'),
                  ),
                  SizedBox(height: 12.h),
                  _ServiceCard(
                    icon: Icons.school_rounded,
                    iconColor: AppColors.blue600,
                    bgColor: AppColors.blue100,
                    title: lang.t('cdmcSvc3Title'),
                    subtitle: lang.t('cdmcSvc3Subtitle'),
                    items: [
                      lang.t('cdmcSvc3Item1'),
                      lang.t('cdmcSvc3Item2'),
                      lang.t('cdmcSvc3Item3'),
                      lang.t('cdmcSvc3Item4'),
                    ],
                    bulletColor: AppColors.blue600,
                    btnLabel: lang.t('cdmcSvc3Btn'),
                  ),
                  SizedBox(height: 12.h),
                  _ServiceCard(
                    icon: Icons.groups_rounded,
                    iconColor: AppColors.purple,
                    bgColor: AppColors.purple100,
                    title: lang.t('cdmcSvc4Title'),
                    subtitle: lang.t('cdmcSvc4Subtitle'),
                    items: [
                      lang.t('cdmcSvc4Item1'),
                      lang.t('cdmcSvc4Item2'),
                      lang.t('cdmcSvc4Item3'),
                      lang.t('cdmcSvc4Item4'),
                    ],
                    bulletColor: AppColors.purple,
                    btnLabel: lang.t('cdmcSvc4Btn'),
                  ),
                  SizedBox(height: 12.h),
                  _ServiceCard(
                    icon: Icons.task_alt_rounded,
                    iconColor: AppColors.pink600,
                    bgColor: AppColors.pink100,
                    title: lang.t('cdmcSvc5Title'),
                    subtitle: lang.t('cdmcSvc5Subtitle'),
                    items: [
                      lang.t('cdmcSvc5Item1'),
                      lang.t('cdmcSvc5Item2'),
                      lang.t('cdmcSvc5Item3'),
                      lang.t('cdmcSvc5Item4'),
                    ],
                    bulletColor: AppColors.pink600,
                    btnLabel: lang.t('cdmcSvc5Btn'),
                  ),
                  SizedBox(height: AppSpacing.xl.h),

                  // Tertiary centers
                  Container(
                    padding: EdgeInsets.all(AppSpacing.base.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.xl2),
                      border: Border.all(
                          color: AppColors.purple.withOpacity(0.4), width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lang.t('cdmcSvcTertiaryTitle'),
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        SizedBox(height: 6.h),
                        Text(lang.t('cdmcSvcTertiaryDesc'),
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary)),
                        SizedBox(height: 10.h),
                        ...[
                          lang.t('cdmcSvcCenter1'),
                          lang.t('cdmcSvcCenter2'),
                          lang.t('cdmcSvcCenter3'),
                        ].map((c) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF3E8FF),
                                      Color(0xFFFCE7F3),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.business_rounded,
                                        size: 16.sp,
                                        color: AppColors.purple),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                        child: Text(c,
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                color:
                                                    AppColors.textPrimary))),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.base.h),
                ],
              ),
            ),
            const StandardFooter(),
          ],
        ),
      );
    });
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.bulletColor,
    required this.btnLabel,
  });

  final IconData icon;
  final Color iconColor, bgColor, bulletColor;
  final String title, subtitle, btnLabel;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(icon, size: 24.sp, color: iconColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    SizedBox(height: 2.h),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: BoxDecoration(
                          color: bulletColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                        child: Text(item,
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                                height: 1.3))),
                  ],
                ),
              )),
          SizedBox(height: 12.h),
          GradientButton(
            onPressed: () {},
            height: 42.h,
            child: Text(
              btnLabel,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
