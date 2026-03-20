// =============================================================================
// data/remote/mysql_timetable_dao.dart
// =============================================================================

import '../../domain/models/timetable_entry.dart';
import 'mysql_database.dart';

class MysqlTimetableDao {
  Future<List<TimetableEntry>> getEntriesForUser(String userId) async {
    final conn = await MySqlDatabase.getConnection();
    
    // We utilize SQL parameterized querying (?) to prevent SQL injection payloads
    final results = await conn.query(
      'SELECT * FROM timetable WHERE userId = ?', 
      [userId]
    );
    
    // Force raw typecasting to string explicitly mapping the native MySQL driver rows
    return results.map((row) => TimetableEntry(
      id: row['id'].toString(),
      subject: row['subject'].toString(),
      dayOfWeek: row['dayOfWeek'].toString(),
      startTime: row['startTime'].toString(),
      endTime: row['endTime'].toString(),
      room: row['room'].toString(),
      userId: row['userId'].toString(),
    )).toList();
  }
}
