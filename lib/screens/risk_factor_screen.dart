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

/// Mirrors /components/RiskFactorScreen.tsx
class RiskFactorScreen extends StatefulWidget {
  const RiskFactorScreen({super.key});

  @override
  State<RiskFactorScreen> createState() => _RiskFactorScreenState();
}

class _RiskFactorScreenState extends State<RiskFactorScreen> {
  /// POST `/child-scale-scores` category (matches scales fetch).
  static const String _scaleCategory = 'RISK_FACTOR';

  int _current = 0;
  final Map<int, bool> _answers = {};

  static int? _scaleIdFromPayload(dynamic raw) {
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  static final List<_RiskFactor> _fallbackFactors = [
    _RiskFactor(
        questionL10nKey: 'riskFactorFallback1',
        categoryL10nKey: 'riskCatBirthHistory'),
    _RiskFactor(
        questionL10nKey: 'riskFactorFallback2',
        categoryL10nKey: 'riskCatBirthHistory'),
    _RiskFactor(
        questionL10nKey: 'riskFactorFallback3',
        categoryL10nKey: 'riskCatBirthHistory'),
    _RiskFactor(
        questionL10nKey: 'riskFactorFallback4',
        categoryL10nKey: 'riskCatFamilyHistory'),
    _RiskFactor(
        questionL10nKey: 'riskFactorFallback5',
        categoryL10nKey: 'riskCatMedicalHistory'),
    _RiskFactor(
        questionL10nKey: 'riskFactorFallback6',
        categoryL10nKey: 'riskCatMedicalHistory'),
    _RiskFactor(
        questionL10nKey: 'riskFactorFallback7',
        categoryL10nKey: 'riskCatSensory'),
    _RiskFactor(
        questionL10nKey: 'riskFactorFallback8',
        categoryL10nKey: 'riskCatMedicalHistory'),
    _RiskFactor(
        questionL10nKey: 'riskFactorFallback9',
        categoryL10nKey: 'riskCatEnvironmental'),
    _RiskFactor(
        questionL10nKey: 'riskFactorFallback10',
        categoryL10nKey: 'riskCatSocialEnvironmental'),
    _RiskFactor(
        questionL10nKey: 'riskFactorFallback11',
        categoryL10nKey: 'riskCatSocialEnvironmental'),
    _RiskFactor(
        questionL10nKey: 'riskFactorFallback12',
        categoryL10nKey: 'riskCatMedicalHistory'),
  ];

  List<_RiskFactor> _factors = [];
  bool _loadingQuestions = true;
  String? _remoteLoadError;

  double get _progress => _factors.isEmpty ? 0 : (_current + 1) / _factors.length;

  void _handleAnswer(bool value) {
    setState(() {
      _answers[_current] = value;
    });
  }

  void _goNext() {
    if (!_answers.containsKey(_current)) return;
    if (_current >= _factors.length - 1) return;
    setState(() => _current++);
  }

  Future<void> _complete() async {
    final lang = LanguageProvider.to;
    if (_factors.isEmpty) {
      Get.toNamed(AppRoutes.results, arguments: {
        'type': _scaleCategory,
        'answers': _answers,
        'score': 0.0,
        'interpretation': lang.t('riskInterpEmpty'),
        'riskCount': 0,
      });
      return;
    }

    final utils = GlobalUtils();
    final childId =
        utils.isGuestScaleSession ? null : (utils.childId ?? 1);

    final scores = <Map<String, dynamic>>[];
    for (var i = 0; i < _factors.length; i++) {
      final v = _answers[i];
      if (v == null) continue;
      final scaleId = _factors[i].scaleId ?? (i + 1);
      scores.add({'scale_id': scaleId, 'score': v ? 1 : 0});
    }

    Map<String, dynamic>? resultData;
    String? apiMessage;
    final riskCount = _answers.values.where((v) => v).length;
    double scoreForResults =
        _factors.isEmpty ? 0.0 : (riskCount / _factors.length) * 100;

    String localInterpretation;
    if (riskCount == 0) {
      localInterpretation = lang.t('riskInterpNoneIdentified');
    } else if (riskCount <= 2) {
      localInterpretation = lang.t('riskInterpLowBand');
    } else if (riskCount <= 4) {
      localInterpretation = lang.t('riskInterpModerateBand');
    } else if (riskCount <= 6) {
      localInterpretation = lang.t('riskInterpHighBand');
    } else {
      localInterpretation = lang.t('riskInterpVeryHighBand');
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
      'riskCount': riskCount,
      'resultData': resultData,
      'child_report_id': resultData?['child_report_id'] ??
          resultData?['report_id'] ??
          resultData?['id'],
    });
  }

  String _questionLine(_RiskFactor f, LanguageProvider lang) {
    if (f.questionL10nKey != null) return lang.t(f.questionL10nKey!);
    return lang.isEnglish ? f.questionEnglish : f.questionMalayalam;
  }

  String _categoryLine(_RiskFactor f, LanguageProvider lang) {
    if (f.categoryL10nKey != null) return lang.t(f.categoryL10nKey!);
    if (f.category == 'Risk') return lang.t('riskCategoryDefault');
    return f.category;
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final isGuest = GlobalUtils().isGuestScaleSession;
    final result =
        await NetworkHelper().fetchScalesQuestions(category: 'RISK_FACTOR');
    if (!mounted) return;

    if (result['success'] != true) {
      final message = result['message']?.toString() ?? 'Could not load questions';
      final noScalesFound = message.toLowerCase().contains('no scales found');
      setState(() {
        _loadingQuestions = false;
        _remoteLoadError = message;
        _factors = (isGuest || noScalesFound) ? [] : List.of(_fallbackFactors);
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
        _factors = isGuest ? [] : List.of(_fallbackFactors);
        _answers.clear();
        _current = 0;
      });
      return;
    }

    final fetched = listRaw
        .whereType<Map>()
        .map((q) {
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
            scaleId: _scaleIdFromPayload(q['id']),
          );
        })
        .whereType<_RiskFactor>()
        .toList();

    if (fetched.isEmpty) {
      setState(() {
        _loadingQuestions = false;
        _remoteLoadError = isGuest ? 'No questions returned' : null;
        _factors = isGuest ? [] : List.of(_fallbackFactors);
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
      _factors = fetched;
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

    if (_factors.isEmpty) {
      return Obx(() {
        final lang = LanguageProvider.to;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Column(
            children: [
              Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient),
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
                                lang.t('riskFactorChecklist'),
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
                          _remoteLoadError ?? 'No questions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14.sp, color: AppColors.textSecondary),
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
      });
    }

    final factor = _factors[_current];
    final answered = _answers.containsKey(_current);
    final isLast = _current == _factors.length - 1;

    return Obx(() {
      final lang = LanguageProvider.to;

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.primaryGradient),
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
                              lang.t('riskFactorChecklist'),
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
                        '${lang.t('questionLabel')} ${_current + 1} ${lang.t('questionOf')} ${_factors.length}',
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
                              Expanded(
                                child: Text(
                                  _categoryLine(factor, lang),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.orange600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            _questionLine(factor, lang),
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
                              borderRadius:
                                  BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Center(
                              child: Text(
                                isLast
                                    ? lang.t('riskFactorHintSubmit')
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
                              onPressed: () => setState(() => _current--),
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
                              child: Text(
                                lang.t('submit'),
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
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

class _RiskFactor {
  const _RiskFactor({
    this.questionEnglish = '',
    this.questionMalayalam = '',
    this.category = '',
    this.questionL10nKey,
    this.categoryL10nKey,
    this.scaleId,
  });

  final String questionEnglish;
  final String questionMalayalam;
  final String category;
  final String? questionL10nKey;
  final String? categoryL10nKey;
  final int? scaleId;
}
