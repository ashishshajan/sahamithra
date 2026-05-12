import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/network/network_helper.dart';
import '../core/global_utils.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/language_switcher.dart';
import '../widgets/standard_footer.dart';
import '../routes/app_routes.dart';

/// Mirrors /components/ParentalStressScreen.tsx
/// PSI-SF — Parenting Stress Index, Short Form (5-point Likert scale)
class ParentalStressScreen extends StatefulWidget {
  const ParentalStressScreen({super.key});

  @override
  State<ParentalStressScreen> createState() => _ParentalStressScreenState();
}

class _ParentalStressScreenState extends State<ParentalStressScreen> {
  /// POST `/child-scale-scores` category (matches scales fetch).
  static const String _scaleCategory = 'PARENTAL_STRESS';

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

  List<_StressQuestion> _questions = [];
  bool _loadingQuestions = true;
  String? _remoteLoadError;

  static List<_StressQuestion> _offlineStressFallback() => _fallbackQuestions
      .map((q) => _StressQuestion(
            questionEnglish: q,
            questionMalayalam: q,
          ))
      .toList();

  static int? _scaleIdFromPayload(dynamic raw) {
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

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

  Future<void> _complete() async {
    final lang = LanguageProvider.to;
    if (_questions.isEmpty) {
      Get.toNamed(AppRoutes.results, arguments: {
        'type': _scaleCategory,
        'answers': _answers,
        'score': 0.0,
        'interpretation': lang.t('stressNoQuestionsMsg'),
      });
      return;
    }

    final utils = GlobalUtils();
    final childId =
        utils.isGuestScaleSession ? null : (utils.childId ?? 1);

    final scores = <Map<String, dynamic>>[];
    for (var i = 0; i < _questions.length; i++) {
      final v = _answers[i];
      if (v == null) continue;
      final scaleId = _questions[i].scaleId ?? (i + 1);
      scores.add({'scale_id': scaleId, 'score': v});
    }

    Map<String, dynamic>? resultData;
    String? apiMessage;
    final total = _answers.values.fold(0, (s, v) => s + v);
    final max = _questions.length * 5;
    double scoreForResults = max > 0 ? (total / max) * 100 : 0.0;

    String localInterpretation;
    if (scoreForResults <= 40) {
      localInterpretation = lang.t('stressInterpLow');
    } else if (scoreForResults <= 60) {
      localInterpretation = lang.t('stressInterpModerate');
    } else {
      localInterpretation = lang.t('stressInterpHigh');
    }

    try {
      final result = await NetworkHelper().storeAssessment(
        category: _scaleCategory,
        scores: scores,
        childId: childId,
      );
      final root = result['data'];
      if (root is Map) {
        final rootMap = Map<String, dynamic>.from(root);
        apiMessage = rootMap['message']?.toString();
        final inner = rootMap['data'];
        if (inner is Map) {
          resultData = Map<String, dynamic>.from(inner);
        }
      }

      final apiPercentage = resultData?['percentage'];
      if (apiPercentage is num) {
        scoreForResults = apiPercentage.toDouble();
      } else if (apiPercentage is String) {
        scoreForResults = double.tryParse(apiPercentage) ?? scoreForResults;
      }
    } catch (_) {}

    if (!mounted) return;

    final zoneLabel = resultData?['zone_label']?.toString();
    final interpretation = (zoneLabel != null && zoneLabel.isNotEmpty)
        ? zoneLabel
        : (apiMessage?.isNotEmpty == true
            ? apiMessage!
            : localInterpretation);

    Get.toNamed(AppRoutes.results, arguments: {
      'type': _scaleCategory,
      'answers': _answers,
      'score': scoreForResults,
      'interpretation': interpretation,
      'resultData': resultData,
      'child_report_id': resultData?['child_report_id'] ??
          resultData?['report_id'] ??
          resultData?['id'],
    });
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final isGuest = GlobalUtils().isGuestScaleSession;
    final result =
        await NetworkHelper().fetchScalesQuestions(category: 'PARENTAL_STRESS');
    if (!mounted) return;

    if (result['success'] != true) {
      final message = result['message']?.toString() ?? 'Could not load questions';
      final noScalesFound = message.toLowerCase().contains('no scales found');
      setState(() {
        _loadingQuestions = false;
        _remoteLoadError = message;
        _questions =
            (isGuest || noScalesFound) ? [] : _offlineStressFallback();
        _answers.clear();
        _current = 0;
      });
      return;
    }

    final payload = result['data'];
    final dynamic listRaw =
        payload is Map ? payload['data'] : (payload is List ? payload : null);
    if (listRaw is! List) {
      setState(() {
        _loadingQuestions = false;
        _remoteLoadError = isGuest ? 'Unexpected response from server' : null;
        _questions = isGuest ? [] : _offlineStressFallback();
        _answers.clear();
        _current = 0;
      });
      return;
    }

    final fetched = listRaw
        .whereType<Map>()
        .map((q) {
          final english =
              (q['question_english'] ?? q['question_malayalam'] ?? '').toString();
          final malayalam =
              (q['question_malayalam'] ?? q['question_english'] ?? english).toString();
          return _StressQuestion(
            questionEnglish: english,
            questionMalayalam: malayalam,
            scaleId: _scaleIdFromPayload(q['id']),
          );
        })
        .where((s) =>
            s.questionEnglish.isNotEmpty || s.questionMalayalam.isNotEmpty)
        .toList();

    if (fetched.isEmpty) {
      setState(() {
        _loadingQuestions = false;
        _remoteLoadError = isGuest ? 'No questions returned' : null;
        _questions = isGuest ? [] : _offlineStressFallback();
        _answers.clear();
        _current = 0;
      });
      return;
    }

    setState(() {
      _loadingQuestions = false;
      _remoteLoadError = null;
      _answers.clear();
      _current = 0;
      _questions = fetched;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingQuestions) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
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
                              'Parental Stress Scale',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const LanguageSwitcher(),
                        ],
                      ),
                      SizedBox(height: 14.h),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _remoteLoadError ??
                            LanguageProvider.to.t('stressNoQuestionsMsg'),
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 16.h),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _loadingQuestions = true;
                            _remoteLoadError = null;
                          });
                          _loadQuestions();
                        },
                        child: Obx(
                          () => Text(LanguageProvider.to.t('retry')),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Obx(
                          () => Text(LanguageProvider.to.t('back')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const StandardFooter(),
          ],
        ),
      );
    }

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
                        Expanded(
                          child: Obx(
                            () => Text(
                              LanguageProvider.to
                                  .t('parentalStressScale'),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const LanguageSwitcher(),
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
                    Obx(
                      () => Text(
                        '${LanguageProvider.to.t('questionLabel')} ${_current + 1} ${LanguageProvider.to.t('questionOf')} ${_questions.length}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
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
                        Obx(
                          () => Text(
                            LanguageProvider.to.t('stressRateAgreement'),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
                            child: Obx(
                              () => Text(
                                LanguageProvider.to.t('previous'),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                      if (isLast && answered)
                        Expanded(
                          child: GradientButton(
                            onPressed: _complete,
                            height: 50.h,
                            child: Obx(
                              () => Text(
                                LanguageProvider.to
                                    .t('completeAssessment'),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
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
    this.scaleId,
  });

  final String questionEnglish;
  final String questionMalayalam;
  final int? scaleId;
}

class _Option {
  final int value;
  final String label;
  const _Option(this.value, this.label);
}
