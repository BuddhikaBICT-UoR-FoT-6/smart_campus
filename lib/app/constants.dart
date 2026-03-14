// =============================================================================
// app/constants.dart
// =============================================================================
// CLEAN ARCHITECTURE — Configuration Layer
//
// RESPONSIBILITY:
//   Centralizes all architectural "magic numbers" and bare strings, ensuring 
//   strict UI consistency across the entire application and preventing
//   fragmented design systems.
// =============================================================================

/// 1. Semantic Spacing: Replaces raw padding integers with proportional increments
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
}

/// 2. Semantic Sizes: Enforces uniform dimensions across UI elements
class AppSizes {
  static const double iconSmall = 18.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 56.0;
  
  static const double buttonRadius = 12.0;
  static const double cardRadius = 16.0;
}

/// 3. Static Strings: Prevents typo bugs in headers and localized configurations
class AppStrings {
  static const String appName = 'Smart Campus';
  static const String defaultError = 'An unexpected error occurred.';
}
