// =============================================================================
// domain/models/academic_result.dart
// =============================================================================

class AcademicResult {
  final int? id;
  final String subject;
  final int level;
  final int semester;
  final int marks;
  final int credits;
  final String grade;
  final double gpa;
  final String userId;

  const AcademicResult({
    this.id,
    required this.subject,
    required this.level,
    required this.semester,
    required this.marks,
    required this.credits,
    required this.grade,
    required this.gpa,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'level': level,
      'semester': semester,
      'marks': marks,
      'credits': credits,
      'grade': grade,
      'gpa': gpa,
      'userId': userId,
    };
  }

  factory AcademicResult.fromMap(Map<String, dynamic> map) {
    return AcademicResult(
      id: map['id'] as int?,
      subject: map['subject'] as String,
      level: map['level'] as int? ?? 1,
      semester: map['semester'] as int,
      marks: map['marks'] as int? ?? 0,
      credits: map['credits'] as int? ?? 3,
      grade: map['grade'] as String,
      gpa: (map['gpa'] as num).toDouble(),
      userId: map['userId'] as String,
    );
  }
}
