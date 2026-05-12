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

/// Gradient ring + pulse — used while TDSC questions load from the API.
class _TdscLoadingView extends StatefulWidget {
  const _TdscLoadingView();

  @override
  State<_TdscLoadingView> createState() => _TdscLoadingViewState();
}

class _TdscLoadingViewState extends State<_TdscLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<Color> _ringColors = [
    Color(0xff9e1df4),
    Color(0xfff5339b),
    Color(0xff447eff),
    Color(0xff9e1df4),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final lang = LanguageProvider.to;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                return SizedBox(
                  width: 72.r,
                  height: 72.r,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: t * 6.2831853,
                        child: Container(
                          width: 72.r,
                          height: 72.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: _ringColors,
                              stops: const [0.0, 0.35, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 58.r,
                        height: 58.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.92 + (t * 0.08),
                        child: Icon(
                          Icons.psychology_rounded,
                          size: 28.sp,
                          color: AppColors.purple,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
            Text(
              lang.t('loading'),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'TDSC',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        );
      },
    );
  }
}

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
  final ScrollController _scrollController = ScrollController();

  bool _loadingRemoteQuestions = true;
  String? _remoteLoadError;
  List<_Domain> _domains = [];

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// [silent]: pull-to-refresh — keeps full-screen loader off; errors use SnackBar.
  Future<void> _loadQuestions({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _loadingRemoteQuestions = true;
        _remoteLoadError = null;
      });
    }

    final result =
        await NetworkHelper().fetchScalesQuestions(category: 'TDSC');
    if (!mounted) return;

    void applyFailure(String? message) {
      final msg = message ?? 'Could not load questions';
      setState(() {
        _loadingRemoteQuestions = false;
        if (silent) {
          _remoteLoadError = null;
        } else {
          _remoteLoadError = msg;
          _domains = [];
          _answers.clear();
          _currentDomain = 0;
        }
      });
      if (silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    }

    if (result['success'] != true) {
      applyFailure(result['message']?.toString());
      return;
    }

    final payload = result['data'];
    final dynamic listRaw =
        payload is Map ? payload['data'] : (payload is List ? payload : null);
    if (listRaw is! List) {
      applyFailure('Unexpected response from server');
      return;
    }

    final questions = listRaw
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

    if (questions.isEmpty) {
      applyFailure('No questions returned');
      return;
    }

    final lastQuestion = questions.last;
    print(
      'TDSC last question → id: ${lastQuestion.id}, '
      'english: ${lastQuestion.questionEnglish}, '
      'malayalam: ${lastQuestion.questionMalayalam}',
    );

    setState(() {
      _loadingRemoteQuestions = false;
      _remoteLoadError = null;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
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
    final utils = GlobalUtils();
    final childId =
        utils.isGuestScaleSession ? null : (utils.childId ?? 1);

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
        category: 'TDSC',
        scores: scores,
        childId: childId,
      );
      print('result $result');
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
    } catch (_) {
      // Ignore failures for now; still navigate to results.
    }

    if (!mounted) return;
    final zoneLabel = resultData?['zone_label']?.toString();
    final interpretation = (zoneLabel != null && zoneLabel.isNotEmpty)
        ? zoneLabel
        : (apiMessage?.isNotEmpty == true
            ? apiMessage!
            : LanguageProvider.to.t('resultsRecorded'));
    Get.toNamed(AppRoutes.results, arguments: {
      'type': 'TDSC',
      'answers': _answers,
      'score': scoreForResults,
      'interpretation': interpretation,
      'resultData': resultData,
      'child_report_id': resultData?['child_report_id'] ??
          resultData?['report_id'] ??
          resultData?['id'],
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
    if (_loadingRemoteQuestions) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            GradientHeader(
              onBack: () => Get.back(),
              title:
                  '${LanguageProvider.to.t('assessmentTypeTdsc')} ${LanguageProvider.to.t('assessmentGeneric')}',
              subtitle: LanguageProvider.to.t('tdscDescription'),
            ),
            Expanded(
              child: Center(child: _TdscLoadingView()),
            ),
          ],
        ),
      );
    }

    if (_remoteLoadError != null && _domains.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            GradientHeader(
              onBack: () => Get.back(),
              title:
                  '${LanguageProvider.to.t('assessmentTypeTdsc')} ${LanguageProvider.to.t('assessmentGeneric')}',
              subtitle: LanguageProvider.to.t('tdscDescription'),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _remoteLoadError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      TextButton(
                        onPressed: () => _loadQuestions(),
                        child: Obx(
                          () => Text(LanguageProvider.to.t('retry')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          GradientHeader(
            onBack: () => Get.back(),
            title:
                '${LanguageProvider.to.t('assessmentTypeTdsc')} ${LanguageProvider.to.t('assessmentGeneric')}',
            subtitle: LanguageProvider.to.t('tdscDescription'),
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
                    Obx(
                      () => Text(
                        LanguageProvider.to.t('overallProgress'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Obx(
                      () => Text(
                        LanguageProvider.to
                            .t('assessmentQuestionsProgress')
                            .replaceAll('@a', '${_answers.length}')
                            .replaceAll(
                              '@b',
                              '${_domains.fold(0, (s, d) => s + d.questions.length)}',
                            ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.purple,
                        ),
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
          // Container(
          //   color: Colors.white,
          //   height: 56.h,
          //   child: ListView.separated(
          //     scrollDirection: Axis.horizontal,
          //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          //     separatorBuilder: (_, __) => SizedBox(width: 8.w),
          //     itemCount: _domains.length,
          //     itemBuilder: (_, i) {
          //       final d = _domains[i];
          //       final active = i == _currentDomain;
          //       return GestureDetector(
          //         onTap: () => setState(() => _currentDomain = i),
          //         child: AnimatedContainer(
          //           duration: const Duration(milliseconds: 200),
          //           padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          //           decoration: BoxDecoration(
          //             color: active ? d.color : AppColors.neutral100,
          //             borderRadius: BorderRadius.circular(AppRadius.full),
          //           ),
          //           child: Row(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               Icon(d.icon,
          //                   size: 14.sp,
          //                   color: active ? Colors.white : AppColors.textTertiary),
          //               SizedBox(width: 4.w),
          //               Text(
          //                 d.name,
          //                 style: TextStyle(
          //                   fontSize: 12.sp,
          //                   fontWeight: FontWeight.w500,
          //                   color: active ? Colors.white : AppColors.textTertiary,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
          Container(height: 1, color: AppColors.neutral200),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.purple,
              onRefresh: () => _loadQuestions(silent: true),
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSpacing.base.r),
                children: [
                // Domain header card
                // Container(
                //   padding: EdgeInsets.all(AppSpacing.lg.r),
                //   decoration: BoxDecoration(
                //     color: currentDomain.bgColor,
                //     borderRadius: BorderRadius.circular(AppRadius.xl2),
                //     border: Border.all(
                //         color: currentDomain.color.withOpacity(0.3)),
                //   ),
                //   child: Row(
                //     children: [
                //       Container(
                //         width: 48.r,
                //         height: 48.r,
                //         decoration: BoxDecoration(
                //           color: currentDomain.color,
                //           shape: BoxShape.circle,
                //         ),
                //         child: Icon(currentDomain.icon,
                //             size: 24.sp, color: Colors.white),
                //       ),
                //       SizedBox(width: 12.w),
                //       Expanded(
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               currentDomain.name,
                //               style: TextStyle(
                //                 fontSize: 16.sp,
                //                 fontWeight: FontWeight.w700,
                //                 color: AppColors.textPrimary,
                //               ),
                //             ),
                //             Text(
                //               '$answeredInDomain of ${currentDomain.questions.length} answered',
                //               style: TextStyle(
                //                   fontSize: 12.sp,
                //                   color: AppColors.textSecondary),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
                      Obx(
                        () => Text(
                          _currentDomain < _domains.length - 1
                              ? LanguageProvider.to.t('tdscNextDomain')
                              : LanguageProvider.to.t('tdscViewResults'),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
                    child: Obx(
                      () => Text(
                        LanguageProvider.to
                            .t('assessmentAnswerAllQuestions'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
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
                    if (question.ageRange.isNotEmpty) ...[
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
