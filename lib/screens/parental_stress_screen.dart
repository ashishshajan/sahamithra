import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/network/network_helper.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/ParentalStressScreen.tsx
/// PSI-SF — Parenting Stress Index, Short Form (5-point Likert scale)
class ParentalStressScreen extends StatefulWidget {
  const ParentalStressScreen({super.key});

  @override
  State<ParentalStressScreen> createState() => _ParentalStressScreenState();
}

class _ParentalStressScreenState extends State<ParentalStressScreen> {
  int _current = 0;
  final Map<int, int> _answers = {};

  static const List<String> _fallbackQuestions = [
    'I feel overwhelmed by my parenting responsibilities',
    'I feel stressed about my child\'s development',
    'I have difficulty managing my child\'s behavior',
    'I feel isolated in my parenting journey',
    'I worry about my child\'s future',
    'I have enough support from family and friends',
    'I feel confident in my parenting abilities',
    'I struggle to find time for self-care',
  ];

  List<_StressQuestion> _questions = _fallbackQuestions
      .map((q) => _StressQuestion(questionEnglish: q, questionMalayalam: q))
      .toList();

  static const List<_Option> _options = [
    _Option(1, 'Strongly Disagree'),
    _Option(2, 'Disagree'),
    _Option(3, 'Neutral'),
    _Option(4, 'Agree'),
    _Option(5, 'Strongly Agree'),
  ];

  double get _progress =>
      _questions.isEmpty ? 0 : (_current + 1) / _questions.length;

  void _handleAnswer(int value) {
    setState(() {
      _answers[_current] = value;
      if (_current < _questions.length - 1) {
        _current++;
      }
    });
  }

  void _complete() {
    if (_questions.isEmpty) {
      Get.toNamed('/results', arguments: {
        'type': 'Parental Stress',
        'answers': _answers,
        'score': 0,
        'interpretation': 'No questions available',
      });
      return;
    }
    final total = _answers.values.fold(0, (s, v) => s + v);
    final max = _questions.length * 5;
    final pct = (total / max) * 100;

    String interpretation;
    if (pct <= 40) {
      interpretation = 'Low stress levels — you are managing well';
    } else if (pct <= 60) {
      interpretation = 'Moderate stress — consider seeking support';
    } else {
      interpretation = 'High stress levels — please reach out for professional support';
    }

    Get.toNamed('/results', arguments: {
      'type': 'Parental Stress',
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

  @override
  Widget build(BuildContext context) {
    final answered = _answers.containsKey(_current);
    final isLast = _current == _questions.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header (brand gradient like weekly therapy / other inner screens)
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
                        Text(
                          'Parental Stress Scale',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Question ${_current + 1} of ${_questions.length}',
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.base.r),
              child: Column(
                children: [
                  // Question card
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
                          'Rate your agreement',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.purple,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 8.h),
                        Obx(
                          () => Text(
                            LanguageProvider.to.isEnglish
                                ? _questions[_current].questionEnglish
                                : _questions[_current].questionMalayalam,
                            style: TextStyle(
                              fontSize: 17.sp,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        ..._options.map((opt) {
                          final selected = _answers[_current] == opt.value;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: GestureDetector(
                              onTap: () => _handleAnswer(opt.value),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 14.h),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.purple100
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.xl),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.purple
                                        : AppColors.neutral200,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      width: 22.r,
                                      height: 22.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selected
                                            ? AppColors.purple
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: selected
                                              ? AppColors.purple
                                              : AppColors.neutral300,
                                          width: 2,
                                        ),
                                      ),
                                      child: selected
                                          ? Center(
                                              child: Container(
                                                width: 10.r,
                                                height: 10.r,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      opt.label,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: selected
                                            ? AppColors.purple
                                            : AppColors.textPrimary,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Navigation row
                  Row(
                    children: [
                      if (_current > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _current--),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50.h),
                              side:
                                  const BorderSide(color: AppColors.neutral300),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.xl)),
                            ),
                            child: Text('Previous',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textSecondary)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                      if (isLast && answered)
                        Expanded(
                          child: GradientButton(
                            onPressed: _complete,
                            height: 50.h,
                            child: Text(
                              'Complete Assessment',
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
  }
}

class _StressQuestion {
  const _StressQuestion({
    required this.questionEnglish,
    required this.questionMalayalam,
  });

  final String questionEnglish;
  final String questionMalayalam;
}

class _Option {
  final int value;
  final String label;
  const _Option(this.value, this.label);
}
