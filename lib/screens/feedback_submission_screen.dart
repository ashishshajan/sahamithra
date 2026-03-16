import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/gradient_button.dart';
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
  final _notesController = TextEditingController();
  final Map<String, bool?> _quick = {
    'enjoy': null,
    'difficulty': null,
    'more': null,
  };

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      Get.snackbar('Required', 'Please rate your child\'s performance',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
      return;
    }
    Get.snackbar('Submitted!', 'Feedback sent to your care team. +30 points!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white);
    Future.delayed(const Duration(seconds: 2), () => Get.back());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.green600,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Activity Feedback',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Text('Ball Rolling Exercise',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.9))),
                      ],
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
                // Activity info
                _Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ball Rolling Exercise',
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          SizedBox(height: 2.h),
                          Text('Gross Motor • 15 minutes',
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textSecondary)),
                          SizedBox(height: 4.h),
                          Text('Completed: Nov 19, 2025 at 9:30 AM',
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textTertiary)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: AppColors.blue100,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text('Just completed',
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.blue600,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Performance rating
                _Card(
                  child: Column(
                    children: [
                      Text('How did your child perform?',
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
                          'Tap to rate performance',
                          'Needs more practice',
                          'Making progress',
                          'Good effort',
                          'Great job!',
                          'Excellent performance!',
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
                      Text("How was your child's mood?",
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          _MoodBtn('happy', '😊', 'Happy', AppColors.success,
                              _mood, () => setState(() => _mood = 'happy')),
                          SizedBox(width: 8.w),
                          _MoodBtn('neutral', '😐', 'Neutral',
                              AppColors.warning, _mood,
                              () => setState(() => _mood = 'neutral')),
                          SizedBox(width: 8.w),
                          _MoodBtn('fussy', '😢', 'Fussy', AppColors.error,
                              _mood, () => setState(() => _mood = 'fussy')),
                        ],
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
                      Text('Additional Notes (Optional)',
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 10.h),
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'Share observations, challenges, or achievements...',
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
                          'Your feedback helps therapists adjust the therapy program',
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Photo upload
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Photo or Video (Optional)',
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(AppSpacing.xl2.r),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.neutral300,
                                width: 2,
                                style: BorderStyle.solid),
                            borderRadius:
                                BorderRadius.circular(AppRadius.xl2),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.camera_alt_rounded,
                                  size: 32.sp,
                                  color: AppColors.textTertiary),
                              SizedBox(height: 8.h),
                              Text('Tap to capture progress',
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColors.textSecondary)),
                              SizedBox(height: 3.h),
                              Text('Photos help track improvement over time',
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Quick questions
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Questions',
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 12.h),
                      _QuickQ('Did your child enjoy this activity?', 'enjoy',
                          _quick, (k, v) => setState(() => _quick[k] = v)),
                      const Divider(),
                      _QuickQ('Was the difficulty level appropriate?',
                          'difficulty', _quick,
                          (k, v) => setState(() => _quick[k] = v)),
                      const Divider(),
                      _QuickQ('Would you like more activities like this?',
                          'more', _quick,
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
                      Text('📋 Your therapist will see:',
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blue600)),
                      SizedBox(height: 8.h),
                      ...['Performance rating and mood',
                        'Your detailed feedback and observations',
                        'Photos/videos (if uploaded)',
                        'Activity completion time and duration',
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
                  onPressed: _rating > 0 ? _submit : null,
                  height: 52.h,
                  gradient: LinearGradient(
                    colors: [AppColors.green600, AppColors.green600],
                  ),
                  child: Text('Submit Feedback',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
                SizedBox(height: 6.h),
                Text('Feedback will be shared with your care team',
                    style: TextStyle(
                        fontSize: 11.sp, color: AppColors.textTertiary)),
              ],
            ),
          ),
          const StandardFooter(),
        ],
      ),
    );
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
  const _QuickQ(this.question, this.key_, this.answers, this.onAnswer);
  final String question, key_;
  final Map<String, bool?> answers;
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
          _YNBtn('Yes', answers[key_] == true, AppColors.success,
              () => onAnswer(key_, true)),
          SizedBox(width: 6.w),
          _YNBtn('No', answers[key_] == false, AppColors.error,
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
