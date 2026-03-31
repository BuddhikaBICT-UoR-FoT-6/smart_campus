// =============================================================================
// data/remote/mysql_announcement_dao.dart
// =============================================================================

import '../../domain/models/announcement.dart';
import 'mysql_database.dart';

class MysqlAnnouncementDao {
  Future<List<Announcement>> getAnnouncements() async {
    final conn = await MySqlDatabase.getConnection();
    final results = await conn.query('SELECT * FROM announcements ORDER BY date DESC');
    
    return results.map((row) => Announcement(
      id: row['id'] is int ? row['id'] as int : int.tryParse(row['id'].toString()) ?? 0,
      title: row['title'].toString(),
      body: row['body'].toString(),
      postedBy: row['postedBy'].toString(),
      date: row['date'].toString(),
    )).toList();
  }

  Future<void> addAnnouncement(String title, String body, String posterName) async {
    final conn = await MySqlDatabase.getConnection();
    
    // Auto-generate numeric ID equivalent for announcements mimicking legacy system
    final newId = DateTime.now().millisecondsSinceEpoch % 100000;
    final date = DateTime.now().toIso8601String().split('T').first;

    await conn.query(
      'INSERT INTO announcements (id, title, body, postedBy, date) VALUES (?, ?, ?, ?, ?)',
      [newId.toString(), title, body, posterName, date],
    );
  }
}
