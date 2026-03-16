import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/ReportsScreen.tsx
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _period = 'all';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
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
                              Text('Reports & Documents',
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              Text('Complete health records',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.white
                                          .withOpacity(0.9))),
                            ],
                          ),
                        ),
                        Icon(Icons.filter_list_rounded,
                            size: 22.sp, color: Colors.white),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Period filter
                    SizedBox(
                      height: 40.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: ['week', 'month', 'quarter', 'all']
                            .map((p) => Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _period = p),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      decoration: BoxDecoration(
                                        color: _period == p
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.full),
                                      ),
                                      child: Center(
                                        child: Text(
                                          {
                                            'week': 'This Week',
                                            'month': 'This Month',
                                            'quarter': 'This Quarter',
                                            'all': 'All Time'
                                          }[p]!,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: _period == p
                                                ? const Color(0xFF4338CA)
                                                : Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
          ),

          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tab,
              labelColor: const Color(0xFF4338CA),
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: const Color(0xFF4338CA),
              labelStyle:
                  TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Assessments'),
                Tab(text: 'Progress'),
                Tab(text: 'Therapy'),
                Tab(text: 'Medical'),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.neutral200),

          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _AssessmentsTab(),
                _ProgressTab(),
                _TherapyTab(),
                _MedicalTab(),
              ],
            ),
          ),

          // Bottom actions
          Container(
            padding: EdgeInsets.all(AppSpacing.base.r),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: AppColors.neutral200)),
            ),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.download_rounded,
                      size: 18.sp, color: Colors.white),
                  label: Text('Download All Reports (ZIP)',
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    backgroundColor: const Color(0xFF4338CA),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.xl)),
                  ),
                ),
                SizedBox(height: 8.h),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.share_rounded,
                      size: 18.sp, color: AppColors.textSecondary),
                  label: Text('Share with Care Team',
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    side: const BorderSide(color: AppColors.neutral300),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.xl)),
                  ),
                ),
              ],
            ),
          ),
          const StandardFooter(),
        ],
      ),
    );
  }
}

// ── Tab bodies ───────────────────────────────────────────────────────────────

class _AssessmentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reports = [
      _AReport('TDSC Assessment', 'Nov 15, 2025', 85, 'Normal Development',
          AppColors.success, Icons.assignment_turned_in_rounded),
      _AReport('Parental Stress Scale', 'Nov 10, 2025', 42, 'Moderate Stress',
          AppColors.warning, Icons.favorite_rounded),
      _AReport('LEST — Language Evaluation', 'Nov 8, 2025', 72,
          'Age Appropriate', AppColors.success, Icons.record_voice_over_rounded),
    ];

    return ListView(
      padding: EdgeInsets.all(AppSpacing.base.r),
      children: [
        _InfoBanner('📋 Assessment Reports',
            'Standardized developmental and psychological assessments',
            const Color(0xFFEEF2FF), const Color(0xFFC7D2FE)),
        SizedBox(height: 12.h),
        ...reports.map((r) => _AssessmentReportCard(r: r)),
        _OutlineBtn('View All Assessment History'),
      ],
    );
  }
}

class _ProgressTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.base.r),
      children: [
        _InfoBanner('📈 Progress Reports',
            'Detailed developmental progress tracking across all skill areas',
            const Color(0xFFF5F3FF), const Color(0xFFDDD6FE)),
        SizedBox(height: 12.h),
        _ProgressReportCard(
          title: 'Monthly Progress Report',
          period: 'October 2025',
          summary: 'Significant improvement in gross motor skills and speech',
          categories: const [
            _Cat('Gross Motor', 85, '+12%'),
            _Cat('Fine Motor', 72, '+8%'),
            _Cat('Speech', 68, '+15%'),
            _Cat('Cognitive', 75, '+5%'),
          ],
          color: AppColors.purple,
        ),
        SizedBox(height: 12.h),
        _ProgressReportCard(
          title: 'Quarterly Progress Report',
          period: 'Q3 2025 (Jul–Sep)',
          summary: 'Consistent progress across all developmental areas',
          categories: const [
            _Cat('Gross Motor', 73, '+18%'),
            _Cat('Fine Motor', 64, '+12%'),
            _Cat('Speech', 53, '+20%'),
            _Cat('Cognitive', 70, '+10%'),
          ],
          color: AppColors.purple,
        ),
      ],
    );
  }
}

class _TherapyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.base.r),
      children: [
        _InfoBanner('💚 Therapy Session Reports',
            'Reports from your therapy team on session attendance and progress',
            const Color(0xFFF0FDF4), const Color(0xFFA7F3D0)),
        SizedBox(height: 12.h),
        _TherapyCard(
          therapist: 'Dr. Sarah Thompson',
          specialty: 'Physiotherapy',
          period: 'Nov 1–15, 2025',
          done: 8,
          total: 10,
          notes: 'Excellent progress in standing balance and walking exercises',
        ),
        SizedBox(height: 12.h),
        _TherapyCard(
          therapist: 'Ms. Priya Menon',
          specialty: 'Speech Therapy',
          period: 'Nov 1–15, 2025',
          done: 6,
          total: 8,
          notes:
              'Vocabulary expansion showing good results, now forming 2-word sentences',
        ),
      ],
    );
  }
}

class _MedicalTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.base.r),
      children: [
        _InfoBanner('🏥 Medical Records',
            'Doctor consultations, prescriptions, and medical summaries',
            const Color(0xFFFFF1F2), const Color(0xFFFECDD3)),
        SizedBox(height: 12.h),
        _MedDocCard('Medical Board Certificate', 'Issued: Oct 20, 2025',
            'Valid until Oct 2027', AppColors.red100, AppColors.red600),
        SizedBox(height: 10.h),
        _MedDocCard('UDID Card', 'Unique Disability ID',
            'ID: XXXX-XXXX-XXXX-1234', AppColors.orange100, AppColors.orange600),
        SizedBox(height: 10.h),
        _MedDocCard('Pediatric Consultation Report',
            'Dr. Rajesh Kumar • Nov 10, 2025',
            'Developmental assessment and medication review', AppColors.blue100,
            AppColors.blue600),
      ],
    );
  }
}

// ── Small shared widgets ─────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner(this.title, this.subtitle, this.bgColor, this.borderColor);
  final String title, subtitle;
  final Color bgColor, borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          SizedBox(height: 4.h),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 11.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _AReport {
  final String type, date, status;
  final int score;
  final Color color;
  final IconData icon;
  const _AReport(
      this.type, this.date, this.score, this.status, this.color, this.icon);
}

class _AssessmentReportCard extends StatelessWidget {
  const _AssessmentReportCard({required this.r});
  final _AReport r;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
        children: [
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: r.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(r.icon, size: 24.sp, color: r.color),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.type,
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 11.sp, color: AppColors.textTertiary),
                        SizedBox(width: 3.w),
                        Text(r.date,
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textTertiary)),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: r.color.withOpacity(0.12),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(r.status,
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: r.color,
                                  fontWeight: FontWeight.w500)),
                        ),
                        SizedBox(width: 8.w),
                        Text('Score: ${r.score}%',
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _SmBtn(
                    Icons.visibility_rounded, 'View Details',
                    const Color(0xFF4338CA)),
              ),
              SizedBox(width: 8.w),
              _SmBtn(Icons.download_rounded, 'PDF', AppColors.textSecondary,
                  outline: true),
              SizedBox(width: 8.w),
              _SmBtn(Icons.share_rounded, '', AppColors.textSecondary,
                  outline: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cat {
  final String name, change;
  final int pct;
  const _Cat(this.name, this.pct, this.change);
}

class _ProgressReportCard extends StatelessWidget {
  const _ProgressReportCard({
    required this.title,
    required this.period,
    required this.summary,
    required this.categories,
    required this.color,
  });
  final String title, period, summary;
  final List<_Cat> categories;
  final Color color;

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
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child:
                    Icon(Icons.trending_up_rounded, size: 24.sp, color: color),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    Text(period,
                        style: TextStyle(
                            fontSize: 11.sp, color: AppColors.textTertiary)),
                    Text(summary,
                        style: TextStyle(
                            fontSize: 11.sp, color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...categories.map((c) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(c.name,
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary)),
                        Row(
                          children: [
                            Text('${c.pct}%',
                                style: TextStyle(
                                    fontSize: 12.sp, color: color)),
                            SizedBox(width: 6.w),
                            Text(c.change,
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.success)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: c.pct / 100,
                        minHeight: 6.h,
                        backgroundColor: AppColors.neutral100,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _SmBtn(Icons.visibility_rounded, 'Full Report', color),
              ),
              SizedBox(width: 8.w),
              _SmBtn(Icons.download_rounded, 'PDF', AppColors.textSecondary,
                  outline: true),
              SizedBox(width: 8.w),
              _SmBtn(Icons.share_rounded, '', AppColors.textSecondary,
                  outline: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _TherapyCard extends StatelessWidget {
  const _TherapyCard({
    required this.therapist,
    required this.specialty,
    required this.period,
    required this.done,
    required this.total,
    required this.notes,
  });
  final String therapist, specialty, period, notes;
  final int done, total;

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
                  color: AppColors.green100,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(Icons.medical_services_rounded,
                    size: 24.sp, color: AppColors.green600),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(therapist,
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppColors.blue100,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(specialty,
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppColors.blue600)),
                        ),
                        SizedBox(width: 8.w),
                        Text(period,
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textTertiary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Session Completion',
                  style: TextStyle(
                      fontSize: 12.sp, color: AppColors.textSecondary)),
              Text('$done/$total sessions',
                  style: TextStyle(
                      fontSize: 12.sp, color: AppColors.green600)),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: done / total,
              minHeight: 8.h,
              backgroundColor: AppColors.neutral100,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.green600),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.green100,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Therapist Notes:',
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.green600)),
                SizedBox(height: 3.h),
                Text(notes,
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _SmBtn(Icons.visibility_rounded, 'Session Details',
                    AppColors.green600),
              ),
              SizedBox(width: 8.w),
              _SmBtn(Icons.download_rounded, 'PDF', AppColors.textSecondary,
                  outline: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedDocCard extends StatelessWidget {
  const _MedDocCard(
      this.title, this.subtitle, this.detail, this.bgColor, this.iconColor);
  final String title, subtitle, detail;
  final Color bgColor, iconColor;

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
                child: Icon(Icons.description_rounded,
                    size: 24.sp, color: iconColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textTertiary)),
                    SizedBox(height: 3.h),
                    Text(detail,
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                  child: _SmBtn(
                      Icons.visibility_rounded, 'View', iconColor)),
              SizedBox(width: 8.w),
              _SmBtn(Icons.download_rounded, 'PDF', AppColors.textSecondary,
                  outline: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmBtn extends StatelessWidget {
  const _SmBtn(this.icon, this.label, this.color,
      {this.outline = false});
  final IconData icon;
  final String label;
  final Color color;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 38.h,
        padding: EdgeInsets.symmetric(horizontal: label.isEmpty ? 0 : 12.w),
        width: label.isEmpty ? 38.w : null,
        decoration: BoxDecoration(
          color: outline ? Colors.white : color,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: outline ? Border.all(color: AppColors.neutral300) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 14.sp,
                color: outline ? AppColors.textSecondary : Colors.white),
            if (label.isNotEmpty) ...[
              SizedBox(width: 4.w),
              Text(label,
                  style: TextStyle(
                      fontSize: 11.sp,
                      color: outline ? AppColors.textSecondary : Colors.white,
                      fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, 44.h),
          side: const BorderSide(color: AppColors.neutral300),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13.sp, color: AppColors.textSecondary)),
      ),
    );
  }
}
