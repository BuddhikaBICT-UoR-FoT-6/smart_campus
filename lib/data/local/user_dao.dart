import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../domain/models/user.dart';
import '../remote/mysql_sync_helper.dart';
import '../../utils/security_helper.dart';

class UserDao {
  final DatabaseHelper _dbHelper;

  UserDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<User>> getAllUsers() async {
    final db = await _dbHelper.database;
    final rows = await db.query('users', orderBy: 'name ASC');
    return rows.map((row) => User.fromMap(row)).toList();
  }

  Future<void> insertUser(User user) async {
    final db = await _dbHelper.database;
    // Apply default password if not provided
    final rawPassword = (user.password == null || user.password!.isEmpty) ? '1234' : user.password!;
    final hashed = SecurityHelper.hashPassword(rawPassword);
    
    final userWithPassword = user.copyWith(password: hashed);
        
    await db.insert(
      'users',
      userWithPassword.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Background Sync
    MySqlSyncHelper.syncUserInsert(userWithPassword);
  }

  Future<void> updateUser(User user) async {
    final db = await _dbHelper.database;
    
    // Convert to map and remove password if it's null to avoid overwriting existing password
    final data = user.toMap();
    if (user.password == null) {
      data.remove('password');
    }

    await db.update(
      'users',
      data,
      where: 'id = ?',
      whereArgs: [user.id],
    );
    // Background Sync
    MySqlSyncHelper.syncUserInsert(user);
  }

  Future<void> deleteUser(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Background Sync
    MySqlSyncHelper.syncUserDelete(id);
  }

  Future<void> suspendUser(String id, bool suspend) async {
    final db = await _dbHelper.database;
    // For simplicity, we'll just prefix the email with 'suspended_' or use a column if we add it.
    // Let's assume we might add a 'isSuspended' column in the future.
    // For now, we'll just update the name to include [SUSPENDED].
    final user = await getUserById(id);
    if (user != null) {
      final newName = suspend 
        ? (user.name.contains('[SUSPENDED]') ? user.name : '${user.name} [SUSPENDED]')
        : user.name.replaceFirst(' [SUSPENDED]', '');
      await db.update('users', {'name': newName}, where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<User?> getUserById(String id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<void> resetPassword(String id, String newPassword) async {
    final db = await _dbHelper.database;
    final hashed = SecurityHelper.hashPassword(newPassword);
    await db.update(
      'users',
      {'password': hashed},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
