// =============================================================================
// domain/models/user.dart
// =============================================================================
// CLEAN ARCHITECTURE — Domain Layer
//
// This file is intentionally kept free of ANY Flutter or package imports.
// The domain layer is pure Dart — it knows nothing about SQLite, HTTP, or UI.
//
// VIVA POINT:
//   "User is a plain Dart class. It defines what a user IS in our system.
//    The data layer handles HOW to store it; this class just holds the shape."
// =============================================================================

/// Represents the two roles a person can have in the campus system.
///
/// Using an enum instead of a raw String prevents typos like "studdent"
/// and makes role-checking readable: `user.role == UserRole.staff`.
enum UserRole { student, staff }

/// Domain entity representing an authenticated campus user.
///
/// - [id]    Unique identifier (UUID-style string so it works in SQLite)
/// - [name]  Display name shown in the app
/// - [email] Used as the login credential
/// - [role]  Either student or staff — drives which screens are visible
class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // ---------------------------------------------------------------------------
  // SQLite helpers
  // ---------------------------------------------------------------------------

  /// Converts this User to a Map so SQLite's `insert()` / `update()` can use it.
  ///
  /// SQLite has no enum type, so UserRole is stored as a plain String.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name, // e.g. "student" or "staff"
    };
  }

  /// Rebuilds a User from a SQLite row Map.
  ///
  /// `UserRole.values.byName()` converts the stored String back to the enum.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.values.byName(map['role'] as String),
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, role: ${role.name})';
}
