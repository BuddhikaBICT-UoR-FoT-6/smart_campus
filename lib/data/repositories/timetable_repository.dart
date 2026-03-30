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
import '../../domain/models/timetable_entry.dart';

class TimetableRepository {
  final TimetableDao _dao;

  TimetableRepository({TimetableDao? dao})
      : _dao = dao ?? TimetableDao();

  /// Delegates to [TimetableDao] to get all timetable entries for [userId].
  Future<List<TimetableEntry>> getTimetableForUser(String userId) {
    return _dao.getEntriesForUser(userId);
  }

  Future<void> insertEntry(TimetableEntry entry) => _dao.insertEntry(entry);

  Future<void> updateEntry(TimetableEntry entry) => _dao.updateEntry(entry);

  Future<void> deleteEntry(String id) => _dao.deleteEntry(id);
}
}
