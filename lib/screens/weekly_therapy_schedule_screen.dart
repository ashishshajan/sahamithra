import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/WeeklyTherapySchedule.tsx
class WeeklyTherapyScheduleScreen extends StatefulWidget {
  const WeeklyTherapyScheduleScreen({super.key});

  @override
  State<WeeklyTherapyScheduleScreen> createState() =>
      _WeeklyTherapyScheduleScreenState();
}

class _WeeklyTherapyScheduleScreenState
    extends State<WeeklyTherapyScheduleScreen> {
  int _selectedDay = 2; // Wednesday index

  static const List<String> _dayAbbr = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  final List<List<_Activity>> _activitiesByDay = [
    [], // Mon
    [], // Tue
    [   // Wed
      _Activity('Ball Rolling Exercise', 'Gross Motor', 15, false,
          'Focus on smooth, coordinated rolling'),
      _Activity('Picture Naming Game', 'Speech', 10, true,
          'Vocabulary cards session completed'),
      _Activity('Building Block Stacking', 'Fine Motor', 20, false,
          'Encourage pincer grasp practice'),
    ],
    [], // Thu
    [   // Fri
      _Activity('Tummy Time', 'Gross Motor', 10, false, null),
    ],
    [], // Sat
    [], // Sun
  ];

  @override
  Widget build(BuildContext context) {
    final activities = _activitiesByDay[_selectedDay];
    final completed = activities.where((a) => a.completed).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFF4338CA),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
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
                              borderRadius: BorderRadius.circular(AppRadius.xl),
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
                              Text('Therapy Schedule',
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              Text('Week of Feb 1–7, 2026',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color:
                                          Colors.white.withOpacity(0.9))),
                            ],
                          ),
                        ),
                        Icon(Icons.notifications_rounded,
                            size: 22.sp, color: Colors.white),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Day selector
                    SizedBox(
                      height: 72.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (_, __) => SizedBox(width: 8.w),
                        itemCount: _dayAbbr.length,
                        itemBuilder: (_, i) {
                          final dayActs = _activitiesByDay[i];
                          final dayComp =
                              dayActs.where((a) => a.completed).length;
                          final selected = i == _selectedDay;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedDay = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 52.w,
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xl),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _dayAbbr[i],
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: selected
                                          ? const Color(0xFF4338CA)
                                          : Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? const Color(0xFF4338CA)
                                          : Colors.white,
                                    ),
                                  ),
                                  if (dayActs.isNotEmpty)
                                    Text(
                                      '$dayComp/${dayActs.length}',
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        color: selected
                                            ? const Color(0xFF4338CA)
                                            : Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
                // Daily summary
                Container(
                  padding: EdgeInsets.all(AppSpacing.base.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl2),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Today's Goals",
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          SizedBox(height: 4.h),
                          Text(
                              'Focus: Gross motor, Speech, Cognitive',
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4338CA),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text('$completed/${activities.length}',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                Text('SCHEDULED ACTIVITIES',
                    style: TextStyle(
                      fontSize: 11.sp,
                      letterSpacing: 1.0,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    )),
                SizedBox(height: 10.h),

                if (activities.isEmpty)
                  Container(
                    padding: EdgeInsets.all(AppSpacing.xl2.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.xl2),
                    ),
                    child: Column(
                      children: [
                        Text('🌟',
                            style: TextStyle(fontSize: 40.sp)),
                        SizedBox(height: 12.h),
                        Text('No activities scheduled',
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary)),
                        SizedBox(height: 4.h),
                        Text('Rest day — enjoy quality time together!',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textTertiary)),
                      ],
                    ),
                  )
                else
                  ...activities.map((act) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _ActivityCard(
                          activity: act,
                          onComplete: () => setState(() {
                            final idx = activities.indexOf(act);
                            activities[idx] =
                                act.copyWith(completed: true);
                          }),
                        ),
                      )),
              ],
            ),
          ),
          const StandardFooter(),
        ],
      ),
    );
  }
}

class _Activity {
  final String title;
  final String type;
  final int durationMin;
  final bool completed;
  final String? notes;

  const _Activity(
      this.title, this.type, this.durationMin, this.completed, this.notes);

  _Activity copyWith({bool? completed}) => _Activity(
      title, type, durationMin, completed ?? this.completed, notes);
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.onComplete});

  final _Activity activity;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        color: activity.completed
            ? const Color(0xFFF0FDF4)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(
          color: activity.completed
              ? AppColors.success.withOpacity(0.3)
              : AppColors.neutral200,
          width: activity.completed ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: activity.completed ? AppColors.success : AppColors.neutral200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              activity.completed ? Icons.check_rounded : Icons.play_arrow_rounded,
              size: 24.sp,
              color: activity.completed ? Colors.white : AppColors.textTertiary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: activity.completed
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                    decoration: activity.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(activity.type,
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF4338CA))),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.access_time_rounded,
                        size: 12.sp, color: AppColors.textTertiary),
                    SizedBox(width: 3.w),
                    Text('${activity.durationMin} min',
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textTertiary)),
                  ],
                ),
                if (activity.notes != null) ...[
                  SizedBox(height: 6.h),
                  Text(activity.notes!,
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary)),
                ],
                if (!activity.completed) ...[
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: onComplete,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Text('Mark as Complete',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
