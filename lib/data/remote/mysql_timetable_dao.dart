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
      isAttended: row['isAttended'] == null ? null : (row['isAttended'].toString() == '1'),
      lectureContent: row['lectureContent']?.toString(),
      isAdditional: row['isAdditional']?.toString() == '1',
      level: row['level'] != null ? int.tryParse(row['level'].toString()) : null,
      semester: row['semester'] != null ? int.tryParse(row['semester'].toString()) : null,
    )).toList();
  }
}
