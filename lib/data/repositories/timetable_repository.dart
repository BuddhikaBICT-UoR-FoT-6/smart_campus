// =============================================================================
// data/repositories/timetable_repository.dart
// =============================================================================
// CLEAN ARCHITECTURE — Data Layer (Repository Implementation)
//
// RESPONSIBILITY:
//   Acts as the bridge between the domain layer (use-cases) and the data
//   layer (DAO). The domain layer only calls the repository — it never
//   knows whether data comes from SQLite, an API, or a cache.
//
// VIVA POINT:
//   "The repository is like a data manager. The use-case says
//    'give me the timetable for user X' — the repository decides
//    WHERE to get it from. Right now it uses the local DAO."
// =============================================================================

import '../../data/local/timetable_dao.dart';
import '../../data/remote/mysql_timetable_dao.dart';
import '../../domain/models/timetable_entry.dart';
import 'package:flutter/foundation.dart';

class TimetableRepository {
  final TimetableDao _dao;
  final MysqlTimetableDao _mysqlDao = MysqlTimetableDao();

  TimetableRepository({TimetableDao? dao})
      : _dao = dao ?? TimetableDao();

  /// Delegates to [TimetableDao] to get all timetable entries for [userId].
  Future<List<TimetableEntry>> getTimetableForUser(String userId) async {
    try {
      final remoteEntries = await _mysqlDao.getEntriesForUser(userId);
      for (final entry in remoteEntries) {
        await _dao.insertEntryFromSync(entry);
      }
    } catch (e) {
      debugPrint('[TimetableRepository] Remote sync failed: $e');
    }
    return _dao.getEntriesForUser(userId);
  }

  Future<void> insertEntry(TimetableEntry entry) => _dao.insertEntry(entry);

  Future<void> updateEntry(TimetableEntry entry) => _dao.updateEntry(entry);

  Future<void> deleteEntry(String id) => _dao.deleteEntry(id);
}
