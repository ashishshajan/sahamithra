import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/language_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_header.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/AppointmentBookingScreen.tsx
class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  Map<String, dynamic>? _institution;
  /// Therapist picker is hidden in UI; API still requires `therapist_id`.
  static const int _dummyTherapistIdForApi = 1;
  // String? _selectedTherapist;
  String? _selectedTime;
  String? _selectedReasonForVisit;
  bool _isBooking = false;

  // Selected date state using a simple DateTime
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  static const List<String> _reasonForVisitKeys = [
    'appointmentReasonInitial',
    'appointmentReasonSpeech',
    'appointmentReasonOccupational',
    'appointmentReasonDevelopmental',
    'appointmentReasonFollowUp',
    'appointmentReasonGeneral',
  ];

  static const List<String> _slots = [
    '9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '2:00 PM', '2:30 PM', '3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    _institution = Get.arguments as Map<String, dynamic>?;
  }

  bool get _canBook =>
      _selectedTime != null && _selectedReasonForVisit != null;

  Future<void> _book() async {
    final lang = LanguageProvider.to;

    if (!_canBook) {
      Get.snackbar(
        lang.t('snackbarBookingIncompleteTitle'),
        lang.t('snackbarBookingIncompleteBody'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final childId = GlobalUtils().childId;

    if (childId == null) {
      Get.snackbar(
        lang.t('error'),
        lang.t('childIdNotFoundLogin'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final institutionIdRaw = _institution?['id'];
    // final specialityIdRaw =
    //     _institution?['speciality_id'] ?? _institution?['speciality']?['id'];

    final institutionId = int.tryParse('${institutionIdRaw ?? ''}');
    final specialityId = 5; // int.tryParse('${specialityIdRaw ?? ''}'); //TODO: Remove hardcoded value
    final therapistId = _dummyTherapistIdForApi;

    if (institutionId == null) {
      Get.snackbar(
        lang.t('error'),
        lang.t('snackbarAppointmentDetailsError'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final preferredDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final preferredTime = _selectedTime!;
    final reasonForVisit = lang.t(_selectedReasonForVisit!);

    setState(() {
      _isBooking = true;
    });

    final result = await NetworkHelper().createAppointmentRequest(
      childId: childId,
      institutionId: institutionId,
      specialityId: specialityId,
      therapistId: therapistId,
      preferredDate: preferredDate,
      preferredTime: preferredTime,
      reasonForVisit: reasonForVisit,
    );

    if (!mounted) return;

    setState(() {
      _isBooking = false;
    });

    if (result['success'] != true) {
      final failMsg = result['message']?.toString().trim();
      Get.snackbar(
        lang.t('snackbarBookingFailedTitle'),
        (failMsg != null && failMsg.isNotEmpty)
            ? failMsg
            : lang.t('snackbarBookingFailedBody'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      lang.t('snackbarBookingSuccessTitle'),
      lang.t('snackbarBookingSuccessBody'),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
    Future.delayed(
      const Duration(seconds: 2),
      () => Get.offAllNamed(AppRoutes.dashboard),
    );  
      
  }

  @override
  Widget build(BuildContext context) {
    // --- Therapist list (UI hidden; API uses [_dummyTherapistIdForApi]) ----------
    // final therapistsData =
    //     List<dynamic>.from(_institution?['therapists'] ?? []);
    // final therapists = therapistsData.map((t) => _Therapist(
    //       t['id'].toString(),
    //       t['full_name'] ?? '',
    //       t['code'] ?? '',
    //       t['phone'] ?? '',
    //       t['experience'] ?? 0,
    //     )).toList();
    //
    // final selectedTherapistObj = therapists.firstWhereOrNull(
    //     (t) => t.id == _selectedTherapist);
    // ---------------------------------------------------------------------------

    return Obx(() {
      final lang = LanguageProvider.to;
      final _ = lang.language;

      final instName =
          _institution?['name'] ?? lang.t('institutionDefaultName');
      final instAddress = _institution?['location']?['address'] ??
          lang.t('institutionAddressUnavailable');
      final instTiming =
          _institution?['hours'] ?? lang.t('appointmentDefaultHours');
      final inPersonTitle = lang.t('appointmentInPersonVisitTitle');
      final monthLabel = lang.t('monthShort${_selectedDate.month}');

      return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          GradientHeader(
            onBack: () => Get.back(),
            title: lang.t('bookAppointmentTitle'),
            subtitle: lang.t('bookAppointmentSubtitle'),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.base.r),
              children: [
                // Institution info card
                Container(
                  padding: EdgeInsets.all(AppSpacing.base.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.xl2),
                    border: Border.all(color: AppColors.neutral200),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8)
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60.r,
                        height: 60.r,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE0E7FF), Color(0xFFF3E8FF)],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Icon(Icons.location_on_rounded,
                            size: 28.sp, color: const Color(0xFF4F46E5)),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(instName,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            SizedBox(height: 2.h),
                            Text(instAddress,
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary)),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.green100,
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.full),
                                  ),
                                  child: Text(lang.t('availabilityAvailable'),
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: AppColors.green600,
                                          fontWeight: FontWeight.w500)),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(instTiming,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: AppColors.textSecondary)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // // Select therapist (hidden — server still gets [_dummyTherapistIdForApi])
                // _CardSection(
                //   icon: Icons.person_rounded,
                //   title: 'Select Therapist',
                //   child: Column(
                //     children: therapists.map((t) {
                //       final sel = _selectedTherapist == t.id;
                //       return Padding(
                //         padding: EdgeInsets.only(bottom: 8.h),
                //         child: GestureDetector(
                //           onTap: () =>
                //               setState(() => _selectedTherapist = t.id),
                //           child: AnimatedContainer(
                //             duration: const Duration(milliseconds: 150),
                //             padding: EdgeInsets.all(12.r),
                //             decoration: BoxDecoration(
                //               color: sel
                //                   ? const Color(0xFFEEF2FF)
                //                   : Colors.white,
                //               borderRadius:
                //                   BorderRadius.circular(AppRadius.xl),
                //               border: Border.all(
                //                 color: sel
                //                     ? const Color(0xFF4F46E5)
                //                     : AppColors.neutral200,
                //                 width: sel ? 2 : 1,
                //               ),
                //             ),
                //             child: Row(
                //               children: [
                //                 Expanded(
                //                   child: Column(
                //                     crossAxisAlignment:
                //                         CrossAxisAlignment.start,
                //                     children: [
                //                       Text(t.full_name,
                //                           style: TextStyle(
                //                               fontSize: 13.sp,
                //                               fontWeight: FontWeight.w600,
                //                               color: AppColors.textPrimary)),
                //                       Text(t.code,
                //                           style: TextStyle(
                //                               fontSize: 11.sp,
                //                               color:
                //                                   AppColors.textSecondary)),
                //                     ],
                //                   ),
                //                 ),
                //                 if (sel)
                //                   Icon(Icons.check_circle_rounded,
                //                       size: 20.sp,
                //                       color: const Color(0xFF4F46E5)),
                //               ],
                //             ),
                //           ),
                //         ),
                //       );
                //     }).toList(),
                //   ),
                // ),
                // SizedBox(height: 12.h),

                _CardSection(
                  icon: Icons.edit_note_rounded,
                  title: lang.t('appointmentReasonForVisitTitle'),
                  child: Column(
                    children: _reasonForVisitKeys.map((key) {
                      final sel = _selectedReasonForVisit == key;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: GestureDetector(
                          onTap: () => setState(
                            () => _selectedReasonForVisit = key,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color:
                                  sel ? const Color(0xFFEEF2FF) : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xl),
                              border: Border.all(
                                color: sel
                                    ? const Color(0xFF4F46E5)
                                    : AppColors.neutral200,
                                width: sel ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lang.t(key),
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (sel)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 20.sp,
                                    color: const Color(0xFF4F46E5),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 12.h),

                // Select date — simplified calendar
                _CardSection(
                  icon: Icons.calendar_month_rounded,
                  title: lang.t('appointmentSelectDateTitle'),
                  child: _SimpleDatePicker(
                    selected: _selectedDate,
                    onSelect: (d) => setState(() => _selectedDate = d),
                    weekdayLabel: (w) => lang.t('weekdayShort$w'),
                  ),
                ),
                SizedBox(height: 12.h),

                // Time slots
                _CardSection(
                  icon: Icons.access_time_rounded,
                  title: lang.t('appointmentSelectTimeSlotTitle'),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8.h,
                      crossAxisSpacing: 8.w,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: _slots.length,
                    itemBuilder: (_, i) {
                      final sel = _selectedTime == _slots[i];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedTime = _slots[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFFEEF2FF)
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: sel
                                  ? const Color(0xFF4F46E5)
                                  : AppColors.neutral200,
                              width: sel ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(_slots[i],
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: sel
                                      ? const Color(0xFF4F46E5)
                                      : AppColors.textPrimary,
                                  fontWeight: sel
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                )),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12.h),

                // Appointment type (always in-person; tele option disabled in UI)
                _CardSection(
                  icon: Icons.medical_services_rounded,
                  title: lang.t('appointmentTypeTitle'),
                  child: Column(
                    children: [
                      _TypeBtn(
                        inPersonTitle,
                        lang.t('appointmentInPersonVisitSubtitle'),
                        true,
                        () {},
                      ),
                      // SizedBox(height: 8.h),
                      // _TypeBtn(
                      //   'Tele-Consultation',
                      //   'Online consultation via video call',
                      //   false,
                      //   () => setState(() {}),
                      // ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Summary
                if (_canBook)
                  Container(
                    padding: EdgeInsets.all(AppSpacing.base.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEEF2FF), Color(0xFFF3E8FF)],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xl2),
                      border: Border.all(
                          color: const Color(0xFF4F46E5).withOpacity(0.3),
                          width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lang.t('appointmentSummaryTitle'),
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        SizedBox(height: 10.h),
                        _SummaryRow(lang.t('appointmentSummaryInstitution'), instName),
                        // _SummaryRow(
                        //     'Therapist', selectedTherapistObj?.full_name ?? ''),
                        _SummaryRow(
                          lang.t('appointmentSummaryReason'),
                          _selectedReasonForVisit != null
                              ? lang.t(_selectedReasonForVisit!)
                              : '',
                        ),
                        _SummaryRow(
                            lang.t('appointmentSummaryDate'),
                            '${_selectedDate.day} $monthLabel ${_selectedDate.year}'),
                        _SummaryRow(
                            lang.t('appointmentSummaryTime'),
                            _selectedTime ?? ''),
                        _SummaryRow(lang.t('appointmentSummaryType'), inPersonTitle),
                      ],
                    ),
                  ),
                SizedBox(height: 20.h),
              ],
            ),
          ),

          // Book button
          Container(
            padding: EdgeInsets.all(AppSpacing.base.r),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.neutral200)),
            ),
            child: GradientButton(
              onPressed: _canBook && !_isBooking ? _book : null,
              height: 52.h,
              child: _isBooking
                  ? SizedBox(
                      height: 22.h,
                      width: 22.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(lang.t('appointmentConfirm'),
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
    });
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _CardSection extends StatelessWidget {
  const _CardSection(
      {required this.icon, required this.title, required this.child});
  final IconData icon;
  final String title;
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
          Row(
            children: [
              Icon(icon, size: 18.sp, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text(title,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _SimpleDatePicker extends StatelessWidget {
  const _SimpleDatePicker({
    required this.selected,
    required this.onSelect,
    required this.weekdayLabel,
  });
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final String Function(int weekday) weekdayLabel;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Show next 14 days
    final days = List.generate(14, (i) => now.add(Duration(days: i + 1)));

    return SizedBox(
      height: 72.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, _) => SizedBox(width: 8.w),
        itemCount: days.length,
        itemBuilder: (_, i) {
          final d = days[i];
          final sel = d.day == selected.day && d.month == selected.month;
          return GestureDetector(
            onTap: () => onSelect(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 52.w,
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF4F46E5) : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: sel
                      ? const Color(0xFF4F46E5)
                      : AppColors.neutral200,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdayLabel(d.weekday),
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: sel ? Colors.white : AppColors.textTertiary),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  const _TypeBtn(this.title, this.subtitle, this.selected, this.onTap);
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: selected
                ? const Color(0xFF4F46E5)
                : AppColors.neutral200,
            width: selected ? 2 : 1,
          ),
        ),
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
                    fontSize: 11.sp, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reserved when therapist picker UI is re-enabled:
// class _Therapist {
//   final String id, full_name, code, phone;
//   final dynamic experience;
//   const _Therapist(this.id, this.full_name, this.code, this.phone, this.experience);
// }
