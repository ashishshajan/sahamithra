import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/network/network_helper.dart';
import '../core/global_utils.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_header.dart';
import '../widgets/standard_footer.dart';
import '../routes/app_routes.dart';

/// Mirrors /components/TDSCAssessment.tsx
/// Trivandrum Development Screening Chart — interactive multi-step assessment
class TDSCAssessmentScreen extends StatefulWidget {
  const TDSCAssessmentScreen({super.key});

  @override
  State<TDSCAssessmentScreen> createState() => _TDSCAssessmentScreenState();
}

class _TDSCAssessmentScreenState extends State<TDSCAssessmentScreen> {
  int _currentDomain = 0;
  final Map<String, bool?> _answers = {};

  List<_Domain> _domains = [
    _Domain(
      name: 'Gross Motor',
      icon: Icons.directions_run_rounded,
      color: AppColors.blue600,
      bgColor: AppColors.blue100,
      questions: [
        _Question('q1', 'Does the child hold their head up when placed on tummy?', '0-3 months'),
        _Question('q2', 'Can the child roll from back to side?', '4-6 months'),
        _Question('q3', 'Does the child sit independently without support?', '6-8 months'),
        _Question('q4', 'Can the child pull to stand using furniture?', '9-11 months'),
        _Question('q5', 'Does the child walk independently without support?', '12-15 months'),
        _Question('q6', 'Can the child run without falling frequently?', '18-24 months'),
      ],
    ),
    _Domain(
      name: 'Fine Motor',
      icon: Icons.pan_tool_rounded,
      color: AppColors.purple,
      bgColor: AppColors.purple100,
      questions: [
        _Question('fq1', 'Does the child hold a rattle placed in hand?', '2-3 months'),
        _Question('fq2', 'Can the child reach for objects voluntarily?', '4-5 months'),
        _Question('fq3', 'Does the child transfer objects hand to hand?', '6-7 months'),
        _Question('fq4', 'Can the child pick up small objects with pincer grasp?', '9-10 months'),
        _Question('fq5', 'Does the child scribble spontaneously with crayon?', '15-18 months'),
        _Question('fq6', 'Can the child copy a circle?', '3 years'),
      ],
    ),
    _Domain(
      name: 'Language',
      icon: Icons.record_voice_over_rounded,
      color: AppColors.green600,
      bgColor: AppColors.green100,
      questions: [
        _Question('lq1', 'Does the child coo and vocalize?', '2-3 months'),
        _Question('lq2', 'Does the child babble (da-da, ba-ba)?', '6-8 months'),
        _Question('lq3', 'Does the child say "mama" or "dada" meaningfully?', '10-12 months'),
        _Question('lq4', 'Does the child use 3-5 words meaningfully?', '12-15 months'),
        _Question('lq5', 'Can the child combine 2 words (e.g., "more milk")?', '18-24 months'),
        _Question('lq6', 'Can the child speak in short sentences?', '2-3 years'),
      ],
    ),
    _Domain(
      name: 'Social',
      icon: Icons.people_rounded,
      color: AppColors.pink600,
      bgColor: AppColors.pink100,
      questions: [
        _Question('sq1', 'Does the child smile responsively at caregiver?', '2-3 months'),
        _Question('sq2', 'Does the child show stranger anxiety?', '6-9 months'),
        _Question('sq3', 'Does the child wave bye-bye?', '9-12 months'),
        _Question('sq4', 'Does the child play peek-a-boo?', '9-12 months'),
        _Question('sq5', 'Does the child engage in parallel play with other children?', '2 years'),
        _Question('sq6', 'Can the child share toys and take turns?', '3-4 years'),
      ],
    ),
  ];

  _Domain get currentDomain => _domains[_currentDomain];

  int get answeredInDomain =>
      currentDomain.questions.where((q) => _answers.containsKey(q.id)).length;

  double get overallProgress {
    final total = _domains.fold(0, (s, d) => s + d.questions.length);
    final answered = _answers.length;
    return total > 0 ? answered / total : 0.0;
  }

  bool get allCurrentDomainAnswered =>
      currentDomain.questions.every((q) => _answers.containsKey(q.id));

  void _answer(String id, bool value) {
    setState(() => _answers[id] = value);
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final result = await NetworkHelper().fetchScalesQuestions(category: 'TDSC');
    if (!mounted) return;

    if (result['success'] != true) return;

    final payload = result['data'];
    final questionsRaw = payload is Map ? payload['data'] : null;
    if (questionsRaw is! List) return;

    final questions = questionsRaw
        .whereType<Map>()
        .map((q) {
          final id = q['id']?.toString() ?? '';
          final englishText =
              (q['question_english'] ?? q['question_malayalam'] ?? '')
                  .toString();
          final malayalamText =
              (q['question_malayalam'] ?? q['question_english'] ?? englishText)
                  .toString();
          return _Question(id, englishText, '', malayalamText);
        })
        .where((q) => q.id.isNotEmpty)
        .toList();

    if (questions.isEmpty) return;

    setState(() {
      _answers.clear();
      _currentDomain = 0;
      _domains = [
        _Domain(
          name: 'TDSC',
          icon: Icons.directions_run_rounded,
          color: AppColors.blue600,
          bgColor: AppColors.blue100,
          questions: questions,
        ),
      ];
    });
  }

  void _nextDomain() {
    print('Result for tDCS ${{
      'type': 'TDSC',
      'answers': _answers,
      'score': _calculateScore(),
    }}');
    // return; 
    if (_currentDomain < _domains.length - 1) {
      setState(() => _currentDomain++);
    } else {
      // Navigate to results

    

      _submitAssessmentAndGoToResults();
    }
  }

  Future<void> _submitAssessmentAndGoToResults() async {
    final childId = GlobalUtils().childId ?? 1; // dummy fallback

    // Convert `_answers` to API format:
    // [{ "scale_id": <int>, "score": 1 }, ...]
    final scores = _answers.entries
        .map((e) {
          // IDs can be numeric (e.g. "1") or prefixed (e.g. "q1") depending
          // on how questions are provided by the backend.
          final direct = int.tryParse(e.key);
          final match = RegExp(r'\d+').firstMatch(e.key);
          final parsedFromPrefix = match != null ? int.tryParse(match.group(0)!) : null;
          final scaleId = direct ?? parsedFromPrefix;
          if (scaleId == null) return null;
          return <String, dynamic>{
            'scale_id': scaleId,
            // Per your example, always snd `score: 1` for each scale id.
            'score': e.value == true ? 1 : 0,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();

    Map<String, dynamic>? resultData;
    String? apiMessage;
    double scoreForResults = _calculateScore()['percentage'] as double;

    try {
      final result = await NetworkHelper().storeAssessment(
        childId: childId,
        scores: scores,
        category: 'TDSC',
      );
      print('result $result');
      if (result['data'] is Map) {
        resultData = (result['data'] as Map).cast<String, dynamic>();
      }
      apiMessage = result['message']?.toString();

      final apiPercentage = resultData?['percentage'];
      if (apiPercentage is num) {
        scoreForResults = apiPercentage.toDouble();
      } else if (apiPercentage is String) {
        scoreForResults = double.tryParse(apiPercentage) ?? scoreForResults;
      }
    } catch (_) {
      // Ignore failures for now; still navigate to results.
    }

    if (!mounted) return;
    Get.toNamed(AppRoutes.results, arguments: {
      'type': 'TDSC',
      'answers': _answers,
      'score': scoreForResults,
      'interpretation': apiMessage ?? 'Results have been recorded.',
      'resultData': resultData,

    });
  }

  Map<String, dynamic> _calculateScore() {
    int yesCount = _answers.values.where((v) => v == true).length;
    int total = _answers.length;
    double percentage = total > 0 ? (yesCount / total) * 100 : 0;
    return {
      'yes': yesCount,
      'no': total - yesCount,
      'total': total,
      'percentage': percentage,
      'status': percentage >= 75 ? 'Normal' : 'Needs Attention',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          GradientHeader(
            onBack: () => Get.back(),
            title: 'TDSC Assessment',
            subtitle: 'Trivandrum Development Screening Chart',
          ),

          // Progress bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${(_answers.length)} / ${_domains.fold(0, (s, d) => s + d.questions.length)} questions',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.purple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: overallProgress,
                    minHeight: 8.h,
                    backgroundColor: AppColors.neutral100,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.purple),
                  ),
                ),
              ],
            ),
          ),

          // Domain tabs
          Container(
            color: Colors.white,
            height: 56.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemCount: _domains.length,
              itemBuilder: (_, i) {
                final d = _domains[i];
                final active = i == _currentDomain;
                return GestureDetector(
                  onTap: () => setState(() => _currentDomain = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: active ? d.color : AppColors.neutral100,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(d.icon,
                            size: 14.sp,
                            color: active ? Colors.white : AppColors.textTertiary),
                        SizedBox(width: 4.w),
                        Text(
                          d.name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: active ? Colors.white : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(height: 1, color: AppColors.neutral200),

          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.base.r),
              children: [
                // Domain header card
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg.r),
                  decoration: BoxDecoration(
                    color: currentDomain.bgColor,
                    borderRadius: BorderRadius.circular(AppRadius.xl2),
                    border: Border.all(
                        color: currentDomain.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                          color: currentDomain.color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(currentDomain.icon,
                            size: 24.sp, color: Colors.white),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentDomain.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '$answeredInDomain of ${currentDomain.questions.length} answered',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.base.h),

                ...currentDomain.questions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final q = entry.value;
                  final answer = _answers[q.id];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _QuestionCard(
                      index: i + 1,
                      question: q,
                      answer: answer,
                      domainColor: currentDomain.color,
                      onAnswer: (val) => _answer(q.id, val),
                    ),
                  );
                }),

                SizedBox(height: AppSpacing.base.h),

                GradientButton(
                  onPressed: allCurrentDomainAnswered ? _nextDomain : null,
                  height: 56.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentDomain < _domains.length - 1
                            ? 'Next Domain'
                            : 'View Results',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        _currentDomain < _domains.length - 1
                            ? Icons.arrow_forward_rounded
                            : Icons.bar_chart_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.base.h),

                if (!allCurrentDomainAnswered)
                  Center(
                    child: Text(
                      'Please answer all questions to continue',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
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

class _Domain {
  final String name;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final List<_Question> questions;
  _Domain({
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.questions,
  });
}

class _Question {
  final String id;
  final String questionEnglish;
  final String questionMalayalam;
  final String ageRange;

  _Question(
    this.id,
    String questionEnglish,
    this.ageRange, [
    String? questionMalayalam,
  ])  : questionEnglish = questionEnglish,
        questionMalayalam = questionMalayalam ?? questionEnglish;
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.question,
    required this.answer,
    required this.domainColor,
    required this.onAnswer,
  });

  final int index;
  final _Question question;
  final bool? answer;
  final Color domainColor;
  final ValueChanged<bool> onAnswer;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(
          color: answer == null
              ? AppColors.neutral200
              : answer!
                  ? AppColors.success.withOpacity(0.4)
                  : AppColors.error.withOpacity(0.4),
          width: answer == null ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: answer == null
                      ? AppColors.neutral100
                      : answer!
                          ? AppColors.success.withOpacity(0.15)
                          : AppColors.error.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: answer == null
                          ? AppColors.textTertiary
                          : answer!
                              ? AppColors.success
                              : AppColors.error,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        LanguageProvider.to.isEnglish
                            ? question.questionEnglish
                            : question.questionMalayalam,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: domainColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        question.ageRange,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: domainColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onAnswer(true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: answer == true
                          ? AppColors.success
                          : AppColors.success.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: answer == true
                            ? AppColors.success
                            : AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18.sp,
                          color: answer == true
                              ? Colors.white
                              : AppColors.success,
                        ),
                        SizedBox(width: 6.w),
                        Obx(
                          () => Text(
                            LanguageProvider.to.t('yes'),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: answer == true
                                  ? Colors.white
                                  : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => onAnswer(false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: answer == false
                          ? AppColors.error
                          : AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: answer == false
                            ? AppColors.error
                            : AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cancel_rounded,
                          size: 18.sp,
                          color: answer == false
                              ? Colors.white
                              : AppColors.error,
                        ),
                        SizedBox(width: 6.w),
                        Obx(
                          () => Text(
                            LanguageProvider.to.t('no'),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: answer == false
                                  ? Colors.white
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      ],
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
