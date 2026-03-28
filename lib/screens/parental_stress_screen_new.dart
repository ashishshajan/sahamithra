import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/network/network_helper.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/standard_footer.dart';

/// Duplicate of `ParentalStressScreen` — Yes/No per item (Yes=5, No=1 for scoring).
class ParentalStressScreenNew extends StatefulWidget {
  const ParentalStressScreenNew({super.key});

  @override
  State<ParentalStressScreenNew> createState() =>
      _ParentalStressScreenNewState();
}

class _ParentalStressScreenNewState extends State<ParentalStressScreenNew> {
  int _current = 0;
  final Map<int, bool> _answers = {};

  List<_StressQuestion> _questions = List.generate(
    8,
    (i) => _StressQuestion(l10nKey: 'parentalStressFallback${i + 1}'),
  );

  double get _progress =>
      _questions.isEmpty ? 0 : (_current + 1) / _questions.length;

  void _handleAnswer(bool value) {
    setState(() {
      _answers[_current] = value;
    });
  }

  void _goNext() {
    if (!_answers.containsKey(_current)) return;
    if (_current >= _questions.length - 1) return;
    setState(() => _current++);
  }

  void _complete() {
    final lang = LanguageProvider.to;
    if (_questions.isEmpty) {
      Get.toNamed('/results', arguments: {
        'type': lang.t('stress'),
        'answers': _answers,
        'score': 0,
        'interpretation': lang.t('stressNoQuestionsMsg'),
      });
      return;
    }
    final total = _answers.values.fold(0, (s, v) => s + (v ? 5 : 1));
    final max = _questions.length * 5;
    final pct = (total / max) * 100;

    final String interpretation;
    if (pct <= 40) {
      interpretation = lang.t('stressInterpLow');
    } else if (pct <= 60) {
      interpretation = lang.t('stressInterpModerate');
    } else {
      interpretation = lang.t('stressInterpHigh');
    }

    Get.toNamed('/results', arguments: {
      'type': lang.t('stress'),
      'answers': _answers,
      'score': pct,
      'interpretation': interpretation,
    });
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final result =
        await NetworkHelper().fetchScalesQuestions(category: 'PARENTAL_STRESS');
    if (!mounted) return;

    if (result['success'] != true) return;

    final payload = result['data'];
    final questionsRaw = payload is Map ? payload['data'] : null;
    if (questionsRaw is! List) return;

    final fetched = questionsRaw
        .whereType<Map>()
        .map((q) {
          final english =
              (q['question_english'] ?? q['question_malayalam'] ?? '').toString();
          final malayalam =
              (q['question_malayalam'] ?? q['question_english'] ?? english).toString();
          return _StressQuestion(
            questionEnglish: english,
            questionMalayalam: malayalam,
          );
        })
        .where((s) =>
            s.questionEnglish.isNotEmpty || s.questionMalayalam.isNotEmpty)
        .toList();

    if (fetched.isEmpty) return;

    setState(() {
      _answers.clear();
      _current = 0;
      _questions = fetched.cast<_StressQuestion>();
    });
  }

  String _questionBody(_StressQuestion q) {
    if (q.l10nKey != null) {
      return LanguageProvider.to.t(q.l10nKey!);
    }
    return LanguageProvider.to.isEnglish
        ? q.questionEnglish
        : q.questionMalayalam;
  }

  @override
  Widget build(BuildContext context) {
    final answered = _answers.containsKey(_current);
    final isLast = _current == _questions.length - 1;

    return Obx(() {
      final lang = LanguageProvider.to;

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
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
                            child: Text(
                              lang.t('parentalStressScale'),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 8.h,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '${lang.t('questionLabel')} ${_current + 1} ${lang.t('questionOf')} ${_questions.length}',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.base.r),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xl.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xl2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.t('selectYesOrNo'),
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.purple,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _questionBody(_questions[_current]),
                            style: TextStyle(
                              fontSize: 17.sp,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          GestureDetector(
                            onTap: () => _handleAnswer(true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: EdgeInsets.all(AppSpacing.base.r),
                              decoration: BoxDecoration(
                                color: _answers[_current] == true
                                    ? AppColors.orange100
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xl),
                                border: Border.all(
                                  color: _answers[_current] == true
                                      ? AppColors.orange600
                                      : AppColors.neutral200,
                                  width: _answers[_current] == true ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lang.t('yes'),
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: _answers[_current] == true
                                          ? AppColors.orange600
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (_answers[_current] == true)
                                    Icon(Icons.check_circle_rounded,
                                        size: 20.sp,
                                        color: AppColors.orange600),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          GestureDetector(
                            onTap: () => _handleAnswer(false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: EdgeInsets.all(AppSpacing.base.r),
                              decoration: BoxDecoration(
                                color: _answers[_current] == false
                                    ? AppColors.green100
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xl),
                                border: Border.all(
                                  color: _answers[_current] == false
                                      ? AppColors.green600
                                      : AppColors.neutral200,
                                  width: _answers[_current] == false ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lang.t('no'),
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: _answers[_current] == false
                                          ? AppColors.green600
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (_answers[_current] == false)
                                    Icon(Icons.check_circle_rounded,
                                        size: 20.sp,
                                        color: AppColors.green600),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Center(
                              child: Text(
                                isLast
                                    ? lang.t('parentalStressHintComplete')
                                    : lang.t('parentalStressHintNext'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Row(
                      children: [
                        if (_current > 0) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _current--),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50.h),
                                side: const BorderSide(
                                    color: AppColors.neutral300),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.xl)),
                              ),
                              child: Text(
                                lang.t('previous'),
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                        ],
                        if (!isLast)
                          Expanded(
                            child: GradientButton(
                              onPressed: answered ? _goNext : null,
                              height: 50.h,
                              child: Text(
                                lang.t('next'),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        if (isLast && answered)
                          Expanded(
                            child: GradientButton(
                              onPressed: _complete,
                              height: 50.h,
                              child: Text(
                                lang.t('completeAssessment'),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.base.h),
                  ],
                ),
              ),
            ),
            const StandardFooter(),
          ],
        ),
      );
    });
  }
}

class _StressQuestion {
  const _StressQuestion({
    this.l10nKey,
    this.questionEnglish = '',
    this.questionMalayalam = '',
  });

  /// When set, [LanguageProvider] supplies the line for the current language.
  final String? l10nKey;
  final String questionEnglish;
  final String questionMalayalam;
}
