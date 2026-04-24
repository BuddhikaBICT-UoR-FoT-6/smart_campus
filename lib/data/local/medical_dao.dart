import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../domain/models/medical_submission.dart';
import '../remote/mysql_sync_helper.dart';

class MedicalDao {
  final DatabaseHelper _dbHelper;

  MedicalDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<MedicalSubmission>> getAllSubmissions() async {
    final db = await _dbHelper.database;
    final rows = await db.query('medical_submissions');
    return rows.map((row) => MedicalSubmission.fromMap(row)).toList();
  }

  Future<List<MedicalSubmission>> getSubmissionsForUser(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'medical_submissions',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return rows.map((row) => MedicalSubmission.fromMap(row)).toList();
  }

  Future<void> insertSubmission(MedicalSubmission submission) async {
    final db = await _dbHelper.database;
    await db.insert(
      'medical_submissions',
      submission.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Background Sync
    MySqlSyncHelper.syncMedicalSubmissionInsert(submission);
  }

  Future<void> updateSubmissionStatus(String id, String status) async {
    final db = await _dbHelper.database;
    await db.update(
      'medical_submissions',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
    // Get the updated submission to sync
    final rows = await db.query('medical_submissions', where: 'id = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      final updated = MedicalSubmission.fromMap(rows.first);
      MySqlSyncHelper.syncMedicalSubmissionInsert(updated);
    }
  }
}
