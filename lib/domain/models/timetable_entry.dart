// =============================================================================
// domain/models/timetable_entry.dart
// =============================================================================
// CLEAN ARCHITECTURE — Domain Layer
//
// Pure Dart. No Flutter or package imports.
//
// VIVA POINT:
//   "TimetableEntry represents a single class slot for a student.
//    It is linked to a user via userId — a simple foreign-key relationship."
// =============================================================================

/// Represents one row in a student's class schedule.
///
/// - [id]         Unique identifier
/// - [subject]    E.g. "Mobile Application Development"
/// - [dayOfWeek]  E.g. "Monday", "Wednesday"
/// - [startTime]  24-hour format string e.g. "08:00"
/// - [endTime]    24-hour format string e.g. "10:00"
/// - [room]       Lecture hall/lab identifier e.g. "Lab 3"
/// - [userId]     Foreign key → users.id (which student this entry belongs to)
class TimetableEntry {
  final String id;
  final String subject;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String room;
  final String userId;

  const TimetableEntry({
    required this.id,
    required this.subject,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.userId,
  });

  // ---------------------------------------------------------------------------
  // SQLite helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'userId': userId,
    };
  }

  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      id: map['id'] as String,
      subject: map['subject'] as String,
      dayOfWeek: map['dayOfWeek'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      room: map['room'] as String,
      userId: map['userId'] as String,
    );
  }

  @override
  String toString() =>
      'TimetableEntry($dayOfWeek $startTime–$endTime $subject @ $room)';
}
