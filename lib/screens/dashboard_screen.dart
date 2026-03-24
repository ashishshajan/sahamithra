import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/app_provider.dart';
import '../providers/language_provider.dart';
import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../widgets/language_switcher.dart';
import '../widgets/logo_widget.dart';
import '../widgets/standard_footer.dart';
import '../routes/app_routes.dart';

/// Mirrors /components/DashboardScreen.tsx
///
/// - Purple-pink-blue gradient header with logo + profile dropdown
/// - Progress card (gradient)
/// - Gamification teaser (light gradient)
/// - Weekly schedule card (amber)
/// - Assessments list
/// - Services list
/// - Fixed bottom nav
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showProfileMenu = false;
  int _navIndex = 0;
  Map<String, dynamic>? _userData;

  void _handleLogout() {
    _doLogout();
  }

  Future<void> _doLogout() async {
    try {
      final result = await NetworkHelper().logout();

      // Regardless of server response, clear local session and go to login.
      await GlobalUtils().logout();
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.login);
    } catch (_) {
      await GlobalUtils().logout();
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _userData = args;
  }

  void _navigate(String route) => Get.toNamed(route);

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.to;
    final app = AppProvider.to;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: Stack(
        children: [
          // ─── Main Content ──────────────────────────────────────────────
          Column(
            children: [
              // Gradient Header
              _buildHeader(lang, app),

              // Scrollable content
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    12.w,
                    12.h,
                    12.w,
                    AppSpacing.xl2.h,
                  ),
                  children: [
                    // Progress card
                    _buildProgressCard(lang, app),
                    SizedBox(height: 12.h),

                    // Gamification teaser
                    _buildGamificationCard(lang, app),
                    SizedBox(height: 12.h),

                    // Weekly schedule
                    _buildWeeklyScheduleCard(lang, app),
                    SizedBox(height: AppSpacing.xl.h),

                    // Assessments section
                    _buildSectionLabel(lang.t('assessments')),
                    SizedBox(height: AppSpacing.base.h),
                    _buildAssessmentsList(lang),
                    SizedBox(height: AppSpacing.xl.h),

                    // Services section
                    _buildSectionLabel(lang.t('services')),
                    SizedBox(height: AppSpacing.base.h),
                    _buildServicesList(lang),
                  ],
                ),
              ),

              // Bottom nav
              DashboardNavBar(
                currentIndex: _navIndex,
                onTap: (i) => setState(() => _navIndex = i),
              ),
            ],
          ),

          // ─── Global Overlays ───────────────────────────────────────────
          if (_showProfileMenu) ...[
            // Full-screen dismiss layer
            GestureDetector(
              onTap: () => setState(() => _showProfileMenu = false),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.05),
              ),
            ),

            // Profile dropdown positioned relative to top-right
            Positioned(
              right: 16.w,
              top: MediaQuery.of(context).padding.top + 56.h,
              child: _ProfileDropdown(
                onDismiss: () => setState(() => _showProfileMenu = false),
                onLogout: () {
                  setState(() => _showProfileMenu = false);
                  _handleLogout();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(LanguageProvider lang, AppProvider app) {
    return Obx(() {
      return Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const LogoWidget(
                      size: LogoSize.medium,
                      showText: true,
                      withBackground: true,
                    ),
                    const Spacer(),
                    const LanguageSwitcher(),
                    SizedBox(width: 8.w),

                    // Profile button
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showProfileMenu = !_showProfileMenu),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.white20,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Icon(
                          Icons.account_circle_rounded,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  '${lang.t("welcome")} ${_userData?["parentName"] ?? "Parent"}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  lang.t('trackProgress'),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProgressCard(LanguageProvider lang, AppProvider app) {
    return Obx(() {
      final progress = app.progressData.value;
      return GestureDetector(
        onTap: () => _navigate(AppRoutes.progressTracking),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.xl.r),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.xl2),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('overallProgress'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${progress.overall}%',
                      style: TextStyle(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: progress.overall / 100,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor:
                            const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 10.h,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '+12% ${lang.t("fromLastMonth")}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Icon(
                Icons.trending_up_rounded,
                size: 56.sp,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildGamificationCard(LanguageProvider lang, AppProvider app) {
    return Obx(() {
      final progress = app.progressData.value;
      return GestureDetector(
        onTap: () => _navigate(AppRoutes.gamification),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          decoration: BoxDecoration(
            gradient: AppColors.gamificationGradient,
            borderRadius: BorderRadius.circular(AppRadius.xl2),
            border: Border.all(
              color: AppColors.purple.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.purple100,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 32.sp,
                  color: AppColors.purple,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('achievementsUnlocked'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${progress.streak}-${lang.t("dayStreak")} • ${progress.points} ${lang.t("points")}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text('🏆', style: TextStyle(fontSize: 28.sp)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildWeeklyScheduleCard(LanguageProvider lang, AppProvider app) {
    return Obx(() {
      final completed = app.completedCount;
      final total = app.totalCount;
      return GestureDetector(
        onTap: () => _navigate(AppRoutes.weeklySchedule),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          decoration: BoxDecoration(
            gradient: AppColors.amberGradient,
            borderRadius: BorderRadius.circular(AppRadius.xl2),
            border: Border.all(color: const Color(0xFFFCD34D), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE68A),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 32.sp,
                  color: AppColors.amber600,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('thisWeeksTherapy'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$completed/$total ${lang.t("activitiesCompleted")}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.amber600,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  lang.t('viewDetails'),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiary,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildAssessmentsList(LanguageProvider lang) {
    return Obx(() => Column(
          children: [
            _ServiceCard(
              icon: Icons.assignment_turned_in_rounded,
              iconBg: AppColors.blue100,
              iconColor: AppColors.blue600,
              title: lang.t('developmentalScreening'),
              subtitle: lang.t('tdscRange'),
              onTap: () => _navigate(AppRoutes.tdsc),
            ),
            SizedBox(height: 12.h),
            _ServiceCard(
              icon: Icons.favorite_rounded,
              iconBg: AppColors.purple100,
              iconColor: AppColors.purple,
              title: lang.t('parentalStressScale'),
              subtitle: lang.t('selfAssessment'),
              onTap: () => _navigate(AppRoutes.stress),
            ),
            SizedBox(height: 12.h),
            _ServiceCard(
              icon: Icons.warning_amber_rounded,
              iconBg: AppColors.orange100,
              iconColor: AppColors.orange600,
              title: lang.t('riskFactorChecklist'),
              subtitle: lang.t('optionalAssessment'),
              onTap: () => _navigate(AppRoutes.risk),
            ),
          ],
        ));
  }

  Widget _buildServicesList(LanguageProvider lang) {
    return Obx(() => Column(
          children: [
            _ServiceCard(
              icon: Icons.domain_rounded,
              iconBg: AppColors.cyan100,
              iconColor: AppColors.cyan600,
              title: lang.t('cdmcServices'),
              subtitle: lang.t('integratedCare'),
              onTap: () => _navigate(AppRoutes.cdmcServices),
            ),
            SizedBox(height: 12.h),
            _ServiceCard(
              icon: Icons.location_on_rounded,
              iconBg: AppColors.green100,
              iconColor: AppColors.green600,
              title: lang.t('findTherapyCenters'),
              subtitle: lang.t('gpsEnabled'),
              onTap: () => _navigate(AppRoutes.institutions),
            ),
            SizedBox(height: 12.h),
            _ServiceCard(
              icon: Icons.play_circle_filled_rounded,
              iconBg: AppColors.red100,
              iconColor: AppColors.red600,
              title: lang.t('homeTherapyVideos'),
              subtitle: lang.t('expertGuided'),
              onTap: () => _navigate(AppRoutes.videos),
            ),
            SizedBox(height: 12.h),
            _ServiceCard(
              icon: Icons.description_rounded,
              iconBg: AppColors.orange100,
              iconColor: AppColors.orange600,
              title: lang.t('careTeam'),
              subtitle: lang.t('teamCollaboration'),
              onTap: () => _navigate(AppRoutes.teamCollaboration),
            ),
          ],
        ));
  }
}

// ─── Profile dropdown ──────────────────────────────────────────────────────────

class _ProfileDropdown extends StatelessWidget {
  const _ProfileDropdown({
    required this.onDismiss,
    required this.onLogout,
  });

  final VoidCallback onDismiss;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 20,
      borderRadius: BorderRadius.circular(AppRadius.xl2),
      child: Container(
        width: 200.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DropdownItem(
              icon: Icons.settings_rounded,
              label: 'Profile',
              onTap: () {
                onDismiss();
                Get.toNamed(AppRoutes.account);
              },
            ),
            _DropdownItem(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              onTap: onDismiss,
            ),
            Container(height: 1, color: AppColors.neutral100),
            _DropdownItem(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              color: AppColors.error,
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownItem extends StatelessWidget {
  const _DropdownItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl2),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: c),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Service/Assessment card ───────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Icon(icon, size: 28.sp, color: iconColor),
            ),
            SizedBox(width: AppSpacing.base.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
