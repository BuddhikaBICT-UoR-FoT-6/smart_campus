// =============================================================================
// domain/models/lms_material.dart
// =============================================================================

class LmsMaterial {
  final String id;
  final String moduleId;
  final String title;
  final String description;
  final String fileUrl;
  final String type; // 'pdf', 'assignment'
  final String? deadline;

  const LmsMaterial({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.type,
    this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moduleId': moduleId,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'type': type,
      'deadline': deadline,
    };
  }

  factory LmsMaterial.fromMap(Map<String, dynamic> map) {
    return LmsMaterial(
      id: map['id'] as String,
      moduleId: map['moduleId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      fileUrl: map['fileUrl'] as String,
      type: map['type'] as String,
      deadline: map['deadline'] as String?,
    );
  }
}
