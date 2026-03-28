// =============================================================================
// data/remote/mysql_auth_dao.dart
// =============================================================================

import 'package:flutter/foundation.dart';
import '../../domain/models/user.dart';
import 'mysql_database.dart';

class MysqlAuthDao {
  /// Queries MySQL to definitively authenticate a user.
  /// Returns a valid [User] if credentials strictly match, otherwise throws or returns null.
  Future<User?> authenticate(String email, String password) async {
    final conn = await MySqlDatabase.getConnection();
    
    // We utilize strictly parameterized bounds to prevent SQL Injection
    final results = await conn.query(
      'SELECT id, name, email, role FROM users WHERE email = ? AND password = ?', 
      [email, password]
    );

    if (results.isEmpty) {
      debugPrint('[MysqlAuthDao] Secure rejection: Invalid credentials for $email.');
      return null;
    }

    // Explicitly parse native driver responses mapping to structural User
    final row = results.first;
    
    // Convert primitive native string DB structures to Domain architectural Enums
    final roleString = row['role'].toString().toLowerCase();
    final userRole = roleString == 'staff' ? UserRole.staff : UserRole.student;

    return User(
      id: row['id'].toString(),
      name: row['name'].toString(),
      email: row['email'].toString(),
      role: userRole,
    );
  }
}
