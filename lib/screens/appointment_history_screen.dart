import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../routes/app_routes.dart';
import '../widgets/language_switcher.dart';
import '../widgets/standard_footer.dart';

/// Appointment history — list of past / scheduled visits (design: gradient header + white list).
class AppointmentHistoryScreen extends StatelessWidget {
  const AppointmentHistoryScreen({super.key});

  static const LinearGradient _headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xff9e1df4),
      Color(0xfff5339b),
      Color(0xff447eff),
    ],
  );

  static final List<_AppointmentEntry> _demoEntries = [
    _AppointmentEntry(
      statusLabel: 'Appointment Cancelled',
      isPositive: false,
      dateTimeLine: '02-04-2026, 4:30 pm',
      doctorLine: 'Dr. Arun Kumar |  Physiotherapist',
      centreLine: 'Samaritan Rehabilitation Centre',
    ),
    _AppointmentEntry(
      statusLabel: 'Appointment Confirmed!',
      isPositive: true,
      dateTimeLine: '02-04-2026, 4:30 pm',
      doctorLine: 'Dr. Sandeep Nair |  Special Educator',
      centreLine: 'CDC Centre',
    ),
    _AppointmentEntry(
      statusLabel: 'Appointment Confirmed!',
      isPositive: true,
      dateTimeLine: '02-04-2026, 4:30 pm',
      doctorLine: 'Dr. Sandeep Nair |  Special Educator',
      centreLine: 'CDC Centre',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 200.h,
            width: double.infinity,
            child: Container(
              decoration: const BoxDecoration(gradient: _headerGradient),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
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
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.schedule_rounded,
                            size: 22.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.w),
                          const LanguageSwitcher(),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Appointment History',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'All your visits at a glance.',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              height: 1.35,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ],
                  ),

                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl.w,
                  20.h,
                  AppSpacing.xl.w,
                  AppSpacing.base.h,
                ),
                children: [


                  SizedBox(height: 20.h),
                  ..._demoEntries.map(
                    (e) => Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: _AppointmentCard(entry: e),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const StandardFooter(),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 56.h),
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.appointments),
          backgroundColor: AppColors.purple,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'Book appointment',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentEntry {
  const _AppointmentEntry({
    required this.statusLabel,
    required this.isPositive,
    required this.dateTimeLine,
    required this.doctorLine,
    required this.centreLine,
  });

  final String statusLabel;
  final bool isPositive;
  final String dateTimeLine;
  final String doctorLine;
  final String centreLine;
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.entry});

  final _AppointmentEntry entry;

  @override
  Widget build(BuildContext context) {
    final accent = entry.isPositive ? AppColors.success : AppColors.error;
    final icon = entry.isPositive ? Icons.check_rounded : Icons.close_rounded;

    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      borderRadius: BorderRadius.circular(AppRadius.xl2),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 41.r,
              height: 41.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.12),
                border: Border.all(color: accent.withOpacity(0.35)),
              ),
              child: Icon(icon, color: accent, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          entry.statusLabel,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12.sp,
                            color: AppColors.textTertiary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            entry.dateTimeLine,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w300,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    entry.doctorLine,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entry.centreLine,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
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
