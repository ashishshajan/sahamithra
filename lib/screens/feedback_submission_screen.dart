import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_header.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/FeedbackSubmissionScreen.tsx
class FeedbackSubmissionScreen extends StatefulWidget {
  const FeedbackSubmissionScreen({super.key});

  @override
  State<FeedbackSubmissionScreen> createState() =>
      _FeedbackSubmissionScreenState();
}

class _FeedbackSubmissionScreenState extends State<FeedbackSubmissionScreen> {
  int _rating = 0;
  String _mood = '';
  final _subjectController = TextEditingController();
  final _notesController = TextEditingController();
  int _sessionId = 0;
  int _therapyId = 0;
  String _sessionName = '';
  bool _isSubmitting = false;
  final Map<String, bool?> _quick = {
    'enjoy': null,
    'difficulty': null,
    'more': null,
  };

  @override
  void initState() {
    super.initState();
    final raw = Get.arguments;
    if (raw is Map) {
      final m = Map<String, dynamic>.from(
        raw.map((k, v) => MapEntry(k.toString(), v)),
      );
      _sessionId = _asInt(m['session_id']);
      _therapyId = _asInt(m['therapy_id']);
      final name = m['session_name']?.toString().trim();
      if (name != null && name.isNotEmpty) {
        _sessionName = name;
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  String _formatMoodForApi() {
    if (_mood.trim().isEmpty) return 'not_selected';
    return _mood.trim();
  }

  String _formatQuickAnswer(bool? value) {
    if (value == null) return 'not_answered';
    return value ? 'yes' : 'no';
  }

  String _buildFeedbackDescription(String userNotes) {
    final details = <String>[
      'rating=$_rating',
      'mood=${_formatMoodForApi()}',
      'enjoy=${_formatQuickAnswer(_quick['enjoy'])}',
      'difficulty=${_formatQuickAnswer(_quick['difficulty'])}',
      'more=${_formatQuickAnswer(_quick['more'])}',
    ].join(', ');

    return '$details\nnotes=$userNotes';
  }

  Future<void> _submit() async {
    final lang = LanguageProvider.to;
    if (_isSubmitting) return;
    if (_sessionId <= 0 || _therapyId <= 0) {
      Get.snackbar(
        lang.t('feedbackUnavailableTitle'),
        lang.t('feedbackSessionDetailsMissing'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }
    if (_rating == 0) {
      Get.snackbar(lang.t('feedbackRequiredTitle'),
          lang.t('feedbackRatePerformanceRequired'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
      return;
    }
    final subject = _subjectController.text.trim();
    final notes = _notesController.text.trim();
    if (subject.isEmpty) {
      Get.snackbar(
        lang.t('feedbackRequiredTitle'),
        lang.t('feedbackSubjectRequired'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }
    if (notes.isEmpty) {
      Get.snackbar(
        lang.t('feedbackRequiredTitle'),
        lang.t('feedbackDetailsRequired'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final description = _buildFeedbackDescription(notes);

    setState(() => _isSubmitting = true);
    final result = await NetworkHelper().submitPatientFeedback(
      sessionId: _sessionId,
      therapyId: _therapyId,
      feedbackSubject: subject,
      feedbackDescription: description,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final ok = result['success'] == true;
    final message = (result['message'] ?? '').toString();
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${lang.t('feedbackSubmittedTitle')} '
            '${message.isNotEmpty ? message : lang.t('feedbackSubmittedSuccess')}',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 1),
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Get.back(result: true);
      });
      return;
    }

    Get.snackbar(
      lang.t('feedbackFailedTitle'),
      message.isNotEmpty ? message : lang.t('feedbackSubmitFailed'),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lang = LanguageProvider.to;
      final _ = lang.language;
      final sessionDisplayName = _sessionName.trim().isEmpty
          ? lang.t('feedbackActivityFallback')
          : _sessionName;
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            GradientHeader(
              onBack: () => Get.back(),
              title: lang.t('feedbackHeaderTitle'),
              subtitle: sessionDisplayName,
            ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.base.r),
              children: [
                // Activity info
                _Card(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sessionDisplayName,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            SizedBox(height: 2.h),
                            Text(lang.t('feedbackActivityMeta'),
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary)),
                            SizedBox(height: 4.h),
                            Text(lang.t('feedbackCompletedAt'),
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppColors.blue100,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            lang.t('feedbackStatusJustCompleted'),
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.blue600,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Performance rating
                _Card(
                  child: Column(
                    children: [
                      Text(lang.t('feedbackPerformanceQuestion'),
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          final star = i + 1;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _rating = star),
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 6.w),
                              child: Icon(
                                star <= _rating
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 42.sp,
                                color: star <= _rating
                                    ? Colors.amber
                                    : AppColors.neutral300,
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        [
                          lang.t('feedbackRatingTap'),
                          lang.t('feedbackRatingNeedsPractice'),
                          lang.t('feedbackRatingMakingProgress'),
                          lang.t('feedbackRatingGoodEffort'),
                          lang.t('feedbackRatingGreatJob'),
                          lang.t('feedbackRatingExcellent'),
                        ][_rating],
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Child's mood
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.t('feedbackMoodQuestion'),
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          _MoodBtn('happy', '😊', lang.t('feedbackMoodHappy'),
                              AppColors.success,
                              _mood, () => setState(() => _mood = 'happy')),
                          SizedBox(width: 8.w),
                          _MoodBtn('neutral', '😐', lang.t('feedbackMoodNeutral'),
                              AppColors.warning, _mood,
                              () => setState(() => _mood = 'neutral')),
                          SizedBox(width: 8.w),
                          _MoodBtn('fussy', '😢', lang.t('feedbackMoodFussy'),
                              AppColors.error,
                              _mood, () => setState(() => _mood = 'fussy')),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.t('feedbackSubjectLabel'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      TextField(
                        controller: _subjectController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: lang.t('feedbackSubjectHint'),
                          hintStyle: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textTertiary,
                          ),
                          filled: true,
                          fillColor: AppColors.neutral100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.all(12.r),
                        ),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Notes
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.t('feedbackAdditionalNotesOptional'),
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 10.h),
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: lang.t('feedbackAdditionalNotesHint'),
                          hintStyle: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textTertiary),
                          filled: true,
                          fillColor: AppColors.neutral100,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.xl),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.all(12.r),
                        ),
                        style: TextStyle(
                            fontSize: 13.sp, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                          lang.t('feedbackNotesHelper'),
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Photo upload
                // _Card(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text('Add Photo or Video (Optional)',
                //           style: TextStyle(
                //               fontSize: 14.sp,
                //               fontWeight: FontWeight.w600,
                //               color: AppColors.textPrimary)),
                //       SizedBox(height: 10.h),
                //       GestureDetector(
                //         onTap: () {},
                //         child: Container(
                //           width: double.infinity,
                //           padding: EdgeInsets.all(AppSpacing.xl2.r),
                //           decoration: BoxDecoration(
                //             border: Border.all(
                //                 color: AppColors.neutral300,
                //                 width: 2,
                //                 style: BorderStyle.solid),
                //             borderRadius:
                //                 BorderRadius.circular(AppRadius.xl2),
                //           ),
                //           child: Column(
                //             children: [
                //               Icon(Icons.camera_alt_rounded,
                //                   size: 32.sp,
                //                   cuccessful feedback submission go back to olor: AppColors.textTertiary),
                //               SizedBox(height: 8.h),
                //               Text('Tap to capture progress',
                //                   style: TextStyle(
                //                       fontSize: 13.sp,
                //                       color: AppColors.textSecondary)),
                //               SizedBox(height: 3.h),
                //               Text('Photos help track improvement over time',
                //                   style: TextStyle(
                //                       fontSize: 11.sp,
                //                       color: AppColors.textTertiary)),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: 12.h),

                // Quick questions
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.t('feedbackQuickQuestions'),
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 12.h),
                      _QuickQ(
                          lang.t('feedbackQuickQEnjoy'),
                          'enjoy',
                          _quick,
                          lang.t('yes'),
                          lang.t('no'),
                          (k, v) => setState(() => _quick[k] = v)),
                      const Divider(),
                      _QuickQ(lang.t('feedbackQuickQDifficulty'), 'difficulty',
                          _quick, lang.t('yes'), lang.t('no'),
                          (k, v) => setState(() => _quick[k] = v)),
                      const Divider(),
                      _QuickQ(lang.t('feedbackQuickQMore'), 'more', _quick,
                          lang.t('yes'), lang.t('no'),
                          (k, v) => setState(() => _quick[k] = v)),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Info box
                Container(
                  padding: EdgeInsets.all(AppSpacing.base.r),
                  decoration: BoxDecoration(
                    color: AppColors.blue100,
                    borderRadius: BorderRadius.circular(AppRadius.xl2),
                    border: Border.all(color: AppColors.blue600.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.t('feedbackTherapistWillSee'),
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blue600)),
                      SizedBox(height: 8.h),
                      ...[lang.t('feedbackTherapistSee1'),
                        lang.t('feedbackTherapistSee2'),
                        lang.t('feedbackTherapistSee3'),
                        lang.t('feedbackTherapistSee4'),
                      ].map((t) => Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Row(
                              children: [
                                Text('• ',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.blue600)),
                                Expanded(
                                    child: Text(t,
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColors.textSecondary))),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),

          // Submit
          Container(
            padding: EdgeInsets.all(AppSpacing.base.r),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: AppColors.neutral200)),
            ),
            child: Column(
              children: [
                GradientButton(
                  onPressed: (_rating > 0 && !_isSubmitting) ? _submit : null,
                  height: 52.h,
                  child: _isSubmitting
                      ? SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(lang.t('submitFeedback'),
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
                SizedBox(height: 6.h),
                Text(lang.t('feedbackSharedWithCareTeam'),
                    style: TextStyle(
                        fontSize: 11.sp, color: AppColors.textTertiary)),
              ],
            ),
          ),
          const StandardFooter(),
        ],
      ),
    );
    });
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
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
      child: child,
    );
  }
}

class _MoodBtn extends StatelessWidget {
  const _MoodBtn(
      this.key_, this.emoji, this.label, this.color, this.selected, this.onTap);
  final String key_, emoji, label;
  final Color color;
  final String selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == key_;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl2),
            border: Border.all(
              color: isSelected ? color : AppColors.neutral200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: TextStyle(fontSize: 32.sp)),
              SizedBox(height: 4.h),
              Text(label,
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: isSelected ? color : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickQ extends StatelessWidget {
  const _QuickQ(this.question, this.key_, this.answers, this.yesLabel,
      this.noLabel, this.onAnswer);
  final String question, key_;
  final Map<String, bool?> answers;
  final String yesLabel;
  final String noLabel;
  final void Function(String, bool) onAnswer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
              child: Text(question,
                  style: TextStyle(
                      fontSize: 13.sp, color: AppColors.textPrimary))),
          SizedBox(width: 12.w),
          _YNBtn(yesLabel, answers[key_] == true, AppColors.success,
              () => onAnswer(key_, true)),
          SizedBox(width: 6.w),
          _YNBtn(noLabel, answers[key_] == false, AppColors.error,
              () => onAnswer(key_, false)),
        ],
      ),
    );
  }
}

class _YNBtn extends StatelessWidget {
  const _YNBtn(this.label, this.selected, this.activeColor, this.onTap);
  final String label;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
              color: selected ? activeColor : AppColors.neutral300),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}
