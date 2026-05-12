import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/standard_footer.dart';
import '../routes/app_routes.dart';

/// Mirrors /components/TherapistDashboard.tsx
class TherapistDashboardScreen extends StatelessWidget {
  const TherapistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0891B2), Color(0xFF2563EB)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            width: 36.r,
                            height: 36.r,
                            decoration: BoxDecoration(
                              color: AppColors.white20,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xl),
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 16.sp, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Therapist Portal',
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              Text('Dr. Sarah Thompson — Physiotherapy',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color:
                                          Colors.white.withOpacity(0.9))),
                            ],
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              width: 36.r,
                              height: 36.r,
                              decoration: BoxDecoration(
                                color: AppColors.white20,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.notifications_rounded,
                                  size: 18.sp, color: Colors.white),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                width: 8.r,
                                height: 8.r,
                                decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: AppColors.white20,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.settings_rounded,
                              size: 18.sp, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Quick stats
                    Row(
                      children: [
                        _Stat('24', 'Active Patients'),
                        SizedBox(width: 12.w),
                        _Stat('8', "Today's Sessions"),
                        SizedBox(width: 12.w),
                        _Stat('12', 'Pending Reviews'),
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
                // Quick actions
                _SectionTitle('Quick Actions'),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.5,
                  children: [
                    _ActionCard(Icons.group_rounded, 'My Participants',
                        AppColors.cyan600, () {}),
                    _ActionCard(Icons.description_rounded, 'Create Program',
                        AppColors.cyan600, () {}),
                    _ActionCard(Icons.medical_services_rounded,
                        'Activity Library', AppColors.cyan600,
                        () => Get.toNamed(AppRoutes.activityLibrary)),
                    _ActionCard(Icons.calendar_month_rounded, 'Appointments',
                        AppColors.cyan600,
                        () => Get.toNamed(AppRoutes.appointments)),
                  ],
                ),
                SizedBox(height: 20.h),

                // Today's schedule
                _SectionTitle("Today's Schedule"),
                _SessionCard('Aarav Kumar', '9:00 AM – 10:00 AM',
                    'Physiotherapy', 'Session 8/12 — Standing exercises',
                    const Color(0xFF3B82F6)),
                SizedBox(height: 10.h),
                _SessionCard('Priya Menon', '10:30 AM – 11:30 AM',
                    'Speech Therapy', 'Session 5/10 — Language development',
                    AppColors.purple),
                SizedBox(height: 10.h),
                _SessionCard('Ravi Sharma', '2:00 PM – 3:00 PM',
                    'Occupational', 'Session 3/8 — Fine motor skills',
                    AppColors.green600),
                SizedBox(height: 20.h),

                // Features
                _SectionTitle('Features'),
                _FeatureRow(
                  icon: Icons.trending_up_rounded,
                  iconBg: const Color(0xFFEEF2FF),
                  iconColor: const Color(0xFF4F46E5),
                  title: 'Progress Monitoring',
                  subtitle: 'Track participant improvements',
                  onTap: () => Get.toNamed(AppRoutes.progressTracking),
                ),
                SizedBox(height: 10.h),
                _FeatureRow(
                  icon: Icons.chat_bubble_rounded,
                  iconBg: AppColors.orange100,
                  iconColor: AppColors.orange600,
                  title: 'Team Collaboration',
                  subtitle: 'Coordinate with care team',
                  onTap: () =>
                      Get.toNamed(AppRoutes.teamCollaboration),
                ),
                SizedBox(height: 10.h),
                _FeatureRow(
                  icon: Icons.video_library_rounded,
                  iconBg: AppColors.pink100,
                  iconColor: AppColors.pink600,
                  title: 'Custom Content',
                  subtitle: 'Create & share therapy videos',
                  onTap: () => Get.toNamed(AppRoutes.videos),
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

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value, label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppRadius.xl2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            SizedBox(height: 2.h),
            Text(label,
                style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.9))),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          letterSpacing: 1.0,
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard(this.icon, this.label, this.color, this.onTap);
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28.sp, color: color),
            SizedBox(height: 8.h),
            Text(label,
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard(this.name, this.time, this.type, this.note, this.color);
  final String name, time, type, note;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                SizedBox(height: 3.h),
                Text(time,
                    style: TextStyle(
                        fontSize: 12.sp, color: AppColors.textSecondary)),
                SizedBox(height: 3.h),
                Text(note,
                    style: TextStyle(
                        fontSize: 11.sp, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(type,
                style: TextStyle(
                    fontSize: 11.sp,
                    color: color,
                    fontWeight: FontWeight.w500)),
          ),
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
    required this.onTap,
  });
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: iconBg,
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
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20.sp, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
