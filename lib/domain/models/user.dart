// =============================================================================
// domain/models/user.dart
// =============================================================================
// CLEAN ARCHITECTURE — Domain Layer
// =============================================================================

/// Represents the two roles a person can have in the campus system.
enum UserRole { student, staff, superadmin }

/// Domain entity representing an authenticated campus user.
class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? address;
  final String? emergencyName;
  final String? emergencyPhone;
  final String? profilePic;

  final int? level;
  final int? semester;
  final bool isRepeat;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.address,
    this.emergencyName,
    this.emergencyPhone,
    this.profilePic,
    this.level,
    this.semester,
    this.isRepeat = false,
  });

  // ---------------------------------------------------------------------------
  // SQLite helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'address': address,
      'emergencyName': emergencyName,
      'emergencyPhone': emergencyPhone,
      'profilePic': profilePic,
      'level': level,
      'semester': semester,
      'isRepeat': isRepeat ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.values.byName(map['role'] as String),
      address: map['address'] as String?,
      emergencyName: map['emergencyName'] as String?,
      emergencyPhone: map['emergencyPhone'] as String?,
      profilePic: map['profilePic'] as String?,
      level: map['level'] as int?,
      semester: map['semester'] as int?,
      isRepeat: (map['isRepeat'] as int? ?? 0) == 1,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, role: ${role.name}, level: $level, semester: $semester, isRepeat: $isRepeat)';

  User copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? address,
    String? emergencyName,
    String? emergencyPhone,
    String? profilePic,
    int? level,
    int? semester,
    bool? isRepeat,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      address: address ?? this.address,
      emergencyName: emergencyName ?? this.emergencyName,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      profilePic: profilePic ?? this.profilePic,
      level: level ?? this.level,
      semester: semester ?? this.semester,
      isRepeat: isRepeat ?? this.isRepeat,
    );
  }
}
