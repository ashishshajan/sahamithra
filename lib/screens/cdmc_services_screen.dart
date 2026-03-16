import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/CDMCServicesScreen.tsx
class CDMCServicesScreen extends StatelessWidget {
  const CDMCServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.cyan600,
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
                        Text('CDMC Services',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Text('Integrated Disability Care',
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
              padding: EdgeInsets.all(AppSpacing.base.r),
              children: [
                // Info banner
                Container(
                  padding: EdgeInsets.all(AppSpacing.base.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFCFFAFE), Color(0xFFDBEAFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl2),
                    border: Border.all(color: AppColors.cyan100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.business_rounded,
                          size: 22.sp, color: AppColors.cyan600),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Community Disability Management Centres (CDMC)',
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            SizedBox(height: 4.h),
                            Text(
                                'Integrated services for comprehensive care of differently-abled children in Kozhikode district',
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

                Text('AVAILABLE SERVICES',
                    style: TextStyle(
                      fontSize: 11.sp,
                      letterSpacing: 1.0,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    )),
                SizedBox(height: 10.h),

                // Service cards
                _ServiceCard(
                  icon: Icons.headphones, // TODO: ASHISH
                  iconColor: AppColors.blue600,
                  bgColor: AppColors.blue100,
                  title: 'Medical Assessment & Care',
                  subtitle: 'Comprehensive medical evaluation and ongoing care',
                  items: const [
                    'Developmental screening (TDSC, LEST)',
                    'Medical board certification for disability',
                    'UDID card enrollment',
                    'Pediatric consultation and follow-up',
                  ],
                  bulletColor: AppColors.blue600,
                  btnColor: AppColors.blue600,
                  btnLabel: 'Request Assessment',
                ),
                SizedBox(height: 12.h),
                _ServiceCard(
                  icon: Icons.favorite_rounded,
                  iconColor: AppColors.purple,
                  bgColor: AppColors.purple100,
                  title: 'Therapy Services',
                  subtitle: 'Multi-disciplinary therapy programs',
                  items: const [
                    'Physiotherapy sessions',
                    'Speech and language therapy',
                    'Occupational therapy',
                    'Behavioral therapy',
                  ],
                  bulletColor: AppColors.purple,
                  btnColor: AppColors.purple,
                  btnLabel: 'Book Therapy Session',
                ),
                SizedBox(height: 12.h),
                _ServiceCard(
                  icon: Icons.school_rounded,
                  iconColor: AppColors.green600,
                  bgColor: AppColors.green100,
                  title: 'Educational Support',
                  subtitle: 'Special education and skill development',
                  items: const [
                    'Special education programs',
                    'Pre-academic skill development',
                    'School readiness programs',
                    'Vocational training guidance',
                  ],
                  bulletColor: AppColors.green600,
                  btnColor: AppColors.green600,
                  btnLabel: 'Enroll in Program',
                ),
                SizedBox(height: 12.h),
                _ServiceCard(
                  icon: Icons.groups_rounded,
                  iconColor: AppColors.orange600,
                  bgColor: AppColors.orange100,
                  title: 'Family Support Services',
                  subtitle: 'Counseling and community resources',
                  items: const [
                    'Parental counseling and stress management',
                    'Family training programs',
                    'Parent support groups',
                    'Community resource linkage',
                  ],
                  bulletColor: AppColors.orange600,
                  btnColor: AppColors.orange600,
                  btnLabel: 'Access Support',
                ),
                SizedBox(height: 12.h),
                _ServiceCard(
                  icon: Icons.task_alt_rounded,
                  iconColor: AppColors.pink600,
                  bgColor: AppColors.pink100,
                  title: 'Legal & Administrative',
                  subtitle: 'Documentation and rights awareness',
                  items: const [
                    'RPWD Act information & guidance',
                    'Disability Medical Board assistance',
                    'Niramaya scheme enrollment',
                    'DLSA coordination',
                  ],
                  bulletColor: AppColors.pink600,
                  btnColor: AppColors.pink600,
                  btnLabel: 'Learn More',
                ),
                SizedBox(height: AppSpacing.xl.h),

                // Tertiary centers
                Container(
                  padding: EdgeInsets.all(AppSpacing.base.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.xl2),
                    border: Border.all(
                        color: AppColors.cyan600.withOpacity(0.4), width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tertiary Care Centers',
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 6.h),
                      Text(
                          'For specialized care and complex cases, seamless referral to:',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary)),
                      SizedBox(height: 10.h),
                      ...[
                        'Medical College Hospital, Kozhikode',
                        'Child Development Centre, Thiruvananthapuram',
                        'Regional Cancer Centre (RCC)',
                      ].map((c) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCFFAFE),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.business_rounded,
                                      size: 16.sp, color: AppColors.cyan600),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                      child: Text(c,
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.textPrimary))),
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
    required this.btnColor,
    required this.btnLabel,
  });

  final IconData icon;
  final Color iconColor, bgColor, bulletColor, btnColor;
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
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 42.h,
              decoration: BoxDecoration(
                color: btnColor,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Center(
                child: Text(btnLabel,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
