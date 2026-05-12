import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sahamitra1_0/widgets/gradient_header.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/app_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/standard_footer.dart';

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

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _showFeedbackDialog(LanguageProvider lang) async {
    final subjectCtrl = TextEditingController(text: 'Progress Feedback');
    final descriptionCtrl = TextEditingController();

    int sessionId = 0;
    int therapyId = 0;
    final args = Get.arguments;
    if (args is Map) {
      sessionId = _asInt(args['session_id'] ?? args['sessionId']);
      therapyId = _asInt(args['therapy_id'] ?? args['therapyId']);
    }

    final isSubmitting = false.obs;

    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, 16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: const BoxDecoration(
                      color: AppColors.purple50,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.purple,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      lang.t('addFeedback'),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: subjectCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  filled: true,
                  fillColor: AppColors.neutral100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                ),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: descriptionCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: lang.t('enterFeedback'),
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppColors.neutral100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(12.r),
                ),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSubmitting.value ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 44.h),
                          side: const BorderSide(color: AppColors.neutral300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                        ),
                        child: Text(
                          lang.t('cancel'),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSubmitting.value
                            ? null
                            : () => _submitFeedback(
                                  lang: lang,
                                  subjectCtrl: subjectCtrl,
                                  descriptionCtrl: descriptionCtrl,
                                  sessionId: sessionId,
                                  therapyId: therapyId,
                                  isSubmitting: isSubmitting,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 44.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                        ),
                        child: isSubmitting.value
                            ? SizedBox(
                                width: 18.r,
                                height: 18.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                lang.t('submitFeedback'),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    subjectCtrl.dispose();
    descriptionCtrl.dispose();
  }

  Future<void> _submitFeedback({
    required LanguageProvider lang,
    required TextEditingController subjectCtrl,
    required TextEditingController descriptionCtrl,
    required int sessionId,
    required int therapyId,
    required RxBool isSubmitting,
  }) async {
    final description = descriptionCtrl.text.trim();
    if (description.isEmpty) {
      Get.snackbar(
        'Required',
        lang.t('enterFeedback'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }
    final subject = subjectCtrl.text.trim().isEmpty
        ? 'Progress Feedback'
        : subjectCtrl.text.trim();

    isSubmitting.value = true;
    final result = await NetworkHelper().submitPatientFeedback(
      sessionId: sessionId,
      therapyId: therapyId,
      feedbackSubject: subject,
      feedbackDescription: description,
    );
    isSubmitting.value = false;

    final ok = result['success'] == true;
    final message = (result['message'] ?? '').toString();
    if (ok) {
      Get.back();
      Get.snackbar(
        'Submitted!',
        message.isNotEmpty ? message : 'Feedback submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Failed',
        message.isNotEmpty ? message : 'Unable to submit feedback',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lang = LanguageProvider.to;
      final _ = lang.language;

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              GradientHeader(
                onBack: () => Get.back(),
                title: lang.t('progressTrackingTitle'),
                subtitle: lang.t('progressTrackingSubtitle'),
              ),
              _buildPeriodSelector(lang),

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
                  tabs: [
                    Tab(text: lang.t('tabOverview')),
                    Tab(text: lang.t('tabGoals')),
                    Tab(text: lang.t('tabActivities')),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(lang),
                    _buildGoalsTab(lang),
                    _buildActivitiesTab(lang),
                  ],
                ),
              ),

              _buildFooter(lang),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPeriodSelector(LanguageProvider lang) {
    return Container(
      color: Colors.white,
      padding:
          EdgeInsets.symmetric(horizontal: AppSpacing.base.w, vertical: 12.h),
      child: Row(
        children: [
          _PeriodChip(
            label: lang.t('periodWeek'),
            active: _selectedPeriod == 'week',
            onTap: () => setState(() => _selectedPeriod = 'week'),
          ),
          SizedBox(width: 8.w),
          _PeriodChip(
            label: lang.t('periodMonth'),
            active: _selectedPeriod == 'month',
            onTap: () => setState(() => _selectedPeriod = 'month'),
          ),
          SizedBox(width: 8.w),
          _PeriodChip(
            label: lang.t('periodAllTime'),
            active: _selectedPeriod == 'all',
            onTap: () => setState(() => _selectedPeriod = 'all'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(LanguageProvider lang) {
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
                          lang.t('overallProgress'),
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
                  lang.t('progressDeltaFromLastMonth'),
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
                  lang.t('skillAreasProgress'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.base.h),
                _SkillBar(
                  label: lang.t('skillGrossMotor'),
                  value: p.grossMotor,
                  color: AppColors.blue600,
                ),
                SizedBox(height: AppSpacing.base.h),
                _SkillBar(
                  label: lang.t('skillFineMotor'),
                  value: p.fineMotor,
                  color: AppColors.green600,
                ),
                SizedBox(height: AppSpacing.base.h),
                _SkillBar(
                  label: lang.t('skillSpeechLanguage'),
                  value: p.speech,
                  color: AppColors.purple,
                ),
                SizedBox(height: AppSpacing.base.h),
                _SkillBar(
                  label: lang.t('skillCognitive'),
                  value: p.cognitive,
                  color: AppColors.orange600,
                ),
                SizedBox(height: AppSpacing.base.h),
                _SkillBar(
                  label: lang.t('skillSocial'),
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
                  lang.t('activityStatistics'),
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
                          label: lang.t('statCompleted'),
                          value: '${app.completedCount}',
                          bg: const Color(0xFFEEF2FF),
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _StatBox(
                          label: lang.t('statPending'),
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

  Widget _buildGoalsTab(LanguageProvider lang) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.base.r),
      children: [
        _GoalCard(
          title: lang.t('goalMock1Title'),
          status: lang.t('goalStatusCompleted'),
          statusColor: AppColors.success,
          statusBg: const Color(0xFFD1FAE5),
          targetDate: lang.t('goalMock1Meta'),
          progress: 1.0,
          progressColor: AppColors.success,
          borderColor: AppColors.success,
        ),
        SizedBox(height: 12.h),
        _GoalCard(
          title: lang.t('goalMock2Title'),
          status: lang.t('goalStatusInProgress'),
          statusColor: AppColors.blue600,
          statusBg: AppColors.blue100,
          targetDate: lang.t('goalMock2Meta'),
          progress: 0.70,
          progressColor: AppColors.blue600,
          borderColor: AppColors.blue600,
        ),
        SizedBox(height: 12.h),
        _GoalCard(
          title: lang.t('goalMock3Title'),
          status: lang.t('goalStatusInProgress'),
          statusColor: AppColors.orange600,
          statusBg: AppColors.orange100,
          targetDate: lang.t('goalMock3Meta'),
          progress: 0.60,
          progressColor: AppColors.orange600,
          borderColor: AppColors.orange600,
        ),
      ],
    );
  }

  Widget _buildActivitiesTab(LanguageProvider lang) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.base.r),
      children: [
        _ActivityLogCard(
          lang: lang,
          title: lang.t('activityMock1Title'),
          time: lang.t('activityMock1Time'),
          feedback: lang.t('activityMock1Feedback'),
          stars: 4,
        ),
        SizedBox(height: 12.h),
        _ActivityLogCard(
          lang: lang,
          title: lang.t('activityMock2Title'),
          time: lang.t('activityMock2Time'),
          feedback: lang.t('activityMock2Feedback'),
          stars: 5,
        ),
      ],
    );
  }

  Widget _buildFooter(LanguageProvider lang) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(AppSpacing.base.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: AppColors.neutral200),
          SizedBox(height: AppSpacing.base.h),
          GradientButton(
            onPressed: () => _showFeedbackDialog(lang),
            height: 48.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  lang.t('addFeedback'),
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
    required this.lang,
    required this.title,
    required this.time,
    required this.feedback,
    required this.stars,
  });

  final LanguageProvider lang;
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
                  lang.t('activityCompletedBadge'),
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
            '${lang.t('parentFeedbackLabel')} $feedback',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                lang.t('performanceLabel'),
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
