// =============================================================================
// domain/usecases/get_timetable.dart
// =============================================================================
// CLEAN ARCHITECTURE — Domain Layer (Use-Case)
//
// RESPONSIBILITY:
//   A use-case is one specific business action the user can perform.
//   It sits between the UI (Provider) and the data layer (Repository).
//
// VIVA POINT:
//   "GetTimetable has one job: fetch the timetable for the logged-in user.
//    It doesn't care about SQLite or widgets. If we add caching later,
//    only the repository changes — this class stays the same."
// =============================================================================

import '../models/timetable_entry.dart';
import '../../data/repositories/timetable_repository.dart';

class GetTimetable {
  final TimetableRepository _repository;

  GetTimetable(this._repository);

  /// Executes the use-case.
  ///
  /// [userId] — the ID of the currently logged-in student.
  /// Returns a sorted list of that student's timetable entries.
  Future<List<TimetableEntry>> call(String userId) {
    return _repository.getTimetableForUser(userId);
  }
}
