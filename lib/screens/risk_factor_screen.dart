import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/network/network_helper.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_header.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/RiskFactorScreen.tsx
class RiskFactorScreen extends StatefulWidget {
  const RiskFactorScreen({super.key});

  @override
  State<RiskFactorScreen> createState() => _RiskFactorScreenState();
}

class _RiskFactorScreenState extends State<RiskFactorScreen> {
  int _current = 0;
  final Map<int, bool> _answers = {};

  static  List<_RiskFactor> _fallbackFactors = [
    _RiskFactor(
      questionEnglish: 'Was the child born prematurely (before 37 weeks)?',
      questionMalayalam: 'Was the child born prematurely (before 37 weeks)?',
      category: 'Birth History',
    ),
    _RiskFactor(
      questionEnglish: 'Did the child have low birth weight (less than 2.5 kg)?',
      questionMalayalam: 'Did the child have low birth weight (less than 2.5 kg)?',
      category: 'Birth History',
    ),
    _RiskFactor(
      questionEnglish: 'Were there any complications during pregnancy or delivery?',
      questionMalayalam: 'Were there any complications during pregnancy or delivery?',
      category: 'Birth History',
    ),
    _RiskFactor(
      questionEnglish: 'Is there a family history of developmental delays or disabilities?',
      questionMalayalam: 'Is there a family history of developmental delays or disabilities?',
      category: 'Family History',
    ),
    _RiskFactor(
      questionEnglish: 'Does the child have any genetic conditions or syndromes?',
      questionMalayalam: 'Does the child have any genetic conditions or syndromes?',
      category: 'Medical History',
    ),
    _RiskFactor(
      questionEnglish: 'Has the child experienced any serious infections (meningitis, encephalitis)?',
      questionMalayalam: 'Has the child experienced any serious infections (meningitis, encephalitis)?',
      category: 'Medical History',
    ),
    _RiskFactor(
      questionEnglish: 'Does the child have hearing or vision problems?',
      questionMalayalam: 'Does the child have hearing or vision problems?',
      category: 'Sensory',
    ),
    _RiskFactor(
      questionEnglish: 'Has the child had any head injuries or seizures?',
      questionMalayalam: 'Has the child had any head injuries or seizures?',
      category: 'Medical History',
    ),
    _RiskFactor(
      questionEnglish: 'Is the child exposed to environmental toxins (lead, mercury)?',
      questionMalayalam: 'Is the child exposed to environmental toxins (lead, mercury)?',
      category: 'Environmental',
    ),
    _RiskFactor(
      questionEnglish: 'Does the child have limited access to early childhood education?',
      questionMalayalam: 'Does the child have limited access to early childhood education?',
      category: 'Social/Environmental',
    ),
    _RiskFactor(
      questionEnglish: 'Has the child experienced significant stress or trauma?',
      questionMalayalam: 'Has the child experienced significant stress or trauma?',
      category: 'Social/Environmental',
    ),
    _RiskFactor(
      questionEnglish: 'Does the child have chronic health conditions (asthma, diabetes)?',
      questionMalayalam: 'Does the child have chronic health conditions (asthma, diabetes)?',
      category: 'Medical History',
    ),
  ];

  List<_RiskFactor> _factors = List.of(_fallbackFactors);

  double get _progress => _factors.isEmpty ? 0 : (_current + 1) / _factors.length;

  bool get _canComplete => _factors.isNotEmpty && _answers.length == _factors.length;

  void _handleAnswer(bool value) {
    setState(() {
      _answers[_current] = value;
      if (_current < _factors.length - 1) {
        _current++;
      }
    });
  }

  void _complete() {
    if (_factors.isEmpty) {
      Get.toNamed('/results', arguments: {
        'type': 'Risk Factor',
        'answers': _answers,
        'score': 0,
        'interpretation': 'No risk factors available',
        'riskCount': 0,
      });
      return;
    }
    final riskCount = _answers.values.where((v) => v).length;
    String interpretation;
    if (riskCount == 0) {
      interpretation = 'No significant risk factors identified';
    } else if (riskCount <= 2) {
      interpretation = 'Low risk — Minimal risk factors. Continue regular monitoring.';
    } else if (riskCount <= 4) {
      interpretation = 'Moderate risk — Some risk factors identified. Consider early intervention.';
    } else if (riskCount <= 6) {
      interpretation = 'High risk — Multiple risk factors. Early intervention strongly recommended.';
    } else {
      interpretation = 'Very high risk — Significant risk factors. Immediate evaluation recommended.';
    }

    Get.toNamed('/results', arguments: {
      'type': 'Risk Factor',
      'answers': _answers,
      'score': (riskCount / _factors.length) * 100,
      'interpretation': interpretation,
      'riskCount': riskCount,
    });
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final result =
        await NetworkHelper().fetchScalesQuestions(category: 'RISK_FACTOR');
    if (!mounted) return;

    if (result['success'] != true) return;

    final payload = result['data'];
    final questionsRaw = payload is Map ? payload['data'] : null;
    if (questionsRaw is! List) return;

    final fetched = questionsRaw
        .whereType<Map>()
        .map((q) {
          final id = q['id']?.toString() ?? '';
          final questionEnglish =
              (q['question_english'] ?? q['question_malayalam'] ?? '')
                  .toString();
          final questionMalayalam =
              (q['question_malayalam'] ?? q['question_english'] ?? questionEnglish)
                  .toString();
          final cat = q['category']?.toString() ?? 'Risk';

          if (questionEnglish.isEmpty && questionMalayalam.isEmpty) return null;
          return _RiskFactor(
            questionEnglish: questionEnglish,
            questionMalayalam: questionMalayalam,
            category: cat,
          );
        })
        .whereType<_RiskFactor>()
        .toList();

    if (fetched.isEmpty) return;

    setState(() {
      _answers.clear();
      _current = 0;
      _factors = fetched;
    });
  }

  @override
  Widget build(BuildContext context) {
    final factor = _factors[_current];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Gradient header with progress
          Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
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
                            'Risk Factor Checklist',
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
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Question ${_current + 1} of ${_factors.length}',
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
                  // Question card
                  Container(
                    padding: EdgeInsets.all(AppSpacing.xl.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.xl2),
                      border: Border.all(color: AppColors.purple100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 16.sp, color: AppColors.orange600),
                            SizedBox(width: 6.w),
                            Text(
                              factor.category,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.orange600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Obx(
                          () => Text(
                            LanguageProvider.to.isEnglish
                                ? factor.questionEnglish
                                : factor.questionMalayalam,
                            style: TextStyle(
                              fontSize: 17.sp,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Yes button
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Yes',
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
                                      size: 20.sp, color: AppColors.orange600),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // No button
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'No',
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
                                      size: 20.sp, color: AppColors.green600),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Center(
                            child: Text(
                              'Select your answer to continue to the next question',
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
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _current > 0
                              ? () => setState(() => _current--)
                              : null,
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50.h),
                            side: const BorderSide(color: AppColors.neutral300),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xl)),
                          ),
                          child: Text('Back',
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary)),
                        ),
                      ),
                      if (_canComplete) ...[
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _complete,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50.h),
                              backgroundColor: AppColors.orange600,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.xl)),
                            ),
                            child: Text('Submit',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
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

class _RiskFactor {
  final String questionEnglish;
  final String questionMalayalam;
  final String category;
  const _RiskFactor({
    required this.questionEnglish,
    required this.questionMalayalam,
    required this.category,
  });
}
