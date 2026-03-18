// =============================================================================
// app/config.dart
// =============================================================================
// CLEAN ARCHITECTURE — Environment Configuration Layer
//
// RESPONSIBILITY:
//   Acts as the central router for 'Flavors' (Environment configurations).
//   By injecting `--dart-define=ENV=prod` during build, the app automatically
//   switches endpoints, analytics keys, and logging profiles without native 
//   Xcode/Gradle flavor complexity.
// =============================================================================

class AppConfig {
  // 1. Statically extract the injection variable at compile time
  // Defaulting to 'dev' ensures developers don't accidentally run against Prod
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'dev');

  // 2. Dynamically route network configurations based on the compiled hardware state
  static String get apiBaseUrl {
    switch (environment) {
      case 'prod':
        // The isolated production environment database
        return 'https://api.smartcampus.lk/v1'; 
      case 'staging':
        // Pre-production QA environment mirroring production architecture
        return 'https://staging.smartcampus.lk/v1';
      case 'dev':
      default:
        // Local isolated development mock JSON endpoint prevents polluting real data
        return 'https://jsonplaceholder.typicode.com';
    }
  }

  // 3. Expose boolean flags for conditional UI (e.g. hiding debug tools in prod)
  static bool get isProduction => environment == 'prod';
}
