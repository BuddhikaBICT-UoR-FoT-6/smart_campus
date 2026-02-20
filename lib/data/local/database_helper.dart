// =============================================================================
// data/local/database_helper.dart
// =============================================================================
// CLEAN ARCHITECTURE — Data Layer (Local)
//
// RESPONSIBILITY:
//   Owns the SQLite database lifecycle:
//     - Opening / creating the database file
//     - Defining all table schemas
//     - Seeding mock data on first run
//
// PATTERN USED:
//   Singleton — only ONE DatabaseHelper instance is created for the entire
//   app lifetime. This prevents concurrent writes and wasted file handles.
//
// VIVA POINT:
//   "We use sqflite for local storage. DatabaseHelper is a singleton that
//    creates 4 tables on first install. Mock data is inserted at that point
//    so the app works without any backend server."
// =============================================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../../domain/models/user.dart';
import '../../domain/models/timetable_entry.dart';
import '../../domain/models/event.dart';

class DatabaseHelper {
  // ---------------------------------------------------------------------------
  // Singleton setup
  // ---------------------------------------------------------------------------

  DatabaseHelper._internal(); // private constructor
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  /// Returns the open database, initialising it if necessary.
  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  Future<Database> _initDb() async {
    // getDatabasesPath() returns the correct path on both Android and iOS.
    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, 'smart_campus.db');

    return openDatabase(
      fullPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Called ONCE when the database is first created on the device.
  ///
  /// Creates all tables and seeds mock data so the app is immediately usable.
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedMockData(db);
  }

  // ---------------------------------------------------------------------------
  // Table creation
  // ---------------------------------------------------------------------------

  /// Creates the four tables that form the app's local database schema.
  ///
  /// Schema summary (ER in words):
  ///   - users          — primary entity
  ///   - timetable      — each row belongs to ONE user (userId FK)
  ///   - events         — independent entity, campus events
  ///   - registrations  — join table linking users ↔ events (many-to-many)
  Future<void> _createTables(Database db) async {
    // Table 1: users
    // Stores the two mock accounts (student + staff).
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id    TEXT PRIMARY KEY,
        name  TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        role  TEXT NOT NULL
      )
    ''');

    // Table 2: timetable
    // Each row is one class slot; userId links back to the users table.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS timetable (
        id        TEXT PRIMARY KEY,
        subject   TEXT NOT NULL,
        dayOfWeek TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime   TEXT NOT NULL,
        room      TEXT NOT NULL,
        userId    TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    // Table 3: events
    // Campus events that any user can view and register for.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS events (
        id          TEXT PRIMARY KEY,
        title       TEXT NOT NULL,
        description TEXT NOT NULL,
        date        TEXT NOT NULL,
        venue       TEXT NOT NULL,
        organizer   TEXT NOT NULL
      )
    ''');

    // Table 4: registrations
    // Join table. One row = one student registered for one event.
    // The combination of (userId, eventId) is unique (no double-booking).
    await db.execute('''
      CREATE TABLE IF NOT EXISTS registrations (
        id      TEXT PRIMARY KEY,
        userId  TEXT NOT NULL,
        eventId TEXT NOT NULL,
        FOREIGN KEY (userId)  REFERENCES users(id),
        FOREIGN KEY (eventId) REFERENCES events(id),
        UNIQUE (userId, eventId)
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // Mock data seeding
  // ---------------------------------------------------------------------------

  /// Inserts realistic mock data so the app can be demonstrated immediately.
  ///
  /// Credentials (for login screen):
  ///   student@campus.lk / 1234   → role: student
  ///   staff@campus.lk   / 1234   → role: staff
  Future<void> _seedMockData(Database db) async {
    // --- 2 Mock Users ---
    final users = [
      User(
        id: 'usr-001',
        name: 'Ashan Perera',
        email: 'student@campus.lk',
        role: UserRole.student,
      ),
      User(
        id: 'usr-002',
        name: 'Dr. Nilufar Silva',
        email: 'staff@campus.lk',
        role: UserRole.staff,
      ),
    ];
    for (final u in users) {
      await db.insert('users', u.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // --- 4 Timetable Rows (for the student account) ---
    final timetable = [
      TimetableEntry(
        id: 'tt-001',
        subject: 'Mobile Application Development',
        dayOfWeek: 'Monday',
        startTime: '08:00',
        endTime: '10:00',
        room: 'Lab 3',
        userId: 'usr-001',
      ),
      TimetableEntry(
        id: 'tt-002',
        subject: 'Software Engineering',
        dayOfWeek: 'Tuesday',
        startTime: '10:00',
        endTime: '12:00',
        room: 'LT 1',
        userId: 'usr-001',
      ),
      TimetableEntry(
        id: 'tt-003',
        subject: 'Database Systems',
        dayOfWeek: 'Wednesday',
        startTime: '13:00',
        endTime: '15:00',
        room: 'Lab 1',
        userId: 'usr-001',
      ),
      TimetableEntry(
        id: 'tt-004',
        subject: 'Computer Networks',
        dayOfWeek: 'Friday',
        startTime: '08:00',
        endTime: '10:00',
        room: 'LT 2',
        userId: 'usr-001',
      ),
    ];
    for (final entry in timetable) {
      await db.insert('timetable', entry.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // --- 3 Campus Events ---
    final events = [
      Event(
        id: 'evt-001',
        title: "Freshers' Welcome Day",
        description: 'Official welcome ceremony for new undergraduate students.',
        date: '2026-03-10',
        venue: 'Main Auditorium',
        organizer: 'Student Affairs',
      ),
      Event(
        id: 'evt-002',
        title: 'Tech Expo 2026',
        description: 'Annual exhibition of final-year engineering projects.',
        date: '2026-04-05',
        venue: 'Engineering Block, Level 2',
        organizer: 'Faculty of Technology',
      ),
      Event(
        id: 'evt-003',
        title: 'Career Fair',
        description: 'Connect with top employers and explore internship opportunities.',
        date: '2026-05-20',
        venue: 'Sports Complex',
        organizer: 'Career Guidance Unit',
      ),
    ];
    for (final event in events) {
      await db.insert('events', event.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
