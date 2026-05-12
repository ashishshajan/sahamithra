/// Spacing constants matching Tailwind CSS scale used in the web design.
/// Tailwind base unit = 4px
class AppSpacing {
  AppSpacing._();

  static const double xs   = 4.0;   // 1 unit
  static const double sm   = 8.0;   // 2 units
  static const double md   = 12.0;  // 3 units
  static const double base = 16.0;  // 4 units
  static const double lg   = 20.0;  // 5 units
  static const double xl   = 24.0;  // 6 units
  static const double xl2  = 32.0;  // 8 units
  static const double xl3  = 40.0;  // 10 units
  static const double xl4  = 48.0;  // 12 units
  static const double xl5  = 56.0;  // 14 units
  static const double xl6  = 64.0;  // 16 units
}

/// Border radius constants matching Tailwind rounded-* classes
class AppRadius {
  AppRadius._();

  static const double sm   = 4.0;   // rounded-sm
  static const double base = 6.0;   // rounded
  static const double md   = 8.0;   // rounded-md
  static const double lg   = 8.0;   // rounded-lg (Tailwind default ≈ 8px)
  static const double xl   = 12.0;  // rounded-xl
  static const double xl2  = 16.0;  // rounded-2xl
  static const double xl3  = 24.0;  // rounded-3xl
  static const double full = 9999.0; // rounded-full
}
