import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
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

  static const List<_RiskFactor> _factors = [
    _RiskFactor('Was the child born prematurely (before 37 weeks)?', 'Birth History'),
    _RiskFactor('Did the child have low birth weight (less than 2.5 kg)?', 'Birth History'),
    _RiskFactor('Were there any complications during pregnancy or delivery?', 'Birth History'),
    _RiskFactor('Is there a family history of developmental delays or disabilities?', 'Family History'),
    _RiskFactor('Does the child have any genetic conditions or syndromes?', 'Medical History'),
    _RiskFactor('Has the child experienced any serious infections (meningitis, encephalitis)?', 'Medical History'),
    _RiskFactor('Does the child have hearing or vision problems?', 'Sensory'),
    _RiskFactor('Has the child had any head injuries or seizures?', 'Medical History'),
    _RiskFactor('Is the child exposed to environmental toxins (lead, mercury)?', 'Environmental'),
    _RiskFactor('Does the child have limited access to early childhood education?', 'Social/Environmental'),
    _RiskFactor('Has the child experienced significant stress or trauma?', 'Social/Environmental'),
    _RiskFactor('Does the child have chronic health conditions (asthma, diabetes)?', 'Medical History'),
  ];

  double get _progress => (_current + 1) / _factors.length;

  bool get _canComplete =>
      _answers.length == _factors.length;

  void _handleAnswer(bool value) {
    setState(() {
      _answers[_current] = value;
      if (_current < _factors.length - 1) {
        _current++;
      }
    });
  }

  void _complete() {
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
                        Text(
                          factor.question,
                          style: TextStyle(
                            fontSize: 17.sp,
                            color: AppColors.textPrimary,
                            height: 1.4,
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
  final String question;
  final String category;
  const _RiskFactor(this.question, this.category);
}
