// =============================================================================
// domain/models/event.dart
// =============================================================================
// CLEAN ARCHITECTURE — Domain Layer
//
// Pure Dart. No Flutter or package imports.
//
// VIVA POINT:
//   "Event holds the data for a campus event. Registrations are stored in a
//    separate 'registrations' table that links users to events — a classic
//    many-to-many relationship kept minimal for our scope."
// =============================================================================

/// Represents a campus event that students can register for.
///
/// - [id]          Unique identifier
/// - [title]       Short event name e.g. "Freshers' Welcome Day"
/// - [description] One-sentence description
/// - [date]        ISO 8601 date string e.g. "2026-03-15"
/// - [venue]       Location string e.g. "Main Auditorium"
/// - [organizer]   Name of the organising department/person
class Event {
  final String id;
  final String title;
  final String description;
  final String date;
  final String venue;
  final String organizer;
  final int capacity;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.venue,
    required this.organizer,
    this.capacity = 50,
  });

  // ---------------------------------------------------------------------------
  // SQLite helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'venue': venue,
      'organizer': organizer,
      'capacity': capacity,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      date: map['date'] as String,
      venue: map['venue'] as String,
      organizer: map['organizer'] as String,
      capacity: map['capacity'] as int? ?? 50,
    );
  }

  @override
  String toString() => 'Event(id: $id, title: $title, date: $date)';
}
