import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../domain/models/academic_result.dart';

class ResultDao {
  final DatabaseHelper _dbHelper;

  ResultDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<AcademicResult>> getResultsForUser(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'academic_results',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return rows.map((row) => AcademicResult.fromMap(row)).toList();
  }

  Future<List<AcademicResult>> getAllResults() async {
    final db = await _dbHelper.database;
    final rows = await db.query('academic_results');
    return rows.map((row) => AcademicResult.fromMap(row)).toList();
  }

  Future<void> insertResult(AcademicResult result) async {
    final db = await _dbHelper.database;
    await db.insert(
      'academic_results',
      result.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateResult(AcademicResult result) async {
    final db = await _dbHelper.database;
    await db.update(
      'academic_results',
      result.toMap(),
      where: 'id = ?',
      whereArgs: [result.id],
    );
  }

  Future<void> deleteResult(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'academic_results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
