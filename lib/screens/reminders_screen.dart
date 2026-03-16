import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/RemindersScreen.tsx
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<_Reminder> _reminders = [
    _Reminder('1', 'therapy', 'Morning Therapy Session',
        'Ball rolling + tummy time exercises', '8:00 AM', '2026-02-22', false),
    _Reminder('2', 'appointment', 'Speech Therapy Appointment',
        'Dr. Priya Menon at CDMC', '10:30 AM', '2026-02-24', false),
    _Reminder('3', 'assessment', 'Monthly Assessment Due',
        'TDSC reassessment for this month', '9:00 AM', '2026-02-28', false),
    _Reminder('4', 'medication', 'Vitamin D Supplement',
        'Daily dose after breakfast', '8:30 AM', '2026-02-22', true),
  ];

  void _complete(String id) {
    setState(() {
      final idx = _reminders.indexWhere((r) => r.id == id);
      if (idx != -1) {
        _reminders[idx] = _reminders[idx].copyWith(completed: true);
      }
    });
    Get.snackbar('Done', 'Reminder marked as complete',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white);
  }

  void _delete(String id) {
    setState(() => _reminders.removeWhere((r) => r.id == id));
    Get.snackbar('Deleted', 'Reminder removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final active = _reminders.where((r) => !r.completed).toList();
    final done = _reminders.where((r) => r.completed).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.amber600,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reminders & Notifications',
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          Text('Stay on track with therapy',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.snackbar(
                        'Coming Soon',
                        'Add reminder feature will be available soon',
                        snackPosition: SnackPosition.BOTTOM,
                      ),
                      child: Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: AppColors.white20,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Icon(Icons.add_rounded,
                            size: 20.sp, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stats strip
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                _Stat('${active.length}', 'Active', AppColors.amber600),
                _Divider(),
                _Stat('${done.length}', 'Completed', AppColors.success),
                _Divider(),
                const _Stat('85%', 'On Time', AppColors.blue600),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.neutral200),

          Expanded(
            child: _reminders.isEmpty
                ? Center(
                    child: Text('No reminders yet',
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textTertiary)))
                : ListView(
                    padding: EdgeInsets.all(AppSpacing.base.r),
                    children: [
                      if (active.isNotEmpty) ...[
                        Text('ACTIVE REMINDERS',
                            style: TextStyle(
                              fontSize: 11.sp,
                              letterSpacing: 1.0,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                            )),
                        SizedBox(height: 10.h),
                        ...active.map((r) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _ReminderCard(
                                reminder: r,
                                onComplete: () => _complete(r.id),
                                onDelete: () => _delete(r.id),
                              ),
                            )),
                      ],
                      if (done.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Text('COMPLETED',
                            style: TextStyle(
                              fontSize: 11.sp,
                              letterSpacing: 1.0,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                            )),
                        SizedBox(height: 10.h),
                        ...done.map((r) => Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: Opacity(
                                opacity: 0.6,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral100,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.xl2),
                                    border: Border.all(
                                        color: AppColors.neutral200,
                                        width: 2),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(r.title,
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color:
                                                        AppColors.textTertiary,
                                                    decoration:
                                                        TextDecoration
                                                            .lineThrough)),
                                            Text(r.time,
                                                style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color:
                                                        AppColors.textTertiary)),
                                          ],
                                        ),
                                      ),
                                      Text('✓',
                                          style: TextStyle(
                                              fontSize: 20.sp,
                                              color: AppColors.success)),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ],
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

class _Reminder {
  final String id, type, title, description, time, date;
  final bool completed;
  const _Reminder(this.id, this.type, this.title, this.description, this.time,
      this.date, this.completed);

  _Reminder copyWith({bool? completed}) => _Reminder(
      id, type, title, description, time, date, completed ?? this.completed);
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard(
      {required this.reminder,
      required this.onComplete,
      required this.onDelete});
  final _Reminder reminder;
  final VoidCallback onComplete, onDelete;

  Color get _borderColor {
    switch (reminder.type) {
      case 'therapy':
        return AppColors.blue600.withOpacity(0.3);
      case 'appointment':
        return AppColors.green600.withOpacity(0.3);
      case 'assessment':
        return AppColors.purple.withOpacity(0.3);
      default:
        return AppColors.orange600.withOpacity(0.3);
    }
  }

  Color get _iconBg {
    switch (reminder.type) {
      case 'therapy':
        return AppColors.blue100;
      case 'appointment':
        return AppColors.green100;
      case 'assessment':
        return AppColors.purple100;
      default:
        return AppColors.orange100;
    }
  }

  Color get _iconColor {
    switch (reminder.type) {
      case 'therapy':
        return AppColors.blue600;
      case 'appointment':
        return AppColors.green600;
      case 'assessment':
        return AppColors.purple;
      default:
        return AppColors.orange600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: _borderColor, width: 2),
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
            width: 42.r,
            height: 42.r,
            decoration:
                BoxDecoration(color: _iconBg, shape: BoxShape.circle),
            child: Icon(Icons.notifications_rounded,
                size: 20.sp, color: _iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(reminder.title,
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    ),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(Icons.delete_outline_rounded,
                          size: 18.sp, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(reminder.description,
                    style: TextStyle(
                        fontSize: 11.sp, color: AppColors.textSecondary)),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 12.sp, color: AppColors.textTertiary),
                    SizedBox(width: 4.w),
                    Text(reminder.time,
                        style: TextStyle(
                            fontSize: 11.sp, color: AppColors.textTertiary)),
                    SizedBox(width: 12.w),
                    Icon(Icons.event_rounded,
                        size: 12.sp, color: AppColors.textTertiary),
                    SizedBox(width: 4.w),
                    Text(reminder.date,
                        style: TextStyle(
                            fontSize: 11.sp, color: AppColors.textTertiary)),
                  ],
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: onComplete,
                  child: Container(
                    height: 34.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Center(
                      child: Text('Mark as Complete',
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.color);
  final String value, label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 11.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 36.h, color: AppColors.neutral200);
  }
}
