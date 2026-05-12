import 'package:flutter/material.dart';

/// Complete color palette for SAHAMITHRA — Flutter implementation.
/// Sources: /config/theme.ts · /styles/globals.css · all Tailwind classes
/// used across every web component (cross-referenced against every .dart screen).
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY BRAND COLORS (Logo gradient)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color purple      = Color(0xFF9333EA); // purple-600
  static const Color pink        = Color(0xFFEC4899); // pink-500
  static const Color blue        = Color(0xFF3B82F6); // blue-500
  static const Color purpleLight = Color(0xFFA855F7); // purple-500

  // Named aliases used across screens
  static const Color primaryPurple = Color(0xFF9333EA); // ≡ purple
  static const Color primaryPink   = Color(0xFFEC4899); // ≡ pink
  static const Color primaryBlue   = Color(0xFF3B82F6); // ≡ blue

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKGROUND COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color backgroundPrimary   = Color(0xFFFFFFFF); // white
  static const Color backgroundSecondary = Color(0xFFF8FAFC); // slate-50
  static const Color backgroundTertiary  = Color(0xFFF1F5F9); // slate-100

  // ═══════════════════════════════════════════════════════════════════════════
  // 50-LEVEL TINTS (light page / card washes)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color purple50  = Color(0xFFFAF5FF);
  static const Color pink50    = Color(0xFFFDF2F8);
  static const Color blue50    = Color(0xFFEFF6FF);
  static const Color indigo50  = Color(0xFFEEF2FF); // ← NEW  indigo-50
  static const Color violet50  = Color(0xFFF5F3FF); // ← NEW  violet-50
  static const Color teal50    = Color(0xFFF0FDFA); // ← NEW  teal-50
  static const Color emerald50 = Color(0xFFECFDF5); // ← NEW  emerald-50
  static const Color green50   = Color(0xFFF0FDF4); // ← NEW  green-50
  static const Color rose50    = Color(0xFFFFF1F2); // ← NEW  rose-50
  static const Color amber50   = Color(0xFFFFFBEB); // ← NEW  amber-50
  static const Color orange50  = Color(0xFFFFF7ED); // ← NEW  orange-50
  static const Color red50     = Color(0xFFFEF2F2); // ← NEW  red-50
  static const Color cyan50    = Color(0xFFECFEFF); // ← NEW  cyan-50
  static const Color yellow50  = Color(0xFFFEFCE8); // ← NEW  yellow-50

  // ═══════════════════════════════════════════════════════════════════════════
  // 100-LEVEL TINTS (icon/chip backgrounds)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color purple100  = Color(0xFFF3E8FF);
  static const Color pink100    = Color(0xFFFCE7F3);
  static const Color blue100    = Color(0xFFDBEAFE);
  static const Color indigo100  = Color(0xFFE0E7FF); // ← NEW  indigo-100
  static const Color violet100  = Color(0xFFEDE9FE); // ← NEW  violet-100
  static const Color teal100    = Color(0xFFCCFBF1); // ← NEW  teal-100
  static const Color emerald100 = Color(0xFFD1FAE5); // ← NEW  emerald-100 (≡ green100)
  static const Color green100   = Color(0xFFD1FAE5);
  static const Color rose100    = Color(0xFFFFE4E6); // ← NEW  rose-100
  static const Color red100     = Color(0xFFFEE2E2);
  static const Color orange100  = Color(0xFFFFEDD5);
  static const Color amber100   = Color(0xFFFEF3C7);
  static const Color cyan100    = Color(0xFFCFFAFE);
  static const Color yellow100  = Color(0xFFFEF9C3);

  // ═══════════════════════════════════════════════════════════════════════════
  // 500-LEVEL MIDS (filled buttons / active states)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color indigo500  = Color(0xFF6366F1); // ← NEW  indigo-500
  static const Color violet500  = Color(0xFF8B5CF6); // ← NEW  violet-500
  static const Color teal500    = Color(0xFF14B8A6); // ← NEW  teal-500
  static const Color emerald500 = Color(0xFF10B981); // ← NEW  emerald-500 (≡ success)
  static const Color green500   = Color(0xFF22C55E); // ← NEW  green-500 (distinct from emerald-500)

  // ═══════════════════════════════════════════════════════════════════════════
  // 600-LEVEL ICON / ACCENT COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  // Already-named aliases kept for back-compat
  static const Color purple600  = Color(0xFF9333EA); // ≡ purple
  static const Color pink600    = Color(0xFFDB2777);
  static const Color blue600    = Color(0xFF2563EB);
  static const Color indigo600  = Color(0xFF4F46E5); // ← NEW  indigo-600
  static const Color violet600  = Color(0xFF7C3AED); // ← NEW  violet-600
  static const Color teal600    = Color(0xFF0D9488); // ← NEW  teal-600
  static const Color emerald600 = Color(0xFF059669); // ← NEW  emerald-600
  static const Color green600   = Color(0xFF16A34A);
  static const Color rose600    = Color(0xFFE11D48); // ← NEW  rose-600
  static const Color red600     = Color(0xFFDC2626);
  static const Color orange600  = Color(0xFFEA580C);
  static const Color amber600   = Color(0xFFD97706);
  static const Color cyan600    = Color(0xFF0891B2);

  // ─── Warm yellow / gold ──────────────────────────────────────────────────
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow500 = Color(0xFFEAB308); // ← NEW  yellow-500

  // ═══════════════════════════════════════════════════════════════════════════
  // 700-LEVEL DARKEN / HOVER STATES
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color purple700  = Color(0xFF7E22CE); // ← NEW  purple-700
  static const Color pink700    = Color(0xFFBE185D); // ← NEW  pink-700
  static const Color blue700    = Color(0xFF1D4ED8); // ← NEW  blue-700
  static const Color indigo700  = Color(0xFF4338CA); // ← NEW  indigo-700
  static const Color teal700    = Color(0xFF0F766E); // ← NEW  teal-700
  static const Color emerald700 = Color(0xFF047857); // ← NEW  emerald-700
  static const Color green700   = Color(0xFF15803D); // ← NEW  green-700

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC / STATUS COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color error   = Color(0xFFEF4444); // red-500
  static const Color info    = Color(0xFF3B82F6); // blue-500

  // ═══════════════════════════════════════════════════════════════════════════
  // NEUTRAL / SLATE SCALE (50 → 900)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color neutral50  = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color textPrimary   = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF475569); // slate-600
  static const Color textTertiary  = Color(0xFF94A3B8); // slate-400
  static const Color textInverse   = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER & DIVIDER
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color border = Color(0xFFE2E8F0); // slate-200

  // ═══════════════════════════════════════════════════════════════════════════
  // WHITE OVERLAYS (for gradient / dark-bg surfaces)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color white10 = Color(0x1AFFFFFF); // ← NEW  10 % white
  static const Color white20 = Color(0x33FFFFFF); //        20 % white
  static const Color white30 = Color(0x4DFFFFFF); //        30 % white
  static const Color white50 = Color(0x80FFFFFF); // ← NEW  50 % white
  static const Color white70 = Color(0xB3FFFFFF); // ← NEW  70 % white

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENT DEFINITIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary brand gradient: purple-600 → pink-500 → blue-500
  /// Used in headers, primary buttons, logos.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [purple, pink, blue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Alias for primaryGradient — used by screens that reference mainGradient.
  static const LinearGradient mainGradient = LinearGradient(
    colors: [purple, pink, blue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Light wash gradient: purple-50 → pink-50 → blue-50
  /// Used for subtle page/card backgrounds (mirrors Tailwind: from-purple-50 via-pink-50 to-blue-50).
  static const LinearGradient lightGradient = LinearGradient(
    colors: [purple50, pink50, blue50],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Hover / pressed variant: purple-700 → pink-700 → blue-700
  static const LinearGradient hoverGradient = LinearGradient(
    colors: [purple700, pink700, blue700],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Card light wash: purple-100 → pink-100 → blue-100
  static const LinearGradient cardGradient = LinearGradient(
    colors: [purple100, pink100, blue100],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Gamification / teaser strip (same hues as card, different label)
  static const LinearGradient gamificationGradient = LinearGradient(
    colors: [purple100, pink100, blue100],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Purple → pink (gamification header, progress badges)
  static const LinearGradient purplePinkGradient = LinearGradient(
    colors: [purple, pink600],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Indigo → purple (progress tracking card, indigoGradient alias)
  static const LinearGradient indigoGradient = LinearGradient(
    colors: [indigo500, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Indigo-600 → blue-600 (Reports / AppointmentBooking / DataPrivacy headers)
  /// Mirrors web: bg-indigo-600 screens
  static const LinearGradient indigoBlueGradient = LinearGradient( // ← NEW
    colors: [indigo600, blue600],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Amber / yellow (WeeklyTherapySchedule reminder card)
  static const LinearGradient amberGradient = LinearGradient(
    colors: [amber100, yellow100],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// LEST Assessment header: green-600 → emerald-500 → teal-500
  /// Mirrors web: from-green-600 via-emerald-500 to-teal-500
  static const LinearGradient lestGradient = LinearGradient( // ← NEW
    colors: [green600, emerald500, teal500],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Teal gradient (ActivityLibrary / CDMC accents)
  static const LinearGradient tealGradient = LinearGradient( // ← NEW
    colors: [teal600, cyan600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Green gradient (InstitutionFinder / TeamCollaboration success states)
  static const LinearGradient greenGradient = LinearGradient( // ← NEW
    colors: [green600, emerald600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Slate / dark gradient (DataPrivacy header, therapist portals)
  /// Mirrors web: bg-slate-700
  static const LinearGradient slateGradient = LinearGradient( // ← NEW
    colors: [neutral700, neutral800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}