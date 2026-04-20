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
/// - [room]            Lecture hall/lab identifier e.g. "Lab 3"
/// - [userId]          Foreign key → users.id
/// - [isAttended]      Attendance status for past lectures (true/false/null)
/// - [lectureContent]   Upcoming content overview
/// - [isAdditional]    Flag for mandatory events / extra sessions
class TimetableEntry {
  final String id;
  final String subject;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String room;
  final String userId;
  final bool? isAttended;
  final String? lectureContent;
  final bool isAdditional;

  final int? level;
  final int? semester;

  const TimetableEntry({
    required this.id,
    required this.subject,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.userId,
    this.isAttended,
    this.lectureContent,
    this.isAdditional = false,
    this.level,
    this.semester,
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
      'isAttended': isAttended == null ? null : (isAttended! ? 1 : 0),
      'lectureContent': lectureContent,
      'isAdditional': isAdditional ? 1 : 0,
      'level': level,
      'semester': semester,
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
      isAttended: map['isAttended'] == null ? null : (map['isAttended'] as int == 1),
      lectureContent: map['lectureContent'] as String?,
      isAdditional: (map['isAdditional'] as int? ?? 0) == 1,
      level: map['level'] as int?,
      semester: map['semester'] as int?,
    );
  }

  @override
  String toString() =>
      'TimetableEntry($dayOfWeek $startTime–$endTime $subject @ $room, level: $level, sem: $semester)';
}
