// =============================================================================
// domain/models/academic_result.dart
// =============================================================================

class AcademicResult {
  final String subject;
  final int semester;
  final String grade;
  final double gpa;

  const AcademicResult({
    required this.subject,
    required this.semester,
    required this.grade,
    required this.gpa,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'semester': semester,
      'grade': grade,
      'gpa': gpa,
    };
  }

  factory AcademicResult.fromMap(Map<String, dynamic> map) {
    return AcademicResult(
      subject: map['subject'] as String,
      semester: map['semester'] as int,
      grade: map['grade'] as String,
      gpa: (map['gpa'] as num).toDouble(),
    );
  }
}
