import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/pdf/assessment_pdf_document.dart';
import '../core/utils/open_local_pdf.dart';
import '../core/storage/assessment_pdf_storage.dart';
import '../core/global_utils.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/network/network_helper.dart';
import '../providers/language_provider.dart';
import '../routes/app_routes.dart';
import '../screens/detailed_report_screen.dart';
import '../widgets/language_switcher.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/ResultsScreen.tsx
/// Displays results after any assessment (TDSC, LEST, Stress, Risk).
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  Future<void> _showRedZoneAlert(LanguageProvider lang) async {
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
                    Get.until((r) => r.isFirst);
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

  Future<void> _downloadPdfReport(
    Map<String, dynamic> args, {
    bool isRedZone = false,
  }) async {
    final resultDataRaw = args['resultData'];
    final resultData = resultDataRaw is Map<String, dynamic>
        ? resultDataRaw
        : (resultDataRaw is Map ? Map<String, dynamic>.from(resultDataRaw) : null);

    final childId = _asInt(
      args['child_id'] ??
          args['childId'] ??
          resultData?['child_id'] ??
          (resultData?['child'] is Map
              ? (resultData?['child'] as Map)['id']
              : null),
    );

    if (childId <= 0) {
      Get.snackbar(
        'Unavailable',
        'Child id not found. Please select a child and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      LanguageProvider.to.t('pdfPreparingTitle'),
      LanguageProvider.to.t('pdfPreparingBody'),
      snackPosition: SnackPosition.BOTTOM,
    );

    final response = await NetworkHelper().getAssessmentDataForPdf(
      childId: childId,
    );
    if (response['success'] != true) {
      Get.snackbar(
        LanguageProvider.to.t('snackbarInvalidReportTitle'),
        (response['message'] ??
                LanguageProvider.to.t('pdfFetchFailed'))
            .toString(),
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
        LanguageProvider.to.t('snackbarInvalidReportTitle'),
        LanguageProvider.to.t('snackbarInvalidReportBody'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final lang = LanguageProvider.to;
      final pdfBytes = await buildAssessmentReportPdf(
        payload: payload,
        labels: AssessmentPdfLabels.fromLang(lang),
      );
      final file = await saveAssessmentReportPdfFile(
        bytes: pdfBytes,
        childId: childId,
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
        await _showRedZoneAlert(LanguageProvider.to);
      }
    } catch (e) {
      Get.snackbar(
        LanguageProvider.to.t('error'),
        LanguageProvider.to
            .t('snackbarPdfGenerateFailed')
            .trParams({'error': '$e'}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lang = LanguageProvider.to;

      final rawArgs = Get.arguments;
      final Map<String, dynamic> args = <String, dynamic>{};
      if (rawArgs is Map) {
        rawArgs.forEach((key, value) {
          args[key.toString()] = value;
        });
      }

      final type = args['type'] is String ? args['type'] as String : 'Assessment';
      final typeDisplay = _localizedAssessmentType(type, lang);

      final dynamic rawScore = args['score'];
      final double parsedScore = rawScore is num
          ? rawScore.toDouble()
          : rawScore is String
              ? (double.tryParse(rawScore) ?? 85.0)
              : 85.0;

      final dynamic resultDataRaw = args['resultData'];
      final Map<String, dynamic>? resultData =
          resultDataRaw is Map ? Map<String, dynamic>.from(resultDataRaw) : null;

      final dynamic zoneLabelRaw =
          args['zone_label'] ?? args['zoneLabel'] ?? resultData?['zone_label'];
      final dynamic zoneColorRaw =
          args['zone_color'] ?? args['zoneColor'] ?? resultData?['zone_color'];

      final String? zoneLabel = zoneLabelRaw?.toString();
      final String? zoneColorStr = zoneColorRaw?.toString();

      final double score = (() {
        final dynamic apiPercentage = resultData?['percentage'];
        if (apiPercentage is num) return apiPercentage.toDouble();
        if (apiPercentage is String) {
          return double.tryParse(apiPercentage) ?? parsedScore;
        }
        return parsedScore;
      })();

      final interpretation = (args['interpretation'] is String)
          ? args['interpretation'] as String
          : (resultData?['zone_label'] != null
              ? lang.t('resultsSavedSuccessfully')
              : lang.t('resultsRecorded'));

      final riskCountRaw = args['riskCount'];
      final int? riskCount = riskCountRaw is int
          ? riskCountRaw
          : riskCountRaw is num
              ? riskCountRaw.toInt()
              : riskCountRaw is String
                  ? int.tryParse(riskCountRaw)
                  : null;

      final zone = (zoneLabel != null || zoneColorStr != null)
          ? _getZoneFromApi(zoneLabel, zoneColorStr)
          : _getZone(type, score, riskCount);

      return PopScope(
        canPop: false,
        child: Scaffold(
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
                          Expanded(
                            child: Text(lang.t('assessmentResults'),
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ),
                          const LanguageSwitcher(),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text('$typeDisplay ${lang.t('completed')}',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.9))),
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
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 120.r,
                            height: 120.r,
                            decoration: BoxDecoration(
                              color: zone.color,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    riskCount != null
                                        ? '$riskCount'
                                        : '${score.round()}%',
                                    style: TextStyle(
                                      fontSize: 30.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (riskCount != null)
                                    Text(lang.t('risks'),
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            zone.label,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            zone.description,
                            style: TextStyle(
                                fontSize: 13.sp, color: AppColors.textSecondary),
                          ),
                          SizedBox(height: 16.h),
                          Divider(color: AppColors.neutral200),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Icon(
                                zone.icon,
                                size: 20.sp,
                                color: zone.color,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  interpretation,
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColors.textSecondary,
                                      height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    if (riskCount == null) ...[
                      Container(
                        padding: EdgeInsets.all(AppSpacing.lg.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.xl2),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang.t('scoreZones'),
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            SizedBox(height: 12.h),
                            ...[
                              _ZoneLegend(AppColors.success,
                                  lang.t('zoneLegendNormalDev')),
                              _ZoneLegend(AppColors.warning,
                                  lang.t('zoneLegendMonitor')),
                              _ZoneLegend(AppColors.orange600,
                                  lang.t('zoneLegendAttention')),
                              _ZoneLegend(
                                  AppColors.error, lang.t('zoneLegendImmediate')),
                            ].map((z) => Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: Row(
                                    children: [
                                      Container(
                                          width: 20.r,
                                          height: 20.r,
                                          decoration: BoxDecoration(
                                              color: z.color,
                                              borderRadius:
                                                  BorderRadius.circular(4))),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(z.text,
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: AppColors.textSecondary)),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    if (score < 80 || (riskCount != null && riskCount > 2))
                      Container(
                        padding: EdgeInsets.all(AppSpacing.lg.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9C3),
                          borderRadius: BorderRadius.circular(AppRadius.xl2),
                          border: Border.all(color: const Color(0xFFFEF08A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang.t('recommendedNextSteps'),
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            SizedBox(height: 10.h),
                            ...[
                              'recNextLest',
                              'recNextStress',
                              'recNextTherapy',
                            ].map((key) => Padding(
                                  padding: EdgeInsets.only(bottom: 6.h),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('• ',
                                          style: TextStyle(
                                              fontSize: 13.sp,
                                              color: AppColors.textSecondary)),
                                      Expanded(
                                        child: Text(lang.t(key),
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: AppColors.textSecondary,
                                                height: 1.4)),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    SizedBox(height: 20.h),

                    if (!GlobalUtils().isGuestUser) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          final rawChild = resultData?['child'];
                          final childMap = rawChild is Map
                              ? Map<String, dynamic>.from(rawChild)
                              : null;
                          final childName =
                              (args['child_name'] ??
                                      args['childName'] ??
                                      childMap?['name'] ??
                                      'Assessment Report')
                                  .toString();

                          final rawTotalScore =
                              args['totalScore'] ?? resultData?['total_score'];
                          final totalScore = rawTotalScore is num
                              ? rawTotalScore.toInt()
                              : int.tryParse(rawTotalScore?.toString() ?? '') ??
                                  score.round();
                          final rawChildId = args['child_id'] ??
                              args['childId'] ??
                              resultData?['child_id'] ??
                              childMap?['id'];
                          final childId = rawChildId is num
                              ? rawChildId.toInt()
                              : int.tryParse(rawChildId?.toString() ?? '');

                          Get.to(
                            () => DetailedReportScreen(
                              childName: childName,
                              childId: childId,
                              totalScore: totalScore,
                              percentage: score,
                              assessmentTag: zone.label,
                              assessmentMessage: zone.description,
                              isRedZone: zone.color == AppColors.error,
                            ),
                          );
                        },
                        icon: Icon(Icons.description_rounded,
                            size: 18.sp, color: Colors.white),
                        label: Text(lang.t('viewDetailedReport'),
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50.h),
                          backgroundColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.xl)),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    if (!GlobalUtils().isGuestUser) ...[
                      OutlinedButton.icon(
                        onPressed: () => _downloadPdfReport(
                          args,
                          isRedZone: zone.color == AppColors.error,
                        ),
                        icon: Icon(Icons.download_rounded,
                            size: 18.sp, color: AppColors.textSecondary),
                        label: Text(lang.t('downloadPdfReport'),
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50.h),
                          side: const BorderSide(color: AppColors.neutral300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.xl)),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    OutlinedButton(
                      onPressed: () {
                        final isRedZone = zone.color == AppColors.error;
                        if (isRedZone && GlobalUtils().isGuestUser) {
                          _showRedZoneAlert(lang);
                        } else {
                          Get.until((r) => r.isFirst);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50.h),
                        side: const BorderSide(color: AppColors.neutral300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl)),
                      ),
                      child: Text(lang.t('returnToDashboard'),
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary)),
                    ),
                    SizedBox(height: AppSpacing.base.h),
                  ],
                ),
              ),
            ),
            const StandardFooter(),
          ],
        ),
        ),
      );
    });
  }
}

class _ZoneInfo {
  final Color color;
  final String label;
  final String description;
  final IconData icon;
  const _ZoneInfo(this.color, this.label, this.description, this.icon);
}

class _ZoneLegend {
  final Color color;
  final String text;
  const _ZoneLegend(this.color, this.text);
}

String _localizedAssessmentType(String type, LanguageProvider lang) {
  switch (type.toUpperCase()) {
    case 'TDSC':
      return lang.t('TDSC');
    case 'LEST':
      return lang.t('assessmentTypeLest');
    case 'PARENTAL STRESS':
    case 'PARENTAL_STRESS':
    case 'STRESS':
      return lang.t('STRESS');
    case 'RISK':
    case 'RISK FACTOR':
    case 'RISK_FACTOR':
      return lang.t('RISK_FACTOR');
    case 'ASSESSMENT':
      return lang.t('ASSESSMENT');
    default:
      return type;
  }
}

_ZoneInfo _getZone(String type, double score, int? riskCount) {
  final lang = LanguageProvider.to;
  if (riskCount != null) {
    if (riskCount == 0) {
      return _ZoneInfo(
          AppColors.success,
          lang.t('noRiskFactors'),
          lang.t('healthyDevelopmentIndicators'),
          Icons.check_circle_rounded);
    } else if (riskCount <= 2) {
      return _ZoneInfo(AppColors.warning, lang.t('lowRisk'),
          lang.t('minimalRiskFactorsPresent'), Icons.info_rounded);
    } else if (riskCount <= 4) {
      return _ZoneInfo(AppColors.orange600, lang.t('moderateRisk'),
          lang.t('someRiskFactorsIdentified'), Icons.warning_rounded);
    } else {
      return _ZoneInfo(AppColors.error, lang.t('highRisk'),
          lang.t('multipleRiskFactorsPresent'), Icons.warning_amber_rounded);
    }
  }

  if (score >= 80) {
    return _ZoneInfo(AppColors.success, lang.t('greenZone'),
        lang.t('normalDevelopment'), Icons.check_circle_rounded);
  } else if (score >= 60) {
    return _ZoneInfo(AppColors.warning, lang.t('yellowZone'),
        lang.t('monitorClosely'), Icons.info_rounded);
  } else if (score >= 40) {
    return _ZoneInfo(AppColors.orange600, lang.t('orangeZone'),
        lang.t('requiresAttention'), Icons.warning_rounded);
  } else {
    return _ZoneInfo(AppColors.error, lang.t('redZone'),
        lang.t('immediateAssessmentNeeded'), Icons.warning_amber_rounded);
  }
}

_ZoneInfo _getZoneFromApi(String? zoneLabel, String? zoneColor) {
  final lang = LanguageProvider.to;
  final color = (() {
    final z = zoneColor?.toLowerCase().trim();
    if (z == null) return AppColors.success;
    if (z == 'green') return AppColors.success;
    if (z == 'yellow') return AppColors.warning;
    if (z == 'orange') return AppColors.orange600;
    if (z == 'red') return AppColors.error;
    return AppColors.success;
  })();

  final label = zoneLabel ?? lang.t('assessmentResults');
  final description = zoneLabel ?? lang.t('normalDevelopment');

  final icon = (() {
    final z = zoneColor?.toLowerCase().trim();
    if (z == 'green') return Icons.check_circle_rounded;
    if (z == 'yellow') return Icons.info_rounded;
    if (z == 'orange') return Icons.warning_rounded;
    if (z == 'red') return Icons.warning_amber_rounded;
    return Icons.check_circle_rounded;
  })();

  return _ZoneInfo(color, label, description, icon);
}
