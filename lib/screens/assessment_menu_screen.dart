import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/gradient_header.dart';
import '../widgets/standard_footer.dart';
import '../routes/app_routes.dart';

/// Mirrors /components/AssessmentMenuScreen.tsx
class AssessmentMenuScreen extends StatelessWidget {
  const AssessmentMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          GradientHeader(
            onBack: () => Get.back(),
            title: 'Choose Your Assessment',
            subtitle: 'Select an assessment to begin screening',
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
                  title: 'Developmental Screening (TDSC)',
                  subtitle: 'Trivandrum Development Screening Chart',
                  description:
                      'A comprehensive screening tool to assess your child\'s developmental milestones across multiple domains.',
                  tags: const [
                    _Tag('0-6 years', Color(0xFFDBEAFE), Color(0xFF1D4ED8)),
                    _Tag('15-20 min', Color(0xFFCFFAFE), Color(0xFF0E7490)),
                    _Tag('Recommended', Color(0xFFF3E8FF), Color(0xFF7C3AED)),
                  ],
                  onTap: () => Get.toNamed(AppRoutes.tdsc),
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
                  title: 'Language Evaluation (LEST)',
                  subtitle: 'Language Evaluation Scale Trivandrum',
                  description:
                      'Assess your child\'s language and communication skills in both receptive and expressive domains.',
                  tags: const [
                    _Tag('0-6 years', Color(0xFFD1FAE5), Color(0xFF15803D)),
                    _Tag('10-15 min', Color(0xFFA7F3D0), Color(0xFF047857)),
                  ],
                  onTap: () => Get.toNamed(AppRoutes.lest),
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
                  title: 'Parental Stress Assessment',
                  subtitle: 'Parenting Stress Index - Short Form (PSI-SF)',
                  description:
                      'A self-assessment to help identify sources of stress in your parenting journey and get appropriate support.',
                  tags: const [
                    _Tag('Parents', Color(0xFFF3E8FF), Color(0xFF7C3AED)),
                    _Tag('10 min', Color(0xFFFCE7F3), Color(0xFFBE185D)),
                    _Tag('Self-care', Color(0xFFFEE2E2), Color(0xFFDC2626)),
                  ],
                  onTap: () => Get.toNamed(AppRoutes.stress),
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
                  title: 'Risk Factor Checklist',
                  subtitle: 'Identify potential developmental risk factors',
                  description:
                      'Optional screening to identify risk factors that may affect your child\'s development and well-being.',
                  tags: const [
                    _Tag('All ages', Color(0xFFFFEDD5), Color(0xFFEA580C)),
                    _Tag('5-10 min', Color(0xFFFEF3C7), Color(0xFFD97706)),
                    _Tag('Optional', Color(0xFFF1F5F9), Color(0xFF475569)),
                  ],
                  onTap: () => Get.toNamed(AppRoutes.risk),
                  hoverBorder: AppColors.orange600,
                ),
                SizedBox(height: AppSpacing.xl.h),

                // Info box
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
                          Text(
                            'About These Assessments',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'These assessments are screening tools designed to help identify areas where your child may need additional support. They are not diagnostic tests and should be discussed with healthcare professionals.',
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
                          '💡 Tip: Complete assessments in a quiet environment when your child is calm and comfortable for the most accurate results.',
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
                  'All assessments are confidential and secure',
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
            // Top colored bar
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
