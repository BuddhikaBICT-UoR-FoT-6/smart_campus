// =============================================================================
// data/remote/announcement_api.dart
// =============================================================================
// CLEAN ARCHITECTURE — Data Layer (Remote)
//
// RESPONSIBILITY:
//   Makes HTTP GET requests to the mock REST API and converts raw JSON
//   into a list of Announcement domain objects.
//
// MOCK API:
//   https://jsonplaceholder.typicode.com/posts?_limit=10
//   This is a free, public dummy REST API — no authentication required.
//   Perfect for university projects and assessments.
//
// VIVA POINT:
//   "We use the http package to call JSONPlaceholder. The response
//    is decoded from JSON and mapped to Announcement objects using
//    fromJson(). If the status code is not 200, we throw an Exception
//    which the Provider catches and stores as an error message."
// =============================================================================

import 'dart:async';             // Required to intercept TimeoutException during hung networks
import 'dart:convert';           // Required to serialize raw network strings to JSON graphs
import 'dart:io';                // Required to natively intercept 'SocketException' on offline devices
import 'package:http/http.dart' as http; // HTTP client

import '../../app/config.dart'; // 1. Inject Environment Flavor bindings
import '../../core/error/app_exceptions.dart'; // Standardized app exceptions for UI safety
import '../../domain/models/announcement.dart';

class AnnouncementApi {
  // ---------------------------------------------------------------------------
  // Dependency: http client
  // ---------------------------------------------------------------------------
  // Injecting the client (rather than using http.get directly) makes this
  // class testable — in unit tests you can pass a mock client.

  final http.Client _client;

  AnnouncementApi({http.Client? client}) : _client = client ?? http.Client();

  // ---------------------------------------------------------------------------
  // API Endpoint
  // ---------------------------------------------------------------------------

  // 2. Remove hardcoded Dev URL and point strictly to the dynamic compiled Environment Config
  static String get _baseUrl => AppConfig.apiBaseUrl;

  // 3. Build the endpoint dynamically combining Flavor Host and Route parameters
  static String get _endpoint => '$_baseUrl/posts?_limit=10';

  // ---------------------------------------------------------------------------
  // Fetch
  // ---------------------------------------------------------------------------

  /// Fetches campus announcements from the mock REST API.
  ///
  /// Returns a [List<Announcement>] on success.
  /// Throws an [Exception] on network failure or non-200 response,
  /// which is caught by [AnnouncementProvider] and shown as an error.
  ///
  /// Example successful JSON element:
  /// ```json
  /// {
  ///   "userId": 1,
  ///   "id": 1,
  ///   "title": "sunt aut facere repellat provident occaecati ...",
  ///   "body": "quia et suscipit suscipit recusandae ..."
  /// }
  /// ```
  Future<List<Announcement>> fetchAnnouncements() async {
    // 1. Convert the hardcoded string into a parsed universally native URI object
    final uri = Uri.parse(_endpoint);

    try {
      // 2. Enforce a strict 10-second timeout. If the server doesn't reply, abort the hanging network socket.
      // This protects the application UI from "spinning forever" if backend servers go down ungracefully.
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      // 3. Mathematically check if the response status is strictly 200 OK.
      if (response.statusCode == 200) {
        // 4. Securely decode the string payload assuming the shape is a List structure
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;

        // 5. Initialize iterative map conversion transforming raw un-typed maps into validated Domain model objects
        return jsonList
            .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // 6. Explicitly bundle any bad REST response into our standardized UI-facing exception.
        throw ServerException('Invalid Response: ${response.statusCode}');
      }
    } on SocketException {
      // 7. Explicitly catch offline devices hitting physical hardware connectivity failures.
      // We shield the raw native stacktrace by converting it to our domain NetworkException.
      throw NetworkException();
    } on TimeoutException {
      // 8. Explicitly catch our forced 10-second timer expiring, resulting in a Timeout.
      throw ServerTimeoutException();
    } catch (e) {
      // 9. Implement an architectural catch-all for unknown edge cases (like JSON parser failures).
      // If it's already one of our structured exceptions, immediately bubble it upwards natively.
      if (e is AppException) rethrow; 
      
      // Otherwise, wrap the unrecognized error to guarantee the UI doesn't crash on unhandled types.
      throw AppException('An unexpected error occurred during fetch.');
    }
  }
}
