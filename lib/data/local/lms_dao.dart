// =============================================================================
// data/local/lms_dao.dart
// =============================================================================

import '../../domain/models/lms_material.dart';
import 'database_helper.dart';

class LmsDao {
  final DatabaseHelper _dbHelper;

  LmsDao({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<LmsMaterial>> getMaterialsForModule(String moduleId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'lms_materials',
      where: 'moduleId = ?',
      whereArgs: [moduleId],
      orderBy: 'id ASC',
    );
    return rows.map((row) => LmsMaterial.fromMap(row)).toList();
  }

  Future<void> insertMaterial(LmsMaterial material) async {
    final db = await _dbHelper.database;
    await db.insert(
      'lms_materials',
      material.toMap(),
    );
  }
}
