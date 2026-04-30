// =============================================================================
// data/local/timetable_dao.dart
// =============================================================================
// CLEAN ARCHITECTURE — Data Layer (Local)
//
// RESPONSIBILITY:
//   DAO = Data Access Object. This class is the ONLY place in the app
//   that writes raw SQL-style queries for the timetable table.
//
// VIVA POINT:
//   "The DAO pattern encapsulates all database access for one table.
//    If we later change how we store timetables, only this file changes —
//    the rest of the app stays the same."
// =============================================================================

import 'package:sqflite/sqflite.dart';

import '../local/database_helper.dart';
import '../../domain/models/timetable_entry.dart';
import '../remote/mysql_sync_helper.dart';

class TimetableDao {
  final DatabaseHelper _dbHelper;

  TimetableDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Returns all timetable entries that belong to the given [userId].
  ///
  /// Used by [TimetableRepository] → [GetTimetable] use-case → UI.
  Future<List<TimetableEntry>> getEntriesForUser(String userId) async {
    final db = await _dbHelper.database;

    final rows = await db.query(
      'timetable',
      where: 'userId = ? OR userId = ?',
      whereArgs: [userId, 'all'],
      orderBy: 'dayOfWeek ASC, startTime ASC', // deterministic sort order
    );

    // Convert each raw Map row into a typed TimetableEntry domain object.
    return rows.map((row) => TimetableEntry.fromMap(row)).toList();
  }

  // ---------------------------------------------------------------------------
  // Write (for completeness — seeding / future admin use)
  // ---------------------------------------------------------------------------

  /// Inserts a new timetable entry from sync without triggering remote push again.
  Future<void> insertEntryFromSync(TimetableEntry entry) async {
    final db = await _dbHelper.database;
    await db.insert(
      'timetable',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Inserts a new timetable entry. Ignores duplicates (same primary key).
  Future<void> insertEntry(TimetableEntry entry) async {
    final db = await _dbHelper.database;
    await db.insert(
      'timetable',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    // Background Sync
    MySqlSyncHelper.syncTimetableInsert(entry);
  }

  Future<void> updateEntry(TimetableEntry entry) async {
    final db = await _dbHelper.database;
    await db.update(
      'timetable',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
    // Background Sync
    MySqlSyncHelper.syncTimetableInsert(entry);
  }

  Future<void> deleteEntry(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'timetable',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Background Sync
    MySqlSyncHelper.syncTimetableDelete(id);
  }
}
