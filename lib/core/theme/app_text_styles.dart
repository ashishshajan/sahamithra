import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography matching the web app's CSS base styles and Tailwind text-* classes.
/// The web app uses system sans-serif at 16px base with the following weights:
///   - font-weight-normal: 400
///   - font-weight-medium: 500
///   - font-weight-semibold: 600
///   - font-weight-bold: 700
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.poppins(
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // ─── Semantic HTML headings (globals.css canonical sizes) ────────────────────
  //
  //   h1 { font-size: var(--text-2xl); font-weight: 500; }   →  24sp  w500
  //   h2 { font-size: var(--text-xl);  font-weight: 500; }   →  20sp  w500
  //   h3 { font-size: var(--text-lg);  font-weight: 500; }   →  18sp  w500

  /// h1 — text-2xl / 24 sp / w500
  static TextStyle get h1 => _base.copyWith(
    fontSize: 24.sp,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  /// h2 — text-xl / 20 sp / w500
  /// Used for: section headings (AssessmentMenu card titles, Gamification
  /// section headers, DataPrivacy block titles, Dashboard sub-section labels).
  static TextStyle get h2 => _base.copyWith(
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  /// h3 — text-lg / 18 sp / w500
  /// Used for: card / list-item titles (Dashboard menu rows, LoginScreen
  /// feature items, CDMCServices card names, FeedbackSubmission block labels).
  static TextStyle get h3 => _base.copyWith(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  // ─── Semantic title scale (bold variants, used by Flutter screens) ───────────

  /// text-5xl font-bold (splash title) → 40sp
  static TextStyle get display => _base.copyWith(
    fontSize: 40.sp,
    fontWeight: FontWeight.w700,
  );

  /// text-xl font-bold (screen titles) → 20sp
  static TextStyle get titleLarge => _base.copyWith(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
  );

  /// text-lg font-bold (section headings) → 18sp
  static TextStyle get titleMedium => _base.copyWith(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
  );

  /// text-base font-semibold (card titles) → 16sp
  static TextStyle get titleSmall => _base.copyWith(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  // ─── Body ────────────────────────────────────────────────────────────────────

  /// text-base (default body) → 16sp
  static TextStyle get bodyLarge => _base.copyWith(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
  );

  /// text-sm → 14sp
  static TextStyle get bodyMedium => _base.copyWith(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// text-xs → 12sp
  static TextStyle get bodySmall => _base.copyWith(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ─── Labels / Buttons ────────────────────────────────────────────────────────

  /// Button label: text-base font-semibold → 16sp
  static TextStyle get button => _base.copyWith(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
  );

  /// text-sm font-medium (form labels) → 14sp
  static TextStyle get label => _base.copyWith(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );

  /// text-xs font-semibold (overline / section caps) → 12sp
  static TextStyle get caption => _base.copyWith(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
    letterSpacing: 0.8,
  );

  // ─── White variants (for gradient / dark-background surfaces) ────────────────

  static TextStyle get h2White        => h2.copyWith(color: Colors.white);
  static TextStyle get h3White        => h3.copyWith(color: Colors.white);
  static TextStyle get displayWhite   => display.copyWith(color: Colors.white);
  static TextStyle get titleLargeWhite  => titleLarge.copyWith(color: Colors.white);
  static TextStyle get titleMediumWhite => titleMedium.copyWith(color: Colors.white);
  static TextStyle get bodyLargeWhite   => bodyLarge.copyWith(color: Colors.white);
  static TextStyle get bodyMediumWhite  => bodyMedium.copyWith(color: Colors.white);
  static TextStyle get bodySmallWhite   => bodySmall.copyWith(color: Colors.white);
  static TextStyle get captionWhite     => caption.copyWith(color: Colors.white70);
}
