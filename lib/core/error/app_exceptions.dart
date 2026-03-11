// =============================================================================
// core/error/app_exceptions.dart
// =============================================================================
// CLEAN ARCHITECTURE — Core Layer
//
// RESPONSIBILITY:
//   Provides a standardized, architecturally safe exception framework.
//   By wrapping all raw Dart/Flutter errors into `AppException`, the UI layer
//   can gracefully present safe error strings without breaking abstraction.
// =============================================================================

/// A standardized production-grade exception class for the application hierarchy.
/// Extending standard Exception ensures full compatibility with Dart's `throw` system.
class AppException implements Exception {
  // A human-readable message safely describing the error to end-users
  final String message;
  // An optional developer-facing string classifying the fault domain
  final String? prefix;

  // Constructor generating fallback strings if none are provided
  AppException([this.message = 'An unexpected error occurred.', this.prefix]);

  // Override string interpolation to print cleanly in Flutter debug consoles
  @override
  String toString() {
    return prefix != null ? '$prefix: $message' : message;
  }
}

/// Thrown specifically when the physical device has no internet connection (Socket bounds)
class NetworkException extends AppException {
  // Hardcoded default payload ensures all offline texts uniformly say the same thing.
  NetworkException([String message = 'Please check your internet connection.']) 
      : super(message, 'Network Error');
}

/// Thrown when the remote API server hangs and breaches our defined timeout limits
class ServerTimeoutException extends AppException {
  // Protects the app from infinite hanging loading spinners by enforcing boundaries
  ServerTimeoutException([String message = 'The connection timed out. Please try again.']) 
      : super(message, 'Timeout Error');
}

/// Thrown when the API responds successfully but explicitly returns a non-200 HTTP status code.
class ServerException extends AppException {
  // General exception for 400, 401, 500, etc.
  ServerException([String message = 'The server encountered an error.']) 
      : super(message, 'Server Error');
}
