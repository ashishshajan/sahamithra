import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/language_switcher.dart';
import '../widgets/logo_widget.dart';
import '../routes/app_routes.dart';

/// Mirrors /components/PublicDashboard.tsx
class PublicDashboardScreen extends StatelessWidget {
  const PublicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ─── Gradient Header ─────────────────────────────────────────────
          _buildHeader(),

          // ─── Content ────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.base.w,
                AppSpacing.base.h,
                AppSpacing.base.w,
                AppSpacing.xl.h,
              ),
              children: [
                // General Awareness Videos
                _buildVideosCard(),
                SizedBox(height: AppSpacing.base.h),

                // Take Assessment
                _buildAssessmentCard(),
                SizedBox(height: AppSpacing.base.h),

                // Find Therapy Centers
                _buildInstitutionsCard(),
                SizedBox(height: AppSpacing.base.h),

                // Care Team
                _buildCareTeamCard(),

                SizedBox(height: AppSpacing.xl.h),

                // Footer
                Column(
                  children: [
                    Text(
                      'SAHAMITHRA - Empowering Families, Supporting Children',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Kozhikode District, Kerala',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.white20,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const LogoWidget(
                    size: LogoSize.medium,
                    showText: true,
                    withBackground: true,
                  ),
                  const Spacer(),
                  const LanguageSwitcher(),
                ],
              ),
              SizedBox(height: 12.h),
              Obx(() => Text(
                    'Welcome to ${LanguageProvider.to.t("appName")}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  )),
              SizedBox(height: 2.h),
              Text(
                'Empowering parents, supporting children',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideosCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFEE2E2), Color(0xFFFCE7F3)],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(
                  Icons.play_circle_filled_rounded,
                  size: 24.sp,
                  color: AppColors.red600,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'General Awareness Videos',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Learn about child development and therapy',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          _VideoSubCard(
            title: 'Understanding Developmental Milestones',
            description:
                "Learn what to expect at each age and stage of your child's growth",
            buttonGradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
            ),
            onTap: () => Get.toNamed(AppRoutes.videos),
          ),
          SizedBox(height: 12.h),
          _VideoSubCard(
            title: 'Early Intervention Benefits',
            description:
                'Discover how early therapy can make a lasting difference',
            buttonGradient: const LinearGradient(
              colors: [Color(0xFFF97316), Color(0xFFF59E0B)],
            ),
            onTap: () => Get.toNamed(AppRoutes.videos),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.assessmentMenu),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          border: Border.all(color: AppColors.neutral200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDBEAFE), Color(0xFFF3E8FF)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 24.sp,
                    color: AppColors.blue600,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Take Your Assessment',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "Screen your child's development with TDSC",
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
                  size: 20.sp,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(AppSpacing.base.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFFAF5FF)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.blue100),
              ),
              child: Column(
                children: [
                  _BulletPoint(
                    color: AppColors.blue600,
                    text: 'Developmental screening (TDSC)',
                  ),
                  SizedBox(height: 8.h),
                  _BulletPoint(
                    color: AppColors.blue600,
                    text: 'Language evaluation (LEST)',
                  ),
                  SizedBox(height: 8.h),
                  _BulletPoint(
                    color: AppColors.blue600,
                    text: 'Parental stress assessment',
                  ),
                  SizedBox(height: 8.h),
                  _BulletPoint(
                    color: AppColors.blue600,
                    text: 'Risk factor checklist',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstitutionsCard() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.institutions),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          border: Border.all(color: AppColors.neutral200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD1FAE5), Color(0xFFD1FAE5)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 24.sp,
                    color: AppColors.green600,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Therapy Centers',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Locate nearby centers with GPS',
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
                  size: 20.sp,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(AppSpacing.base.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0FDF4), Color(0xFFF0FDF4)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.green100),
              ),
              child: Column(
                children: [
                  _BulletPoint(
                    color: AppColors.green600,
                    text: 'GPS-enabled location finder',
                  ),
                  SizedBox(height: 8.h),
                  _BulletPoint(
                    color: AppColors.green600,
                    text: 'CDMC and private centers',
                  ),
                  SizedBox(height: 8.h),
                  _BulletPoint(
                    color: AppColors.green600,
                    text: 'Contact details and directions',
                  ),
                  SizedBox(height: 8.h),
                  _BulletPoint(
                    color: AppColors.green600,
                    text: 'Book appointments directly',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareTeamCard() {
    return Obx(
      () => GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.teamCollaboration),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl2),
            border: Border.all(color: AppColors.neutral200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.base.r),
                decoration: BoxDecoration(
                  color: AppColors.orange100,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  size: 28.sp,
                  color: AppColors.orange600,
                ),
              ),
              SizedBox(width: AppSpacing.base.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageProvider.to.t('careTeam'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      LanguageProvider.to.t('teamCollaboration'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────────

class _VideoSubCard extends StatelessWidget {
  const _VideoSubCard({
    required this.title,
    required this.description,
    required this.buttonGradient,
    required this.onTap,
  });

  final String title;
  final String description;
  final LinearGradient buttonGradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (buttonGradient.colors.first).withOpacity(0.08),
            (buttonGradient.colors.last).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: (buttonGradient.colors.first).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                gradient: buttonGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: buttonGradient.colors.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Watch Videos',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.chevron_right_rounded,
                      size: 16.sp, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 3.h),
          child: Text(
            '✓',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
