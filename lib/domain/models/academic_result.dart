// =============================================================================
// domain/models/academic_result.dart
// =============================================================================

class AcademicResult {
  final int? id;
  final String subject;
  final int semester;
  final String grade;
  final double gpa;
  final String userId;

  const AcademicResult({
    this.id,
    required this.subject,
    required this.semester,
    required this.grade,
    required this.gpa,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'semester': semester,
      'grade': grade,
      'gpa': gpa,
      'userId': userId,
    };
  }

  factory AcademicResult.fromMap(Map<String, dynamic> map) {
    return AcademicResult(
      id: map['id'] as int?,
      subject: map['subject'] as String,
      semester: map['semester'] as int,
      grade: map['grade'] as String,
      gpa: (map['gpa'] as num).toDouble(),
      userId: map['userId'] as String,
    );
  }
}
