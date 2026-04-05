// =============================================================================
// data/local/module_dao.dart
// =============================================================================

import 'package:sqflite/sqflite.dart';
import '../../domain/models/module.dart';
import 'database_helper.dart';

class ModuleDao {
  final DatabaseHelper _dbHelper;

  ModuleDao({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<Module>> getAllModules() async {
    final db = await _dbHelper.database;
    final rows = await db.query('modules', orderBy: 'level ASC, semester ASC');
    return rows.map((row) => Module.fromMap(row)).toList();
  }

  Future<List<Module>> getEnrolledModules(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT m.* FROM modules m
      INNER JOIN module_enrollments e ON m.id = e.moduleId
      WHERE e.userId = ?
      ORDER BY m.level ASC, m.semester ASC
    ''', [userId]);
    return rows.map((row) => Module.fromMap(row)).toList();
  }

  Future<void> enrollModule(String userId, String moduleId) async {
    final db = await _dbHelper.database;
    await db.insert(
      'module_enrollments',
      {'userId': userId, 'moduleId': moduleId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> dropModule(String userId, String moduleId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'module_enrollments',
      where: 'userId = ? AND moduleId = ?',
      whereArgs: [userId, moduleId],
    );
  }

  Future<void> insertModule(Module module) async {
    final db = await _dbHelper.database;
    await db.insert(
      'modules',
      module.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteModule(String moduleId) async {
    final db = await _dbHelper.database;
    // Also delete enrollments for this module to maintain integrity
    await db.delete('module_enrollments', where: 'moduleId = ?', whereArgs: [moduleId]);
    await db.delete('modules', where: 'id = ?', whereArgs: [moduleId]);
  }
}
