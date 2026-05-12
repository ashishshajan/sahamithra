import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/DataPrivacyScreen.tsx
class DataPrivacyScreen extends StatelessWidget {
  const DataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFF334155),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: AppColors.white20,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16.sp, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Data Privacy & Security',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Text('Your information is protected',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                // Security promise banner
                Container(
                  padding: EdgeInsets.all(AppSpacing.xl.r),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60.r,
                        height: 60.r,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.shield_rounded,
                            size: 30.sp, color: Colors.white),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your Data is Secure',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            SizedBox(height: 4.h),
                            Text('Bank-level encryption & compliance',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white.withOpacity(0.9))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(AppSpacing.base.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Security features
                      _SectionCard(
                        emoji: '🔒',
                        title: 'Security Features',
                        child: Column(
                          children: [
                            _FeatureRow(
                              icon: Icons.lock_rounded,
                              iconBg: AppColors.blue100,
                              iconColor: AppColors.blue600,
                              title: 'End-to-End Encryption',
                              subtitle:
                                  'All data encrypted with industry-standard 256-bit AES encryption',
                            ),
                            _FeatureRow(
                              icon: Icons.verified_user_rounded,
                              iconBg: AppColors.green100,
                              iconColor: AppColors.green600,
                              title: 'Secure Authentication',
                              subtitle:
                                  'Aadhaar-based login with OTP verification ensures only authorized access',
                            ),
                            _FeatureRow(
                              icon: Icons.storage_rounded,
                              iconBg: AppColors.purple100,
                              iconColor: AppColors.purple,
                              title: 'Secure Cloud Storage',
                              subtitle:
                                  'Data stored in certified Indian data centers with regular backups',
                            ),
                            _FeatureRow(
                              icon: Icons.visibility_rounded,
                              iconBg: AppColors.orange100,
                              iconColor: AppColors.orange600,
                              title: 'Access Control',
                              subtitle:
                                  'Role-based permissions: only authorized healthcare professionals can view your data',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Compliance
                      _SectionCard(
                        emoji: '✅',
                        title: 'Regulatory Compliance',
                        child: Column(
                          children: [
                            _ComplianceRow('IT Act 2000 Compliant',
                                'Follows Indian information technology regulations'),
                            _ComplianceRow('DISHA Guidelines',
                                'Adheres to Digital Information Security in Healthcare Act'),
                            _ComplianceRow('RPWD Act 2016',
                                'Compliant with Rights of Persons with Disabilities Act',
                                isLast: true),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Data usage
                      _SectionCard(
                        emoji: '📊',
                        title: 'How We Use Your Data',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            'Provide personalized therapy programs for your child',
                            'Track progress and share with your care team',
                            'Coordinate care between healthcare providers',
                            'Generate progress reports and assessments',
                            'Improve app features and user experience',
                          ]
                              .map((t) => Padding(
                                    padding: EdgeInsets.only(bottom: 8.h),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.check_rounded,
                                            size: 16.sp,
                                            color: AppColors.blue600),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                            child: Text(t,
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: AppColors
                                                        .textSecondary,
                                                    height: 1.3))),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // What we never do
                      Container(
                        padding: EdgeInsets.all(AppSpacing.base.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(AppRadius.xl2),
                          border: Border.all(
                              color: const Color(0xFFFECDD3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🚫 We Never:',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF9F1239))),
                            SizedBox(height: 10.h),
                            ...[
                              'Sell your personal or health information',
                              'Share data with third parties without consent',
                              'Use data for marketing purposes',
                              'Store data outside India',
                            ].map((t) => Padding(
                                  padding: EdgeInsets.only(bottom: 6.h),
                                  child: Row(
                                    children: [
                                      Icon(Icons.close_rounded,
                                          size: 16.sp,
                                          color: AppColors.red600),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                          child: Text(t,
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: const Color(
                                                      0xFFBE123C)))),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Your rights
                      _SectionCard(
                        emoji: '👤',
                        title: 'Your Rights',
                        child: Column(
                          children: [
                            _RightRow('Access Your Data',
                                'Request a copy of all your stored information anytime'),
                            _RightRow('Update Information',
                                'Modify or correct your personal and health data'),
                            _RightRow('Data Portability',
                                'Export your data in a standard format'),
                            _RightRow('Delete Your Account',
                                'Request complete removal of your data from our systems',
                                isLast: true),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Contact
                      Container(
                        padding: EdgeInsets.all(AppSpacing.base.r),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEEF2FF), Color(0xFFDBEAFE)],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.xl2),
                          border: Border.all(
                              color: const Color(0xFFC7D2FE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📧 Privacy Concerns?',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            SizedBox(height: 8.h),
                            Text(
                                'Contact our Data Protection Officer:',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary)),
                            SizedBox(height: 10.h),
                            Text('Email: privacy@sahamithra.in',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textPrimary)),
                            SizedBox(height: 3.h),
                            Text('Phone: +91-XXXX-XXXXXX',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textPrimary)),
                            SizedBox(height: 3.h),
                            Text('Office: NHM Kozhikode, Kerala',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      Center(
                        child: Column(
                          children: [
                            Text('Last updated: November 19, 2025',
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textTertiary)),
                            Text('Version 1.0',
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.base.h),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer action
          Container(
            padding: EdgeInsets.all(AppSpacing.base.r),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.neutral200)),
            ),
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 52.h),
                backgroundColor: const Color(0xFF334155),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl)),
              ),
              child: Text('I Understand',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
          const StandardFooter(),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.emoji, required this.title, required this.child});
  final String emoji, title;
  final Widget child;

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
          Text('$emoji $title',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
              child: Icon(icon, size: 20.sp, color: iconColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  SizedBox(height: 2.h),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                          height: 1.3)),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          SizedBox(height: 12.h),
          Divider(color: AppColors.neutral200),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

class _ComplianceRow extends StatelessWidget {
  const _ComplianceRow(this.title, this.subtitle, {this.isLast = false});
  final String title, subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.task_alt_rounded,
                size: 16.sp, color: AppColors.green600),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 13.sp,
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
        if (!isLast) ...[
          SizedBox(height: 10.h),
          Divider(color: AppColors.neutral200),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }
}

class _RightRow extends StatelessWidget {
  const _RightRow(this.title, this.subtitle, {this.isLast = false});
  final String title, subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        SizedBox(height: 2.h),
        Text(subtitle,
            style: TextStyle(
                fontSize: 11.sp, color: AppColors.textSecondary)),
        if (!isLast) ...[
          SizedBox(height: 10.h),
          Divider(color: AppColors.neutral200),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }
}
