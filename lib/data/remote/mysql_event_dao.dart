// =============================================================================
// data/remote/mysql_event_dao.dart
// =============================================================================

import '../../domain/models/event.dart';
import 'mysql_database.dart';

class MysqlEventDao {
  Future<List<Event>> getAllEvents() async {
    final conn = await MySqlDatabase.getConnection();
    final results = await conn.query('SELECT * FROM events');
    
    return results.map((row) => Event(
      id: row['id'].toString(),
      title: row['title'].toString(),
      description: row['description'].toString(),
      date: row['date'].toString(),
      venue: row['venue'].toString(),
      organizer: row['organizer'].toString(),
    )).toList();
  }

  Future<void> registerForEvent(String userId, String eventId) async {
    final conn = await MySqlDatabase.getConnection();
    await conn.query(
      'INSERT INTO user_events (userId, eventId) VALUES (?, ?)',
      [userId, eventId],
    );
  }

  Future<bool> isRegistered(String userId, String eventId) async {
    final conn = await MySqlDatabase.getConnection();
    final results = await conn.query(
      'SELECT 1 FROM user_events WHERE userId = ? AND eventId = ?',
      [userId, eventId],
    );
    return results.isNotEmpty;
  }

  Future<Set<String>> getRegisteredEventIds(String userId) async {
    final conn = await MySqlDatabase.getConnection();
    final results = await conn.query(
      'SELECT eventId FROM user_events WHERE userId = ?',
      [userId],
    );
    // Explicitly mapping native rows utilizing indexing over map allocations
    return results.map((row) => row[0].toString()).toSet();
  }
}
