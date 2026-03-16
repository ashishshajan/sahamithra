import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/app_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/standard_footer.dart';
import '../widgets/standard_header.dart';

/// Mirrors /components/ProgressTrackingScreen.tsx
class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'month';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const StandardHeader(
              showLogo: true,
              title: 'Progress Tracking',
              subtitle: "Track your child's developmental progress",
            ),

            // Period selector
            _buildPeriodSelector(),

            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.purple,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.purple,
                indicatorWeight: 2,
                labelStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Goals'),
                  Tab(text: 'Activities'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildGoalsTab(),
                  _buildActivitiesTab(),
                ],
              ),
            ),

            // Footer with CTA
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      color: Colors.white,
      padding:
          EdgeInsets.symmetric(horizontal: AppSpacing.base.w, vertical: 12.h),
      child: Row(
        children: [
          _PeriodChip(
            label: 'Week',
            active: _selectedPeriod == 'week',
            onTap: () => setState(() => _selectedPeriod = 'week'),
          ),
          SizedBox(width: 8.w),
          _PeriodChip(
            label: 'Month',
            active: _selectedPeriod == 'month',
            onTap: () => setState(() => _selectedPeriod = 'month'),
          ),
          SizedBox(width: 8.w),
          _PeriodChip(
            label: 'All Time',
            active: _selectedPeriod == 'all',
            onTap: () => setState(() => _selectedPeriod = 'all'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Obx(() {
      final p = AppProvider.to.progressData.value;
      return ListView(
        padding: EdgeInsets.all(AppSpacing.base.r),
        children: [
          // Overall progress card
          Container(
            padding: EdgeInsets.all(AppSpacing.xl.r),
            decoration: BoxDecoration(
              gradient: AppColors.indigoGradient,
              borderRadius: BorderRadius.circular(AppRadius.xl2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Progress',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          '${p.overall}%',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 56.r,
                      height: 56.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.trending_up_rounded,
                          size: 32.sp, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: p.overall / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 8.h,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '+12% from last month',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.base.h),

          // Skill areas
          Container(
            padding: EdgeInsets.all(AppSpacing.xl.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skill Areas Progress',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.base.h),
                _SkillBar(
                  label: 'Gross Motor Skills',
                  value: p.grossMotor,
                  color: AppColors.blue600,
                ),
                SizedBox(height: AppSpacing.base.h),
                _SkillBar(
                  label: 'Fine Motor Skills',
                  value: p.fineMotor,
                  color: AppColors.green600,
                ),
                SizedBox(height: AppSpacing.base.h),
                _SkillBar(
                  label: 'Speech & Language',
                  value: p.speech,
                  color: AppColors.purple,
                ),
                SizedBox(height: AppSpacing.base.h),
                _SkillBar(
                  label: 'Cognitive Skills',
                  value: p.cognitive,
                  color: AppColors.orange600,
                ),
                SizedBox(height: AppSpacing.base.h),
                _SkillBar(
                  label: 'Social Skills',
                  value: p.social,
                  color: AppColors.pink600,
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.base.h),

          // Activity stats
          Container(
            padding: EdgeInsets.all(AppSpacing.xl.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity Statistics',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.base.h),
                Obx(() {
                  final app = AppProvider.to;
                  return Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          label: 'Completed',
                          value: '${app.completedCount}',
                          bg: const Color(0xFFEEF2FF),
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _StatBox(
                          label: 'Pending',
                          value: '${app.totalCount - app.completedCount}',
                          bg: const Color(0xFFFFFBEB),
                          color: AppColors.amber600,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildGoalsTab() {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.base.r),
      children: [
        _GoalCard(
          title: 'Stand independently for 10 seconds',
          status: 'Completed',
          statusColor: AppColors.success,
          statusBg: const Color(0xFFD1FAE5),
          targetDate: 'Target: Nov 15, 2025 | Achieved: Nov 12, 2025',
          progress: 1.0,
          progressColor: AppColors.success,
          borderColor: AppColors.success,
        ),
        SizedBox(height: 12.h),
        _GoalCard(
          title: 'Say 10 new words clearly',
          status: 'In Progress',
          statusColor: AppColors.blue600,
          statusBg: AppColors.blue100,
          targetDate: 'Target: Nov 30, 2025 | Progress: 7/10 words',
          progress: 0.70,
          progressColor: AppColors.blue600,
          borderColor: AppColors.blue600,
        ),
        SizedBox(height: 12.h),
        _GoalCard(
          title: 'Stack 5 blocks independently',
          status: 'In Progress',
          statusColor: AppColors.orange600,
          statusBg: AppColors.orange100,
          targetDate: 'Target: Dec 5, 2025 | Progress: 3/5 blocks',
          progress: 0.60,
          progressColor: AppColors.orange600,
          borderColor: AppColors.orange600,
        ),
      ],
    );
  }

  Widget _buildActivitiesTab() {
    return Obx(() {
      final activities = AppProvider.to.therapyActivities
          .where((a) => a.completed)
          .toList();

      return ListView(
        padding: EdgeInsets.all(AppSpacing.base.r),
        children: [
          _ActivityLogCard(
            title: 'Ball Rolling Exercise',
            time: 'Today, 9:30 AM - 15 minutes',
            feedback: '"Great session! Very engaged."',
            stars: 4,
          ),
          SizedBox(height: 12.h),
          _ActivityLogCard(
            title: 'Picture Naming Game',
            time: 'Yesterday, 3:00 PM - 12 minutes',
            feedback: '"Named 8 out of 10 pictures correctly!"',
            stars: 5,
          ),
        ],
      );
    });
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(AppSpacing.base.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: AppColors.neutral200),
          SizedBox(height: AppSpacing.base.h),
          GradientButton(
            onPressed: () {},
            height: 48.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  'Add Feedback',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.base.h),
          const StandardFooter(),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────────

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: active ? AppColors.purplePinkGradient : null,
          color: active ? null : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  const _SkillBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$value%',
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF4F46E5),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8.h,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.bg,
    required this.color,
  });

  final String label;
  final String value;
  final Color bg;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.targetDate,
    required this.progress,
    required this.progressColor,
    required this.borderColor,
  });

  final String title;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final String targetDate;
  final double progress;
  final Color progressColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            targetDate,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation(progressColor),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityLogCard extends StatelessWidget {
  const _ActivityLogCard({
    required this.title,
    required this.time,
    required this.feedback,
    required this.stars,
  });

  final String title;
  final String time;
  final String feedback;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '✓ Completed',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.green600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            time,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Parent feedback: $feedback',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                'Performance: ',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textTertiary,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Text(
                    '★',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: i < stars
                          ? AppColors.yellow400
                          : AppColors.neutral300,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
