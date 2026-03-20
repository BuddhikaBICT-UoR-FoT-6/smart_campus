// =============================================================================
// core/telemetry/crashlytics_service.dart
// =============================================================================
// CLEAN ARCHITECTURE — Telemetry Layer
//
// RESPONSIBILITY:
//   A Facade intercepting fatal exceptions. In a real production app, this 
//   forwards logs to Firebase Crashlytics or Sentry. Using a facade prevents 
//   Firebase SDKs from heavily polluting the business logic.
// =============================================================================

import 'package:flutter/foundation.dart';
import '../error/app_exceptions.dart';

class CrashlyticsService {
  // 1. Singleton pattern ensures telemetry doesn't duplicate network pings
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  // 2. Mock initialization mapped to main() bootstrap sequence
  static Future<void> initialize() async {
    debugPrint('[CrashlyticsService] Telemetry hooks dynamically initialized.');
  }

  // 3. Centralized router for exceptions
  static void logCrash(Object error, StackTrace? stackTrace) {
    // 4. Architecturally ignore routing basic 'Offline' exceptions to Crashlytics
    // Since offline events aren't 'crashes', they just waste database space
    if (error is NetworkException) return;

    // 5. Differential behavior based on the Environment Flavor
    if (kReleaseMode) {
      // In Production, transmit to remote servers quietly
      // e.g., FirebaseCrashlytics.instance.recordError(error, stackTrace);
      debugPrint('[CrashlyticsService] Transmitting fatal stacktrace to server...');
    } else {
      // In Dev, yell loudly into the local console
      debugPrint('=================[ CRASH DETECTED ]=================');
      debugPrint(error.toString());
      if (stackTrace != null) debugPrint(stackTrace.toString());
      debugPrint('====================================================');
    }
  }
}
