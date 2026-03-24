import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
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
  String? _selectedTherapist;
  String? _selectedTime;
  bool _inPerson = true;
  bool _isBooking = false;

  // Selected date state using a simple DateTime
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  static const List<String> _slots = [
    '9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '2:00 PM', '2:30 PM', '3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM',
  ];

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _institution = Get.arguments as Map<String, dynamic>?;
  }

  bool get _canBook =>
      _selectedTherapist != null && _selectedTime != null;

  Future<void> _book() async {
    if (!_canBook) {
      Get.snackbar(
        'Incomplete',
        'Please select a therapist and time slot',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final childId = GlobalUtils().childId;

    if (childId == null) {
      Get.snackbar(
        'Error',
        'Child id not found. Please log in again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final institutionIdRaw = _institution?['id'];
    final specialityIdRaw =
        _institution?['speciality_id'] ?? _institution?['speciality']?['id'];
    print('Therapist: ${_selectedTherapist}');
    final therapistIdRaw = _selectedTherapist;

    final institutionId = int.tryParse('${institutionIdRaw ?? ''}');
    final specialityId = 5;//int.tryParse('${specialityIdRaw ?? ''}'); //TODO: Remove this hardcoded value
    final therapistId = int.tryParse(therapistIdRaw ?? '');

    if (institutionId == null ||
        specialityId == null ||
        therapistId == null) {
      Get.snackbar(
        'Error',
        'Unable to determine appointment details. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final preferredDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final preferredTime = _selectedTime!;

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
      reasonForVisit: '',
    );

    if (!mounted) return;

    setState(() {
      _isBooking = false;
    });

    if (result['success'] != true) {
      Get.snackbar(
        'Booking Failed',
        result['message'] ?? 'Unable to book appointment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Appointment Booked!',
      'Your appointment has been confirmed. +25 points earned!',
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
    final therapistsData = List<dynamic>.from(_institution?['therapists'] ?? []);
    final therapists = therapistsData.map((t) => _Therapist(
      t['id'].toString(),
      t['full_name'] ?? '',
      t['code'] ?? '',
      t['phone'] ?? '',
      t['experience'] ?? 0,
    )).toList();

    final selectedTherapistObj = therapists.firstWhereOrNull(
        (t) => t.id == _selectedTherapist);
    
    final instName = _institution?['name'] ?? 'Institution';
    final instAddress = _institution?['location']?['address'] ?? 'Address unavailable';
    final instTiming = _institution?['hours'] ?? 'Mon–Sat: 9 AM – 5 PM';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          GradientHeader(
            onBack: () => Get.back(),
            title: 'Book Appointment',
            subtitle: 'Schedule a therapy session',
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
                                  child: Text('Available',
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

                // Select therapist
                _CardSection(
                  icon: Icons.person_rounded,
                  title: 'Select Therapist',
                  child: Column(
                    children: therapists.map((t) {
                      final sel = _selectedTherapist == t.id;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedTherapist = t.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFFEEF2FF)
                                  : Colors.white,
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(t.full_name,
                                          style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary)),
                                      Text(t.code,
                                          style: TextStyle(
                                              fontSize: 11.sp,
                                              color:
                                                  AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                if (sel)
                                  Icon(Icons.check_circle_rounded,
                                      size: 20.sp,
                                      color: const Color(0xFF4F46E5)),
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
                  title: 'Select Date',
                  child: _SimpleDatePicker(
                    selected: _selectedDate,
                    onSelect: (d) => setState(() => _selectedDate = d),
                  ),
                ),
                SizedBox(height: 12.h),

                // Time slots
                _CardSection(
                  icon: Icons.access_time_rounded,
                  title: 'Select Time Slot',
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

                // Appointment type
                _CardSection(
                  icon: Icons.medical_services_rounded,
                  title: 'Appointment Type',
                  child: Column(
                    children: [
                      _TypeBtn('In-Person Visit',
                          'Visit the center for therapy session',
                          _inPerson, () => setState(() => _inPerson = true)),
                      SizedBox(height: 8.h),
                      _TypeBtn('Tele-Consultation',
                          'Online consultation via video call',
                          !_inPerson, () => setState(() => _inPerson = false)),
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
                        Text('Appointment Summary',
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        SizedBox(height: 10.h),
                        _SummaryRow('Institution', instName),
                        _SummaryRow('Therapist', selectedTherapistObj?.full_name ?? ''),
                        _SummaryRow('Date',
                            '${_selectedDate.day} ${_months[_selectedDate.month - 1]} ${_selectedDate.year}'),
                        _SummaryRow('Time', _selectedTime ?? ''),
                        _SummaryRow(
                            'Type', _inPerson ? 'In-Person Visit' : 'Tele-Consultation'),
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
                  : Text('Confirm Appointment',
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
  const _SimpleDatePicker({required this.selected, required this.onSelect});
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Show next 14 days
    final days = List.generate(14, (i) => now.add(Duration(days: i + 1)));
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 72.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
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
                    dayNames[d.weekday - 1],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13.sp, color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _Therapist {
  final String id, full_name, code, phone;
  final dynamic experience;
  const _Therapist(this.id, this.full_name, this.code, this.phone, this.experience);
}
