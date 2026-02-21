// =============================================================================
// data/local/event_dao.dart
// =============================================================================
// CLEAN ARCHITECTURE — Data Layer (Local)
//
// RESPONSIBILITY:
//   All SQLite access for the 'events' and 'registrations' tables.
//
// VIVA POINT:
//   "Event DAO handles two tables. It checks if a student is already
//    registered before inserting a new registration row — preventing
//    duplicates at the database level using a UNIQUE constraint."
// =============================================================================

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart' as uuid_pkg;

import '../local/database_helper.dart';
import '../../domain/models/event.dart';

class EventDao {
  final DatabaseHelper _dbHelper;
  final uuid_pkg.Uuid _uuid;

  EventDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _uuid = const uuid_pkg.Uuid();

  // ---------------------------------------------------------------------------
  // Events — Read
  // ---------------------------------------------------------------------------

  /// Returns ALL campus events from the local database.
  ///
  /// Events are seeded at first run by DatabaseHelper, so this always
  /// returns data even when offline.
  Future<List<Event>> getAllEvents() async {
    final db = await _dbHelper.database;
    final rows = await db.query('events', orderBy: 'date ASC');
    return rows.map((row) => Event.fromMap(row)).toList();
  }

  // ---------------------------------------------------------------------------
  // Registrations — Read
  // ---------------------------------------------------------------------------

  /// Returns true if [userId] has already registered for [eventId].
  ///
  /// Used by the UI to toggle the "Register" button to "Registered ✓".
  Future<bool> isRegistered(String userId, String eventId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'registrations',
      where: 'userId = ? AND eventId = ?',
      whereArgs: [userId, eventId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Returns the IDs of all events the [userId] has registered for.
  ///
  /// Used by [EventProvider] on startup to pre-populate the registered set.
  Future<Set<String>> getRegisteredEventIds(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'registrations',
      columns: ['eventId'],
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return rows.map((r) => r['eventId'] as String).toSet();
  }

  // ---------------------------------------------------------------------------
  // Registrations — Write
  // ---------------------------------------------------------------------------

  /// Registers [userId] for [eventId].
  ///
  /// Uses ConflictAlgorithm.ignore so calling this twice does nothing harmful
  /// (the UNIQUE constraint on (userId, eventId) prevents duplicate rows).
  Future<void> registerForEvent(String userId, String eventId) async {
    final db = await _dbHelper.database;
    await db.insert(
      'registrations',
      {
        'id': _uuid.v4(),       // auto-generate a unique registration ID
        'userId': userId,
        'eventId': eventId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}
