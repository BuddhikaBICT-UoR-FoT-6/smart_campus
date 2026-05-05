import '../models/timetable_entry.dart';
import '../../data/repositories/timetable_repository.dart';

class GetTimetable {
  final TimetableRepository _repository;

  GetTimetable(this._repository);

  Future<List<TimetableEntry>> call(String userId) {
    return _repository.getTimetableForUser(userId);
  }
}
