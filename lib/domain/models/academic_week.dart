// =============================================================================
// domain/models/academic_week.dart
// =============================================================================

enum WeekType { academic, vacation, exam, result }

class AcademicWeek {
  final int number;
  final String label;
  final WeekType type;
  final DateTime startDate;
  final DateTime endDate;

  const AcademicWeek({
    required this.number,
    required this.label,
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'label': label,
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory AcademicWeek.fromMap(Map<String, dynamic> map) {
    return AcademicWeek(
      number: map['number'] as int,
      label: map['label'] as String,
      type: WeekType.values.byName(map['type'] as String),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
    );
  }
}
