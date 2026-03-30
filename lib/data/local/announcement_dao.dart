import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../domain/models/announcement.dart';

class AnnouncementDao {
  final DatabaseHelper _dbHelper;

  AnnouncementDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<Announcement>> getAllAnnouncements() async {
    final db = await _dbHelper.database;
    final rows = await db.query('announcements', orderBy: 'id DESC');
    return rows.map((row) => Announcement.fromMap(row)).toList();
  }

  Future<void> insertAnnouncement(Announcement announcement) async {
    final db = await _dbHelper.database;
    await db.insert(
      'announcements',
      announcement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    final db = await _dbHelper.database;
    await db.update(
      'announcements',
      announcement.toMap(),
      where: 'id = ?',
      whereArgs: [announcement.id],
    );
  }

  Future<void> deleteAnnouncement(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'announcements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
