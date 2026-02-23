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

import 'dart:convert';
import 'package:http/http.dart' as http;

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

  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // Limit to 10 posts so the list doesn't overwhelm the screen.
  static const String _endpoint = '$_baseUrl/posts?_limit=10';

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
    final uri = Uri.parse(_endpoint);

    // async/await pauses here until the HTTP response arrives.
    // The rest of the app keeps running (UI stays responsive).
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      // jsonDecode converts the raw String body into a Dart List<dynamic>
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;

      // Map each JSON object to an Announcement domain model.
      return jsonList
          .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      // Non-200: surface a readable error so the UI can display it.
      throw Exception(
        'Failed to load announcements. '
        'Status: ${response.statusCode}',
      );
    }
  }
}
