import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/ResultsScreen.tsx
/// Displays results after any assessment (TDSC, LEST, Stress, Risk).
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // `Get.arguments` can be null / not the expected type when a route is opened
    // directly. Use safe parsing + dummy defaults.
    final rawArgs = Get.arguments;
    final Map<String, dynamic> args = <String, dynamic>{};
    if (rawArgs is Map) {
      rawArgs.forEach((key, value) {
        args[key.toString()] = value;
      });
    }

    final type = args['type'] is String ? args['type'] as String : 'Assessment';

    // API response uses `percentage` for TDSC.
    final dynamic rawScore = args['score'];
    final double parsedScore = rawScore is num
        ? rawScore.toDouble()
        : rawScore is String
            ? (double.tryParse(rawScore) ?? 85.0)
            : 85.0;

    final dynamic resultDataRaw = args['resultData'];
    final Map<String, dynamic>? resultData =
        resultDataRaw is Map ? (resultDataRaw as Map).cast<String, dynamic>() : null;

    // zone_label / zone_color can come either top-level or inside `resultData`.
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
            ? 'Results saved successfully'
            : 'Results have been recorded.');

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFF4F46E5),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                child: Row(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assessment Results',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Text('$type completed',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.9))),
                      ],
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
                  // Score card
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
                        // Score circle
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
                                  Text('risks',
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

                  // Score zones legend
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
                          Text('Score Zones',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          SizedBox(height: 12.h),
                          ...[
                            _ZoneLegend(
                                AppColors.success, '80–100: Normal Development'),
                            _ZoneLegend(
                                AppColors.warning, '60–79: Monitor Closely'),
                            _ZoneLegend(
                                AppColors.orange600, '40–59: Requires Attention'),
                            _ZoneLegend(
                                AppColors.error, '0–39: Immediate Assessment'),
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
                                    Text(z.text,
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Recommendations
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
                          Text('Recommended Next Steps',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          SizedBox(height: 10.h),
                          ...[
                            'Complete Language Evaluation (LEST) if speech delay is suspected',
                            'Take the Parental Stress Assessment',
                            'Consider booking an appointment with a therapy institution',
                          ].map((step) => Padding(
                                padding: EdgeInsets.only(bottom: 6.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• ',
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            color: AppColors.textSecondary)),
                                    Expanded(
                                      child: Text(step,
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

                  // Action buttons
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.description_rounded,
                        size: 18.sp, color: Colors.white),
                    label: Text('View Detailed Report',
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
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.download_rounded,
                        size: 18.sp, color: AppColors.textSecondary),
                    label: Text('Download PDF Report',
                        style: TextStyle(
                            fontSize: 14.sp, color: AppColors.textSecondary)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.h),
                      side: const BorderSide(color: AppColors.neutral300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  OutlinedButton(
                    onPressed: () => Get.until((r) => r.isFirst),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.h),
                      side: const BorderSide(color: AppColors.neutral300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl)),
                    ),
                    child: Text('Return to Dashboard',
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
    );
  }

  _ZoneInfo _getZone(String type, double score, int? riskCount) {
    if (riskCount != null) {
      if (riskCount == 0) {
        return _ZoneInfo(AppColors.success, 'No Risk Factors',
            'Healthy development indicators', Icons.check_circle_rounded);
      } else if (riskCount <= 2) {
        return _ZoneInfo(AppColors.warning, 'Low Risk',
            'Minimal risk factors present', Icons.info_rounded);
      } else if (riskCount <= 4) {
        return _ZoneInfo(AppColors.orange600, 'Moderate Risk',
            'Some risk factors identified', Icons.warning_rounded);
      } else {
        return _ZoneInfo(AppColors.error, 'High Risk',
            'Multiple risk factors present', Icons.warning_amber_rounded);
      }
    }

    if (score >= 80) {
      return _ZoneInfo(AppColors.success, 'Green Zone',
          'Normal Development', Icons.check_circle_rounded);
    } else if (score >= 60) {
      return _ZoneInfo(AppColors.warning, 'Yellow Zone',
          'Monitor Closely', Icons.info_rounded);
    } else if (score >= 40) {
      return _ZoneInfo(AppColors.orange600, 'Orange Zone',
          'Requires Attention', Icons.warning_rounded);
    } else {
      return _ZoneInfo(AppColors.error, 'Red Zone',
          'Immediate Assessment Needed', Icons.warning_amber_rounded);
    }
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

_ZoneInfo _getZoneFromApi(String? zoneLabel, String? zoneColor) {
  // Map API `zone_color` to UI colors.
  final color = (() {
    final z = zoneColor?.toLowerCase().trim();
    if (z == null) return AppColors.success;
    if (z == 'green') return AppColors.success;
    if (z == 'yellow') return AppColors.warning;
    if (z == 'orange') return AppColors.orange600;
    if (z == 'red') return AppColors.error;
    // Unknown string: fallback to success.
    return AppColors.success;
  })();

  final label = zoneLabel ?? 'Assessment Results';

  // Keep description aligned with what the API gives us.
  final description = zoneLabel ?? 'Normal Development';

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
