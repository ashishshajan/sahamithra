import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/pdf/assessment_pdf_document.dart';
import '../core/utils/open_local_pdf.dart';
import '../core/storage/assessment_pdf_storage.dart';
import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/language_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/gradient_header.dart';
import '../widgets/standard_footer.dart';

class DetailedReportScreen extends StatelessWidget {
  const DetailedReportScreen({
    super.key,
    this.childName = '',
    this.childId,
    this.totalScore = 0,
    this.percentage = 0,
    this.assessmentTag = '',
    this.assessmentMessage = '',
    this.isRedZone = false,
    this.recommendations = const [],
    this.assessmentDetails = const [],
  });

  final String childName;
  final int? childId;
  final int totalScore;
  final double percentage;
  final String assessmentTag;
  final String assessmentMessage;
  final bool isRedZone;
  final List<ReportRecommendation> recommendations;
  final List<ReportDetail> assessmentDetails;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailedReportController>(
      init: DetailedReportController.fromScreen(this),
      global: false,
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          body: Column(
            children: [
              GradientHeader(
                showLogo: false,
                title: controller.displayName,
                subtitle: controller.headerSubtitle,
                trailing: controller.initials.isEmpty
                    ? null
                    : Container(
                        width: 34.r,
                        height: 34.r,
                        decoration: const BoxDecoration(
                          color: AppColors.white20,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          controller.initials,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
              ),
              Expanded(
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 18.h),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate.fixed([
                          _ScoreCard(
                            totalScore: controller.totalScore,
                            percentage: controller.percentage,
                            assessmentTag: controller.assessmentTag,
                            assessmentMessage: controller.assessmentMessage,
                            accent: controller.zoneAccent,
                            surface: controller.zoneSurface,
                          ),
                          if (controller.isLoading) ...[
                            SizedBox(height: 18.h),
                            const _LoadingIndicator(
                                label: 'Loading detailed report...'),
                          ],
                          if (controller.recommendations.isNotEmpty) ...[
                            SizedBox(height: 18.h),
                            const _SectionTitle(
                                title: 'Recommended Next Steps'),
                            SizedBox(height: 10.h),
                            ...controller.recommendations.map(
                              (item) => Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: _RecommendationTile(item: item),
                              ),
                            ),
                          ],
                          if (controller.assessmentDetails.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            const _SectionTitle(title: 'Assessment Details'),
                            SizedBox(height: 10.h),
                            ...controller.assessmentDetails.map(
                              (detail) => Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: _AssessmentDetailTile(detail: detail),
                              ),
                            ),
                          ],
                          SizedBox(height: 18.h),
                          _GradientActionButton(
                            label: 'Download PDF Report',
                            icon: Icons.download_rounded,
                            onTap: controller.downloadPdfReport,
                          ),
                          SizedBox(height: 10.h),
                          OutlinedButton(
                            onPressed: () {
                              if (controller.isRedZone &&
                                  GlobalUtils().isGuestUser) {
                                controller.showRedZoneAlert();
                              } else {
                                Get.until((route) => route.isFirst);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50.h),
                              side: const BorderSide(color: AppColors.purple100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.xl),
                              ),
                            ),
                            child: Text(
                              'Return to Dashboard',
                              style: TextStyle(
                                color: AppColors.purple600,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              const StandardFooter(),
            ],
          ),
        );
      },
    );
  }
}

class DetailedReportController extends GetxController {
  DetailedReportController({
    required this.childName,
    required this.childId,
    required this.totalScore,
    required this.percentage,
    required this.assessmentTag,
    required this.assessmentMessage,
    required this.recommendations,
    required this.assessmentDetails,
    required this.isRedZone,
    this.zoneColor = '',
  });

  factory DetailedReportController.fromScreen(DetailedReportScreen screen) {
    return DetailedReportController(
      childName: screen.childName.trim(),
      childId: screen.childId,
      totalScore: screen.totalScore,
      percentage: screen.percentage,
      assessmentTag: screen.assessmentTag,
      assessmentMessage: screen.assessmentMessage,
      recommendations: List<ReportRecommendation>.from(screen.recommendations),
      assessmentDetails: List<ReportDetail>.from(screen.assessmentDetails),
      isRedZone: screen.isRedZone,
      zoneColor: screen.isRedZone ? 'red' : '',
    );
  }

  String childName;
  final int? childId;
  int totalScore;
  double percentage;
  String assessmentTag;
  String assessmentMessage;
  String zoneColor;
  List<ReportRecommendation> recommendations;
  List<ReportDetail> assessmentDetails;
  bool isLoading = false;
  bool isRedZone;
  int? age;
  String? ageGroup;

  /// Primary accent color derived from the API `color` field.
  /// Falls back to red so the screen still reads as an alert when missing.
  Color get zoneAccent {
    switch (zoneColor.toLowerCase().trim()) {
      case 'green':
        return AppColors.success;
      case 'yellow':
      case 'amber':
        return AppColors.warning;
      case 'orange':
        return AppColors.orange600;
      case 'red':
      default:
        return AppColors.error;
    }
  }

  Color get zoneSurface => zoneAccent.withOpacity(0.12);

  @override
  void onInit() {
    super.onInit();
    if (childId != null && childId! > 0) {
      fetchDetailedReport();
    }
  }

  Future<void> fetchDetailedReport() async {
    isLoading = true;
    update();

    final response =
        await NetworkHelper().getDetailedAssessmentReport(childId: childId!);

    if (response['success'] == true) {
      // `NetworkHelper._handleResponse` wraps the full JSON body under
      // `data`, so for envelopes shaped like `{success, data: {...}}`
      // we need to peel off the outer layer to reach the actual record.
      final body = response['data'];
      final unwrapped = (body is Map && body['data'] is Map)
          ? body['data'] as Map
          : (body is Map ? body : const {});
      final data = Map<String, dynamic>.from(unwrapped);

      childName = (data['child_name'] ?? childName).toString();
      age = _asIntOrNull(data['age']);
      ageGroup = data['age_group']?.toString();
      totalScore = _asInt(data['total_score'], totalScore);
      percentage = _asDouble(data['percentage'], percentage);

      final zoneMap = data['zone'] is Map
          ? Map<String, dynamic>.from(data['zone'] as Map)
          : <String, dynamic>{};

      assessmentTag =
          (zoneMap['label'] ?? data['color'] ?? assessmentTag).toString();
      assessmentMessage = (zoneMap['description'] ??
              data['message'] ??
              assessmentMessage)
          .toString();

      final zoneColorRaw =
          zoneMap['color'] ?? zoneMap['zone_color'] ?? data['color'];
      final zoneColorStr = zoneColorRaw?.toString().trim();
      if (zoneColorStr != null && zoneColorStr.isNotEmpty) {
        zoneColor = zoneColorStr;
        isRedZone = zoneColorStr.toLowerCase() == 'red';
      }

      // Prefer the new top-level `recommended_steps` payload (list of
      // `{title, description}` objects). Fall back to the legacy
      // `zone.instructions` (list of strings) for backwards compatibility.
      final recommendedStepsRaw = data['recommended_steps'];
      if (recommendedStepsRaw is List && recommendedStepsRaw.isNotEmpty) {
        recommendations = recommendedStepsRaw
            .map((entry) {
              if (entry is Map) {
                final step = Map<String, dynamic>.from(entry);
                return ReportRecommendation(
                  title: (step['title'] ?? '').toString(),
                  subtitle: (step['description'] ?? '').toString(),
                  icon: Icons.medical_information_rounded,
                );
              }
              return ReportRecommendation(
                title: entry.toString(),
                subtitle: '',
                icon: Icons.medical_information_rounded,
              );
            })
            .where((rec) => rec.title.trim().isNotEmpty)
            .toList();
      } else {
        final instructions = zoneMap['instructions'] is List
            ? List<dynamic>.from(zoneMap['instructions'] as List)
            : <dynamic>[];
        if (instructions.isNotEmpty) {
          recommendations = instructions
              .map((e) => ReportRecommendation(
                    title: e.toString(),
                    subtitle: '',
                    icon: Icons.medical_information_rounded,
                  ))
              .toList();
        }
      }

      final breakdownRaw = data['category_breakdown'];
      if (breakdownRaw is List && breakdownRaw.isNotEmpty) {
        assessmentDetails = breakdownRaw
            .whereType<Map>()
            .map(
              (e) {
                final item = Map<String, dynamic>.from(e);
                final correct = _asInt(item['correct_answers'], 0);
                final total = _asInt(item['total_questions'], 0);
                final pct = _asDouble(item['percentage'], 0);
                return ReportDetail(
                  title: item['category']?.toString() ?? 'Category',
                  given: '$correct',
                  expected: '$total',
                  percent: pct,
                  isCorrect: total > 0 && pct >= 60,
                );
              },
            )
            .toList();
      }
    } else {
      Get.snackbar(
        'Failed',
        (response['message'] ?? 'Unable to load detailed report').toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }

    isLoading = false;
    update();
  }

  Future<void> downloadPdfReport() async {
    final effectiveChildId = childId;
    if (effectiveChildId == null || effectiveChildId <= 0) {
      Get.snackbar(
        'Unavailable',
        'Child id not found. Please select a child and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final lang = LanguageProvider.to;
    Get.snackbar(
      lang.t('pdfPreparingTitle'),
      lang.t('pdfPreparingBody'),
      snackPosition: SnackPosition.BOTTOM,
    );

    final response =
        await NetworkHelper().getAssessmentDataForPdf(childId: effectiveChildId);
    if (response['success'] != true) {
      Get.snackbar(
        lang.t('snackbarInvalidReportTitle'),
        (response['message'] ?? lang.t('pdfFetchFailed')).toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final payloadRaw = response['data'];
    final payload = payloadRaw is Map<String, dynamic>
        ? payloadRaw
        : (payloadRaw is Map ? Map<String, dynamic>.from(payloadRaw) : null);
    if (payload == null) {
      Get.snackbar(
        lang.t('snackbarInvalidReportTitle'),
        lang.t('snackbarInvalidReportBody'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final test = payload['test'] is Map
          ? Map<String, dynamic>.from(payload['test'] as Map)
          : <String, dynamic>{};
      final zone = payload['zone'] is Map
          ? Map<String, dynamic>.from(payload['zone'] as Map)
          : <String, dynamic>{};
      final pdfZoneColor = (test['zone_color'] ?? zone['color'])
          ?.toString()
          .toLowerCase()
          .trim();
      if (pdfZoneColor != null && pdfZoneColor.isNotEmpty) {
        isRedZone = pdfZoneColor == 'red';
      }

      final pdfBytes = await buildAssessmentReportPdf(
        payload: payload,
        labels: AssessmentPdfLabels.fromLang(lang),
      );
      final file = await saveAssessmentReportPdfFile(
        bytes: pdfBytes,
        childId: effectiveChildId,
      );

      Get.snackbar(
        lang.t('snackbarPdfSavedTitle'),
        lang.t('snackbarPdfSavedBody').trParams({'path': file.path}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      await _promptOpenPdf(file);

      if (isRedZone && GlobalUtils().isGuestUser) {
        await showRedZoneAlert();
      }
    } catch (e) {
      Get.snackbar(
        LanguageProvider.to.t('snackbarInvalidReportTitle'),
        LanguageProvider.to
            .t('snackbarPdfGenerateFailed')
            .trParams({'error': '$e'}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> showRedZoneAlert() async {
    final lang = LanguageProvider.to;
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.r, 28.r, 24.r, 20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 36.sp,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                lang.t('redZoneAlertTitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                lang.t('redZoneAlertMessage'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    Get.offAllNamed(
                      AppRoutes.login,
                      arguments: {'initialTab': 'parent'},
                    );
                  },
                  icon: Icon(Icons.login_rounded,
                      size: 18.sp, color: Colors.white),
                  label: Text(
                    lang.t('goToParentLogin'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Get.back();
                    Get.until((route) => route.isFirst);
                  },
                  child: Text(
                    lang.t('cancel'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _promptOpenPdf(File file) async {
    final lang = LanguageProvider.to;
    await Get.dialog(
      AlertDialog(
        title: Text(lang.t('pdfDownloadedTitle')),
        content: Text(lang.t('pdfOpenNowPrompt')),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(lang.t('pdfNotNow')),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _openPdf(file);
            },
            child: Text(lang.t('pdfOpen')),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _openPdf(File file) async {
    final ok = await openPdfLocation(file);
    if (!ok) {
      Get.snackbar(
        LanguageProvider.to.t('snackbarPdfOpenFailedTitle'),
        LanguageProvider.to.t('snackbarPdfOpenFailedBody')
            .trParams({'path': file.parent.path}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  int? _asIntOrNull(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double _asDouble(dynamic value, double fallback) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  /// Title shown in the header. Falls back to a neutral label when no child
  /// name has been provided yet (e.g. while the API call is in flight).
  String get displayName =>
      childName.trim().isEmpty ? 'Detailed Report' : childName;

  String get initials {
    final parts = childName
        .split(' ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  String? get headerSubtitle {
    final hasGroup = ageGroup?.isNotEmpty ?? false;
    final hasAge = age != null && age! > 0;
    if (hasAge && hasGroup) return 'Age: $age | $ageGroup';
    if (hasGroup) return ageGroup;
    if (hasAge) return 'Age: $age';
    return null;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 15.sp,
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28.r,
            height: 28.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.purple600,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.totalScore,
    required this.percentage,
    required this.assessmentTag,
    required this.assessmentMessage,
    required this.accent,
    required this.surface,
  });

  final int totalScore;
  final double percentage;
  final String assessmentTag;
  final String assessmentMessage;
  final Color accent;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3.w, color: accent),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  child: Column(
                    children: [
                    if (assessmentTag.trim().isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        constraints: BoxConstraints(maxWidth: 220.w),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          assessmentTag,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accent,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    Container(
                      width: 138.r,
                      height: 138.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 7.w,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$totalScore',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'TOTAL SCORE',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 9.sp,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      '${percentage.toStringAsFixed(2)}% Percentage',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: accent,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (assessmentMessage.trim().isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        assessmentMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.sp,
                          height: 1.35,
                        ),
                      ),
                    ],
                    ],
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

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.item});

  final ReportRecommendation item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: const BoxDecoration(
              color: AppColors.purple50,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 17.sp, color: AppColors.purple600),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                if (item.subtitle.trim().isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentDetailTile extends StatelessWidget {
  const _AssessmentDetailTile({required this.detail});

  final ReportDetail detail;

  ({Color bg, Color fg, String label}) _pillTheme() {
    final pct = detail.percent;
    if (pct == null) {
      return detail.isCorrect
          ? (bg: AppColors.green100, fg: AppColors.green700, label: 'Correct')
          : (bg: AppColors.red50, fg: AppColors.red600, label: 'Incorrect');
    }
    final label = '${pct.toStringAsFixed(0)}%';
    if (pct >= 80) {
      return (bg: AppColors.green100, fg: AppColors.green700, label: label);
    }
    if (pct >= 50) {
      return (
        bg: AppColors.warning.withOpacity(0.15),
        fg: AppColors.orange600,
        label: label,
      );
    }
    return (bg: AppColors.red50, fg: AppColors.red600, label: label);
  }

  @override
  Widget build(BuildContext context) {
    final pill = _pillTheme();
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  detail.title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: pill.bg,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    pill.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: pill.fg,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 24.w,
            runSpacing: 8.h,
            children: [
              _ValueColumn(label: 'CORRECT', value: detail.given),
              _ValueColumn(label: 'TOTAL', value: detail.expected),
            ],
          ),
          if ((detail.note ?? '').isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              detail.note!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ValueColumn extends StatelessWidget {
  const _ValueColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 70.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 9.sp,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50.h),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
        icon: Icon(icon, color: Colors.white, size: 18.sp),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class ReportRecommendation {
  const ReportRecommendation({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class ReportDetail {
  const ReportDetail({
    required this.title,
    required this.given,
    required this.expected,
    required this.isCorrect,
    this.percent,
    this.note,
  });

  final String title;
  final String given;
  final String expected;
  final bool isCorrect;

  /// Percentage of correct answers in this category (0..100), if available.
  final double? percent;
  final String? note;
}
