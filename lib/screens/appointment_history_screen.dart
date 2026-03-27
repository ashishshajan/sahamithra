import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../routes/app_routes.dart';
import '../widgets/language_switcher.dart';
import '../widgets/standard_footer.dart';

/// Appointment history — list of past / scheduled visits (design: gradient header + white list).
class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  bool _isLoading = true;
  String? _error;
  List<_AppointmentEntry> _entries = const [];
  final Set<int> _cancellingIds = <int>{};
  int _total = 0;
  int _currentPage = 1;
  int _lastPage = 1;

  static const LinearGradient _headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xff9e1df4),
      Color(0xfff5339b),
      Color(0xff447eff),
    ],
  );

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final childId = GlobalUtils().childId;
    if (childId == null) {
      setState(() {
        _isLoading = false;
        _error = 'Child not selected';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await NetworkHelper().getAppointments(
      childId: childId,
      page: 1,
    );
    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _isLoading = false;
        _error = result['message']?.toString() ?? 'Failed to load appointments';
      });
      return;
    }

    final data = result['data'];
    final appointmentsRaw = data is Map ? data['appointments'] : null;
    final paginationRaw = data is Map ? data['pagination'] : null;

    final appointments = (appointmentsRaw is List)
        ? appointmentsRaw.whereType<Map>().map((a) => _AppointmentEntry.fromApi(a)).toList()
        : <_AppointmentEntry>[];

    int currentPage = 1;
    int lastPage = 1;
    int total = appointments.length;
    if (paginationRaw is Map) {
      final cp = paginationRaw['current_page'];
      final lp = paginationRaw['last_page'];
      final t = paginationRaw['total'];
      currentPage = cp is int ? cp : int.tryParse(cp?.toString() ?? '') ?? 1;
      lastPage = lp is int ? lp : int.tryParse(lp?.toString() ?? '') ?? 1;
      total = t is int ? t : int.tryParse(t?.toString() ?? '') ?? total;
    }

    setState(() {
      _entries = appointments;
      _currentPage = currentPage;
      _lastPage = lastPage;
      _total = total;
      _isLoading = false;
    });
  }

  Future<void> _cancelAppointment(int appointmentId) async {
    final childId = GlobalUtils().childId;
    if (childId == null) {
      Get.snackbar(
        'Cancel appointment',
        'Child not selected.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _cancellingIds.add(appointmentId));
    final result = await NetworkHelper().cancelAppointment(
      appointmentId: appointmentId,
      childId: childId,
    );
    if (!mounted) return;
    setState(() => _cancellingIds.remove(appointmentId));

    if (result['success'] == true) {
      Get.snackbar(
        'Success',
        result['message']?.toString() ?? 'Appointment cancelled successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
      await _loadAppointments();
      return;
    }

    Get.snackbar(
      'Cancel appointment',
      result['message']?.toString() ?? 'Unable to cancel appointment.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

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
              child: _buildContent(),
            ),
          ),
          const StandardFooter(),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 56.h),
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.institutions),
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              OutlinedButton(
                onPressed: _loadAppointments,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Text(
          'No appointments found',
          style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        20.h,
        AppSpacing.xl.w,
        AppSpacing.base.h,
      ),
      children: [
        Text(
          '$_total appointment${_total == 1 ? '' : 's'} • Page $_currentPage/$_lastPage',
          style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary),
        ),
        SizedBox(height: 12.h),
        ..._entries.map(
          (e) => Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: _AppointmentCard(
              entry: e,
              isCancelling: _cancellingIds.contains(e.id),
              onCancel: e.canCancel ? () => _cancelAppointment(e.id) : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _AppointmentEntry {
  const _AppointmentEntry({
    required this.id,
    required this.statusCode,
    required this.statusLabel,
    required this.dateTimeLine,
    required this.doctorLine,
    required this.centreLine,
    required this.canCancel,
  });

  final int id;
  /// Server `appointment_status` numeric codes:
  /// 0 pending, 1 approved, 2 completed, 3 rejected, 4 cancelled,
  /// 5 no_show, 6 cancelled_by_parent
  final int statusCode;
  final String statusLabel;
  final String dateTimeLine;
  final String doctorLine;
  final String centreLine;
  final bool canCancel;

  factory _AppointmentEntry.fromApi(Map<dynamic, dynamic> raw) {
    final idRaw = raw['id'];
    final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '') ?? 0;
    final appointmentStatus = raw['appointment_status'];
    final statusInt = appointmentStatus is int
        ? appointmentStatus
        : int.tryParse(appointmentStatus?.toString() ?? '') ?? -1;

    String statusLabel;
    switch (statusInt) {
      case 0:
        statusLabel = 'Pending';
        break;
      case 1:
        statusLabel = 'Approved';
        break;
      case 2:
        statusLabel = 'Completed';
        break;
      case 3:
        statusLabel = 'Rejected';
        break;
      case 4:
        statusLabel = 'Cancelled';
        break;
      case 5:
        statusLabel = 'No show';
        break;
      case 6:
        statusLabel = 'Cancelled by parent';
        break;
      default:
        statusLabel = 'Unknown status';
        break;
    }

    final dateTimeLine = _formatDateTime(
      raw['date']?.toString(),
      raw['time']?.toString(),
    );

    final therapist = raw['therapist'];
    final speciality = raw['speciality'];
    final centre = raw['therapy_centre'];

    final therapistName = therapist is Map && therapist['full_name'] != null
        ? therapist['full_name'].toString()
        : 'Therapist not assigned';
    final specialityName = speciality is Map && speciality['name'] != null
        ? speciality['name'].toString()
        : 'Speciality not available';
    final centreName = centre is Map && centre['name'] != null
        ? centre['name'].toString()
        : 'Therapy centre not available';

    return _AppointmentEntry(
      id: id,
      statusCode: statusInt,
      statusLabel: statusLabel,
      dateTimeLine: dateTimeLine,
      doctorLine: '$therapistName |  $specialityName',
      centreLine: centreName,
      canCancel: statusInt == 0,
    );
  }

  static String _formatDateTime(String? isoDate, String? time) {
    DateTime? parsedDate;
    if (isoDate != null && isoDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(isoDate);
    }
    final dateText = parsedDate != null
        ? DateFormat('dd-MM-yyyy').format(parsedDate.toLocal())
        : '--';

    String timeText = '--';
    if (time != null && time.isNotEmpty) {
      try {
        final dt = DateFormat('HH:mm:ss').parse(time);
        timeText = DateFormat('h:mm a').format(dt).toLowerCase();
      } catch (_) {
        timeText = time;
      }
    }

    return '$dateText, $timeText';
  }
}

(Color accent, IconData icon) _appointmentStatusVisual(int code) {
  switch (code) {
    case 0:
      return (AppColors.warning, Icons.schedule_rounded);
    case 1:
      return (AppColors.success, Icons.check_circle_rounded);
    case 2:
      return (AppColors.success, Icons.task_alt_rounded);
    case 3:
      return (AppColors.error, Icons.cancel_rounded);
    case 4:
      return (AppColors.textTertiary, Icons.event_busy_rounded);
    case 5:
      return (AppColors.orange600, Icons.person_off_rounded);
    case 6:
      return (AppColors.error, Icons.cancel_schedule_send_rounded);
    default:
      return (AppColors.textTertiary, Icons.help_outline_rounded);
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.entry,
    this.onCancel,
    this.isCancelling = false,
  });

  final _AppointmentEntry entry;
  final VoidCallback? onCancel;
  final bool isCancelling;

  @override
  Widget build(BuildContext context) {
    final visual = _appointmentStatusVisual(entry.statusCode);
    final accent = visual.$1;
    final icon = visual.$2;

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
                  if (entry.canCancel) ...[
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: isCancelling ? null : onCancel,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.35),
                            ),
                          ),
                          child: isCancelling
                              ? SizedBox(
                                  width: 10.r,
                                  height: 10.r,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.8,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.error,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Cancel Appointment',
                                  style: TextStyle(
                                    fontSize: 7.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error,
                                  ),
                                ),
                          ),
                        ),
                      ),

                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
