// =============================================================================
// domain/models/announcement.dart
// =============================================================================
// CLEAN ARCHITECTURE — Domain Layer
//
// Pure Dart. No Flutter or package imports.
//
// VIVA POINT:
//   "Announcement data comes from the REST API, not SQLite. fromJson() maps
//    the JSON fields that JSONPlaceholder returns to our own model fields.
//    The UI only ever sees Announcement objects — it never touches raw JSON."
// =============================================================================

/// Represents a campus-wide announcement fetched from the REST API.
///
/// We use JSONPlaceholder (https://jsonplaceholder.typicode.com/posts)
/// as our mock REST endpoint. Its fields map as follows:
///   - JSON `id`     → [id]
///   - JSON `title`  → [title]
///   - JSON `body`   → [body]
///   - [postedBy] is hardcoded to "Campus Admin" since the mock API has no
///     author field — acceptable for a demo/assessment project
///   - [date] is also hardcoded per-item to show a realistic timestamp
class Announcement {
  final int id;
  final String title;
  final String body;
  final String postedBy;
  final String date;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.postedBy,
    required this.date,
  });

  // ---------------------------------------------------------------------------
  // JSON helper (REST API)
  // ---------------------------------------------------------------------------

  /// Parses a single JSON object from the API response list.
  ///
  /// Example input:
  /// ```json
  /// {
  ///   "userId": 1,
  ///   "id": 3,
  ///   "title": "Exam schedule released",
  ///   "body": "Please check the notice board for final exam dates."
  /// }
  /// ```
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int,
      title: (json['title'] as String).trim(),
      body: (json['body'] as String).trim(),
      postedBy: 'Campus Admin', // mock API has no author field
      date: '2026-02-${(json['id'] as int).clamp(1, 28).toString().padLeft(2, '0')}',
    );
  }

  // ---------------------------------------------------------------------------
  // SQLite helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'postedBy': postedBy,
      'date': date,
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
      postedBy: map['postedBy'] as String,
      date: map['date'] as String,
    );
  }

  @override
  String toString() => 'Announcement(id: $id, title: $title)';
}
