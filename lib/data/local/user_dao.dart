import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../domain/models/user.dart';

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
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUser(User user) async {
    final db = await _dbHelper.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
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
}
