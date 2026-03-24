import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/network/network_helper.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_header.dart';
import '../widgets/standard_footer.dart';
import '../routes/app_routes.dart';

/// Mirrors /components/LESTAssessment.tsx
/// Language Evaluation Scale Trivandrum — bilingual language assessment
class LESTAssessmentScreen extends StatefulWidget {
  const LESTAssessmentScreen({super.key});

  @override
  State<LESTAssessmentScreen> createState() => _LESTAssessmentScreenState();
}

class _LESTAssessmentScreenState extends State<LESTAssessmentScreen> {
  int _currentSection = 0;
  final Map<String, bool?> _answers = {};

  bool _isLoading = false;
  String? _error;

  List<_Section> _sections = [
    _Section(
      name: 'Pre-Linguistic',
      subtitle: '0–12 months',
      icon: Icons.child_care_rounded,
      color: AppColors.cyan600,
      bgColor: AppColors.cyan100,
      questions: [
        _LQuestion('pl1', 'Does the child respond to sound by startling or blinking?', '0-3 months'),
        _LQuestion('pl2', 'Does the child vocalize sounds other than crying?', '2-4 months'),
        _LQuestion('pl3', 'Does the child turn towards a voice or sound?', '4-6 months'),
        _LQuestion('pl4', 'Does the child babble with consonant-vowel combinations?', '6-9 months'),
        _LQuestion('pl5', 'Does the child understand simple words like "no" or their name?', '9-12 months'),
      ],
    ),
    _Section(
      name: 'Receptive Language',
      subtitle: 'Understanding',
      icon: Icons.hearing_rounded,
      color: AppColors.blue600,
      bgColor: AppColors.blue100,
      questions: [
        _LQuestion('rl1', 'Does the child follow simple one-step instructions?', '12-15 months'),
        _LQuestion('rl2', 'Can the child point to body parts when asked?', '15-18 months'),
        _LQuestion('rl3', 'Does the child understand "give me" and "show me"?', '18-21 months'),
        _LQuestion('rl4', 'Can the child identify common objects by name?', '18-24 months'),
        _LQuestion('rl5', 'Does the child follow two-step directions?', '2-2.5 years'),
        _LQuestion('rl6', 'Can the child understand concepts like big/small, in/out?', '2.5-3 years'),
      ],
    ),
    _Section(
      name: 'Expressive Language',
      subtitle: 'Speaking',
      icon: Icons.record_voice_over_rounded,
      color: AppColors.green600,
      bgColor: AppColors.green100,
      questions: [
        _LQuestion('el1', 'Does the child use at least 3 words meaningfully?', '12-15 months'),
        _LQuestion('el2', 'Does the child use 10+ words consistently?', '15-18 months'),
        _LQuestion('el3', 'Does the child combine 2 words (e.g., "more juice")?', '18-24 months'),
        _LQuestion('el4', 'Can the child name familiar pictures in a book?', '18-24 months'),
        _LQuestion('el5', 'Does the child use pronouns like "I" and "me"?', '2-2.5 years'),
        _LQuestion('el6', 'Can the child tell a simple story or describe events?', '3-4 years'),
      ],
    ),
    _Section(
      name: 'Pragmatics',
      subtitle: 'Social Communication',
      icon: Icons.forum_rounded,
      color: AppColors.purple,
      bgColor: AppColors.purple100,
      questions: [
        _LQuestion('pg1', 'Does the child make eye contact during communication?', '0-12 months'),
        _LQuestion('pg2', 'Does the child use gestures like pointing or waving?', '9-12 months'),
        _LQuestion('pg3', 'Does the child initiate communication with others?', '12-18 months'),
        _LQuestion('pg4', 'Can the child take turns in conversation?', '2-3 years'),
        _LQuestion('pg5', 'Does the child understand humor or simple jokes?', '3-4 years'),
      ],
    ),
  ];

  _Section get current => _sections[_currentSection];

  int get answeredInSection =>
      current.questions.where((q) => _answers.containsKey(q.id)).length;

  double get overallProgress {
    final total = _sections.fold(0, (s, d) => s + d.questions.length);
    return total > 0 ? _answers.length / total : 0;
  }

  bool get allAnswered =>
      current.questions.every((q) => _answers.containsKey(q.id));

  void _next() {
    if (_currentSection < _sections.length - 1) {
      setState(() => _currentSection++);
    } else {
      Get.toNamed(AppRoutes.results, arguments: {
        'type': 'LEST',
        'answers': _answers,
        'score': _calcScore(),
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await NetworkHelper().fetchScalesQuestions(category: 'LEST');
    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _isLoading = false;
        _error = result['message'] ?? 'Failed to load questions';
      });
      return;
    }

    final payload = result['data'];
    final questionsRaw = payload is Map ? payload['data'] : null;
    if (questionsRaw is! List) {
      setState(() {
        _isLoading = false;
        _error = 'Unexpected response format';
      });
      return;
    }

    final questions = questionsRaw
        .whereType<Map>()
        .map((q) {
          final id = q['id']?.toString() ?? '';
          final englishText = (q['question_english'] ?? q['question_malayalam'] ?? '').toString();
          final malayalamText = (q['question_malayalam'] ?? q['question_english'] ?? englishText).toString();
          return _LQuestion(id, englishText, '', malayalamText);
        })
        .where((q) => q.id.isNotEmpty)
        .toList();

    if (questions.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _answers.clear();
      _currentSection = 0;
      _sections = [
        _Section(
          name: 'LEST',
          subtitle: '',
          icon: Icons.hearing_rounded,
          color: AppColors.blue600,
          bgColor: AppColors.blue100,
          questions: questions,
        ),
      ];
      _isLoading = false;
    });
  }

  Map<String, dynamic> _calcScore() {
    final yes = _answers.values.where((v) => v == true).length;
    final total = _answers.length;
    final pct = total > 0 ? (yes / total) * 100 : 0.0;
    return {
      'yes': yes,
      'no': total - yes,
      'total': total,
      'percentage': pct,
      'status': pct >= 70 ? 'Age Appropriate' : 'Language Support Recommended',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _sections.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          GradientHeader(
            onBack: () => Get.back(),
            title: 'LEST Assessment',
            subtitle: 'Language Evaluation Scale Trivandrum',
          ),

          // Progress
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Section ${_currentSection + 1} of ${_sections.length}',
                        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                    Text('${_answers.length} answered',
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.green600)),
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
                        const AlwaysStoppedAnimation(AppColors.green600),
                  ),
                ),
              ],
            ),
          ),

          // Section tabs
          Container(
            color: Colors.white,
            height: 52.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemCount: _sections.length,
              itemBuilder: (_, i) {
                final s = _sections[i];
                final active = i == _currentSection;
                final done = _sections[i].questions.every((q) => _answers.containsKey(q.id));
                return GestureDetector(
                  onTap: () => setState(() => _currentSection = i),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: active ? s.color : AppColors.neutral100,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (done && !active)
                          Icon(Icons.check_circle_rounded,
                              size: 14.sp, color: AppColors.success)
                        else
                          Icon(s.icon,
                              size: 14.sp,
                              color: active ? Colors.white : AppColors.textTertiary),
                        SizedBox(width: 4.w),
                        Text(
                          s.name,
                          style: TextStyle(
                            fontSize: 11.sp,
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
                // Section header
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg.r),
                  decoration: BoxDecoration(
                    color: current.bgColor,
                    borderRadius: BorderRadius.circular(AppRadius.xl2),
                    border: Border.all(color: current.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                            color: current.color, shape: BoxShape.circle),
                        child: Icon(current.icon, size: 24.sp, color: Colors.white),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(current.name,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          Text(current.subtitle,
                              style: TextStyle(
                                  fontSize: 12.sp, color: AppColors.textSecondary)),
                          Text('$answeredInSection/${current.questions.length} answered',
                              style: TextStyle(
                                  fontSize: 11.sp, color: AppColors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.base.h),

                ...current.questions.asMap().entries.map((e) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _LQuestionCard(
                        index: e.key + 1,
                        question: e.value,
                        answer: _answers[e.value.id],
                        sectionColor: current.color,
                        onAnswer: (val) =>
                            setState(() => _answers[e.value.id] = val),
                      ),
                    )),

                SizedBox(height: AppSpacing.base.h),

                GradientButton(
                  onPressed: allAnswered ? _next : null,
                  height: 56.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentSection < _sections.length - 1
                            ? 'Next Section'
                            : 'See Results',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        _currentSection < _sections.length - 1
                            ? Icons.arrow_forward_rounded
                            : Icons.bar_chart_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
                if (!allAnswered) ...[
                  SizedBox(height: 8.h),
                  Center(
                    child: Text('Please answer all questions to proceed',
                        style: TextStyle(
                            fontSize: 11.sp, color: AppColors.textTertiary)),
                  ),
                ],
                SizedBox(height: AppSpacing.base.h),
              ],
            ),
          ),
          const StandardFooter(),
        ],
      ),
    );
  }
}

class _Section {
  final String name, subtitle;
  final IconData icon;
  final Color color, bgColor;
  final List<_LQuestion> questions;
  _Section(
      {required this.name,
      required this.subtitle,
      required this.icon,
      required this.color,
      required this.bgColor,
      required this.questions});
}

class _LQuestion {
  final String id;
  final String questionEnglish;
  final String questionMalayalam;
  final String ageRange;

  // Backward-compatible constructor:
  // - Existing hardcoded questions pass (id, text, ageRange) where `text` is English.
  // - API-backed questions can pass (id, english, ageRange, malayalam).
  _LQuestion(
    this.id,
    String questionEnglish,
    this.ageRange, [
    String? questionMalayalam,
  ])  : questionEnglish = questionEnglish,
        questionMalayalam = questionMalayalam ?? questionEnglish;
}

class _LQuestionCard extends StatelessWidget {
  const _LQuestionCard({
    required this.index,
    required this.question,
    required this.answer,
    required this.sectionColor,
    required this.onAnswer,
  });

  final int index;
  final _LQuestion question;
  final bool? answer;
  final Color sectionColor;
  final ValueChanged<bool> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(
          color: answer == null
              ? AppColors.neutral200
              : answer!
                  ? AppColors.success.withOpacity(0.5)
                  : AppColors.error.withOpacity(0.5),
          width: answer == null ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: sectionColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('$index',
                      style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: sectionColor)),
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
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(question.ageRange,
                        style: TextStyle(
                            fontSize: 10.sp, color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _AnswerBtn(
                  labelKey: 'yes',
                  icon: Icons.check_circle_rounded,
                  selected: answer == true,
                  activeColor: AppColors.success,
                  onTap: () => onAnswer(true)),
              SizedBox(width: 8.w),
              _AnswerBtn(
                  labelKey: 'no',
                  icon: Icons.cancel_rounded,
                  selected: answer == false,
                  activeColor: AppColors.error,
                  onTap: () => onAnswer(false)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerBtn extends StatelessWidget {
  const _AnswerBtn({
    required this.labelKey,
    required this.icon,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  final String labelKey;
  final IconData icon;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 42.h,
          decoration: BoxDecoration(
            color: selected ? activeColor : activeColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
                color: selected
                    ? activeColor
                    : activeColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16.sp,
                  color: selected ? Colors.white : activeColor),
              SizedBox(width: 6.w),
              Obx(
                () => Text(
                  LanguageProvider.to.t(labelKey),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : activeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
