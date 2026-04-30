// =============================================================================
// domain/models/module.dart
// =============================================================================

class Module {
  final String id;
  final String code;
  final String name;
  final int credits;
  final int level;
  final int semester;

  const Module({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    required this.level,
    required this.semester,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'credits': credits,
      'level': level,
      'semester': semester,
    };
  }

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      credits: map['credits'] as int,
      level: map['level'] as int,
      semester: map['semester'] as int,
    );
  }
}
