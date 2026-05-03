// =============================================================================
// data/local/campus_contact_dao.dart
// =============================================================================

import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../domain/models/campus_contact.dart';

class CampusContactDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<CampusContact>> getAllContacts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('campus_contacts');
    return List.generate(maps.length, (i) => CampusContact.fromMap(maps[i]));
  }

  Future<void> insertContact(CampusContact contact) async {
    final db = await _dbHelper.database;
    await db.insert(
      'campus_contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateContact(CampusContact contact) async {
    final db = await _dbHelper.database;
    await db.update(
      'campus_contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<void> deleteContact(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'campus_contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
