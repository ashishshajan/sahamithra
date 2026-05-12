import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_header.dart';
import '../widgets/standard_footer.dart';
import '../routes/app_routes.dart';

void _openAssessmentDateOfBirth({
  required String nextRoute,
  required String assessmentName,
  required String assessmentDescription,
  required Color primaryColor,
  required Color secondaryColor,
  DateTime? dobFirstDate,
  DateTime? dobLastDate,
}) {
  final lang = LanguageProvider.to;
  final args = <String, dynamic>{
    'nextRoute': nextRoute,
    'title': lang.t('dateOfBirth'),
    'subtitle': lang.t('assessmentDobHeaderSubtitle'),
    'assessmentName': assessmentName,
    'assessmentDescription': assessmentDescription,
    'primaryColor': primaryColor,
    'secondaryColor': secondaryColor,
  };
  if (dobFirstDate != null) args['dobFirstDate'] = dobFirstDate;
  if (dobLastDate != null) args['dobLastDate'] = dobLastDate;
  Get.toNamed(AppRoutes.assessmentDob, arguments: args);
}

/// Mirrors /components/AssessmentMenuScreen.tsx
class AssessmentMenuScreen extends StatelessWidget {
  const AssessmentMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(
        () => Column(
          children: [
            GradientHeader(
              onBack: () => Get.back(),
              title: LanguageProvider.to.t('assessmentMenuChooseTitle'),
              subtitle: LanguageProvider.to.t('assessmentMenuChooseSubtitle'),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.base.r),
                children: [
                  _AssessmentCard(
                    icon: Icons.assignment_turned_in_rounded,
                    iconGradient: const LinearGradient(
                      colors: [Color(0xFFDBEAFE), Color(0xFFCFFAFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    iconColor: AppColors.blue600,
                    title:
                        '${LanguageProvider.to.t('developmentalScreening')} (${LanguageProvider.to.t('tdsc')})',
                    subtitle: LanguageProvider.to.t('tdscDescription'),
                    description:
                        LanguageProvider.to.t('assessmentMenuTdscDescription'),
                    tags: [
                      _Tag(
                        LanguageProvider.to.t('assessmentMenuTagYears06'),
                        const Color(0xFFDBEAFE),
                        const Color(0xFF1D4ED8),
                      ),
                      _Tag(
                        LanguageProvider.to.t('assessmentMenuTagMin1520'),
                        const Color(0xFFCFFAFE),
                        const Color(0xFF0E7490),
                      ),
                      _Tag(
                        LanguageProvider.to.t('assessmentMenuTagRecommended'),
                        const Color(0xFFF3E8FF),
                        const Color(0xFF7C3AED),
                      ),
                    ],
                    onTap: () => _openAssessmentDateOfBirth(
                      nextRoute: AppRoutes.tdsc,
                      assessmentName:
                          '${LanguageProvider.to.t('developmentalScreening')} (${LanguageProvider.to.t('tdsc')})',
                      assessmentDescription:
                         LanguageProvider.to.t('assessmentMenuTdscDescription'),
                      primaryColor: AppColors.blue600,
                      secondaryColor: const Color(0xFFCFFAFE),
                    ),
                    hoverBorder: AppColors.blue600,
                  ),
                  SizedBox(height: AppSpacing.base.h),

                  _AssessmentCard(
                    icon: Icons.menu_book_rounded,
                    iconGradient: const LinearGradient(
                      colors: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    iconColor: AppColors.green600,
                    title: LanguageProvider.to.t('assessmentMenuLestTitle'),
                    subtitle: LanguageProvider.to.t('lestDescription'),
                    description:
                        LanguageProvider.to.t('assessmentMenuLestDescription'),
                    tags: [
                      _Tag(
                        LanguageProvider.to.t('assessmentMenuTagYears06'),
                        const Color(0xFFD1FAE5),
                        const Color(0xFF15803D),
                      ),
                      _Tag(
                        LanguageProvider.to.t('assessmentMenuTagMin1015'),
                        const Color(0xFFA7F3D0),
                        const Color(0xFF047857),
                      ),
                    ],
                    onTap: () => _openAssessmentDateOfBirth(
                      nextRoute: AppRoutes.lest,
                      assessmentName:
                          LanguageProvider.to.t('assessmentMenuLestTitle'),
                      assessmentDescription:
                          LanguageProvider.to.t('assessmentMenuLestDescription'),
                      primaryColor: AppColors.green600,
                      secondaryColor: const Color(0xFFA7F3D0),
                    ),
                    hoverBorder: AppColors.green600,
                  ),
                  SizedBox(height: AppSpacing.base.h),

                  _AssessmentCard(
                    icon: Icons.favorite_rounded,
                    iconGradient: const LinearGradient(
                      colors: [Color(0xFFF3E8FF), Color(0xFFFCE7F3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    iconColor: AppColors.purple,
                    title: LanguageProvider.to.t('assessmentMenuStressTitle'),
                    subtitle:
                        LanguageProvider.to.t('assessmentMenuStressSubtitle'),
                    description:
                        LanguageProvider.to.t('assessmentMenuStressDescription'),
                    tags: [
                      _Tag(
                        LanguageProvider.to.t('assessmentMenuTagParents'),
                        const Color(0xFFF3E8FF),
                        const Color(0xFF7C3AED),
                      ),
                      _Tag(
                        LanguageProvider.to.t('assessmentMenuTag10Min'),
                        const Color(0xFFFCE7F3),
                        const Color(0xFFBE185D),
                      ),
                      _Tag(
                        LanguageProvider.to.t('assessmentMenuTagSelfCare'),
                        const Color(0xFFFEE2E2),
                        const Color(0xFFDC2626),
                      ),
                    ],
                    onTap: () => _openAssessmentDateOfBirth(
                      nextRoute: AppRoutes.stressNew,
                      assessmentName:
                          LanguageProvider.to.t('assessmentMenuStressTitle'),
                      assessmentDescription:
                          LanguageProvider.to.t('assessmentMenuStressDescription'),
                      primaryColor: AppColors.purple,
                      secondaryColor: const Color(0xFFFCE7F3),
                      dobFirstDate: DateTime(
                        DateTime.now().year - 18,
                        DateTime.now().month,
                        DateTime.now().day,
                      ),
                    ),
                    hoverBorder: AppColors.purple,
                  ),
                  SizedBox(height: AppSpacing.base.h),

                  _AssessmentCard(
                    icon: Icons.warning_amber_rounded,
                    iconGradient: const LinearGradient(
                      colors: [Color(0xFFFFEDD5), Color(0xFFFEF3C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    iconColor: AppColors.orange600,
                    title: LanguageProvider.to.t('riskFactorChecklist'),
                    subtitle:
                        LanguageProvider.to.t('assessmentMenuRiskSubtitle'),
                    description:
                        LanguageProvider.to.t('assessmentMenuRiskDescription'),
                    tags: [
                      _Tag(
                        LanguageProvider.to.t('assessmentMenuTagAllAges'),
                        const Color(0xFFFFEDD5),
                        const Color(0xFFEA580C),
                      ),
                      _Tag(
                        LanguageProvider.to.t('assessmentMenuTagMin510'),
                        const Color(0xFFFEF3C7),
                        const Color(0xFFD97706),
                      ),
                      _Tag(
                        LanguageProvider.to
                            .t('assessmentMenuTagOptionalShort'),
                        const Color(0xFFF1F5F9),
                        const Color(0xFF475569),
                      ),
                    ],
                    onTap: () => _openAssessmentDateOfBirth(
                      nextRoute: AppRoutes.risk,
                      assessmentName:
                          LanguageProvider.to.t('riskFactorChecklist'),
                      assessmentDescription:
                          LanguageProvider.to.t('assessmentMenuRiskDescription'),
                      primaryColor: AppColors.orange600,
                      secondaryColor: const Color(0xFFFEF3C7),
                      dobFirstDate: DateTime(
                        DateTime.now().year - 100,
                        DateTime.now().month,
                        DateTime.now().day,
                      ),
                    ),
                    hoverBorder: AppColors.orange600,
                  ),
                  SizedBox(height: AppSpacing.xl.h),

                  Container(
                    padding: EdgeInsets.all(AppSpacing.xl.r),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(AppRadius.xl2),
                      border: Border.all(
                        color: AppColors.purple.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: AppColors.purple100,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: 18.sp,
                                color: AppColors.purple,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                LanguageProvider.to
                                    .t('assessmentMenuAboutTitle'),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          LanguageProvider.to.t('assessmentMenuAboutBody'),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius:
                                BorderRadius.circular(AppRadius.xl),
                          ),
                          child: Text(
                            LanguageProvider.to.t('assessmentMenuTip'),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.base.h),

                  Text(
                    LanguageProvider.to.t('assessmentMenuConfidentialNote'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.base.h),
                ],
              ),
            ),
            const StandardFooter(),
          ],
        ),
      ),
    );
  }
}

class _Tag {
  final String label;
  final Color bg;
  final Color text;
  const _Tag(this.label, this.bg, this.text);
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({
    required this.icon,
    required this.iconGradient,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tags,
    required this.onTap,
    required this.hoverBorder,
  });

  final IconData icon;
  final LinearGradient iconGradient;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;
  final List<_Tag> tags;
  final VoidCallback onTap;
  final Color hoverBorder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          border: Border.all(color: AppColors.neutral200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [hoverBorder.withOpacity(0.6), hoverBorder],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xl2),
                  topRight: Radius.circular(AppRadius.xl2),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          gradient: iconGradient,
                          borderRadius:
                              BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Icon(icon, size: 28.sp, color: iconColor),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 22.sp,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          iconGradient.colors.first,
                          iconGradient.colors.last.withOpacity(0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 6.h,
                          children: tags
                              .map((t) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: t.bg,
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.full),
                                    ),
                                    child: Text(
                                      t.label,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500,
                                        color: t.text,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
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
}
