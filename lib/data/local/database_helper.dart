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
import '../../domain/models/announcement.dart';
import '../../domain/models/academic_result.dart';

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
  // Profile Update
  // ---------------------------------------------------------------------------

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
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
      version: 11,
      onCreate: _onCreate,
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 11) {
          // Destructive upgrade for easy academic demonstration
          await db.execute('DROP TABLE IF EXISTS announcements');
          await db.execute('DROP TABLE IF EXISTS registrations');
          await db.execute('DROP TABLE IF EXISTS events');
          await db.execute('DROP TABLE IF EXISTS timetable');
          await db.execute('DROP TABLE IF EXISTS users');
          await db.execute('DROP TABLE IF EXISTS academic_results');
          await db.execute('DROP TABLE IF EXISTS academic_calendar');
          await db.execute('DROP TABLE IF EXISTS medical_submissions');
          await db.execute('DROP TABLE IF EXISTS modules');
          await db.execute('DROP TABLE IF EXISTS module_enrollments');
          await db.execute('DROP TABLE IF EXISTS lms_materials');
          await _createTables(db);
          await _seedMockData(db);
        }
      },
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
        role  TEXT NOT NULL,
        address TEXT,
        emergencyName TEXT,
        emergencyPhone TEXT,
        profilePic TEXT,
        level INTEGER,
        semester INTEGER,
        isRepeat INTEGER DEFAULT 0
      )
    ''');

    // Table: academic_results
    await db.execute('''
      CREATE TABLE IF NOT EXISTS academic_results (
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        semester INTEGER NOT NULL,
        grade   TEXT NOT NULL,
        gpa     REAL NOT NULL,
        userId  TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    // Table: academic_calendar
    await db.execute('''
      CREATE TABLE IF NOT EXISTS academic_calendar (
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        number  INTEGER NOT NULL,
        label   TEXT NOT NULL,
        type    TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate   TEXT NOT NULL
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
        isAttended INTEGER,  -- 1 for yes, 0 for no, null for unknown
        lectureContent TEXT,
        isAdditional INTEGER DEFAULT 0,
        level INTEGER,
        semester INTEGER,
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
        organizer   TEXT NOT NULL,
        capacity    INTEGER DEFAULT 50
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

    // Table 5: announcements
    await db.execute('''
      CREATE TABLE IF NOT EXISTS announcements (
        id      INTEGER PRIMARY KEY,
        title   TEXT NOT NULL,
        body    TEXT NOT NULL,
        postedBy TEXT NOT NULL,
        date    TEXT NOT NULL
      )
    ''');

    // Table 6: academic_results
    await db.execute('''
      CREATE TABLE IF NOT EXISTS academic_results (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        subject  TEXT NOT NULL,
        semester INTEGER NOT NULL,
        grade    TEXT NOT NULL,
        gpa      REAL NOT NULL,
        userId   TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    // Table 7: academic_calendar
    await db.execute('''
      CREATE TABLE IF NOT EXISTS academic_calendar (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        weekNumber INTEGER NOT NULL,
        label     TEXT NOT NULL,
        type      TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate   TEXT NOT NULL
      )
    ''');

    // Table: medical_submissions
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medical_submissions (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        week INTEGER NOT NULL,
        date TEXT NOT NULL,
        photoPath TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Table: modules
    await db.execute('''
      CREATE TABLE IF NOT EXISTS modules (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        credits INTEGER NOT NULL,
        level INTEGER NOT NULL,
        semester INTEGER NOT NULL
      )
    ''');

    // Table: module_enrollments
    await db.execute('''
      CREATE TABLE IF NOT EXISTS module_enrollments (
        userId TEXT NOT NULL,
        moduleId TEXT NOT NULL,
        PRIMARY KEY (userId, moduleId),
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (moduleId) REFERENCES modules(id) ON DELETE CASCADE
      )
    ''');

    // Table: lms_materials
    await db.execute('''
      CREATE TABLE IF NOT EXISTS lms_materials (
        id TEXT PRIMARY KEY,
        moduleId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        fileUrl TEXT NOT NULL,
        type TEXT NOT NULL,
        deadline TEXT,
        FOREIGN KEY (moduleId) REFERENCES modules(id) ON DELETE CASCADE
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
    final users = [
      User(
        id: 'usr-001',
        name: 'Ashan Perera',
        email: 'student@campus.lk',
        role: UserRole.student,
        address: 'No 45, Flower Road, Colombo 07',
        emergencyName: 'Sumanasiri Perera (Father)',
        emergencyPhone: '0712345678',
      ),
      User(
        id: 'usr-002',
        name: 'Dr. Nilufar Silva',
        email: 'staff@campus.lk',
        role: UserRole.staff,
        address: 'Faculty of Engineering, UoR',
        emergencyName: 'Security Desk',
        emergencyPhone: '0412223334',
      ),
      User(
        id: 'usr-003',
        name: 'Campus Admin',
        email: 'admin@campus.lk',
        role: UserRole.superadmin,
        address: 'Administrative Block, UoR',
        emergencyName: 'Director Office',
        emergencyPhone: '0412224444',
      ),
    ];
    for (final u in users) {
      await db.insert('users', u.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // --- Full 5-Day Weekly Timetable (usr-001) ---
    final timetable = [
      // MONDAY
      TimetableEntry(
        id: 'tt-001',
        subject: 'Mobile Application Development',
        dayOfWeek: 'Monday',
        startTime: '08:00',
        endTime: '10:00',
        room: 'Lab 3',
        userId: 'usr-001',
        isAttended: true,
        lectureContent: 'Introduction to Flutter Architecture and Widgets.',
      ),
      // TUESDAY
      TimetableEntry(
        id: 'tt-002',
        subject: 'Software Engineering',
        dayOfWeek: 'Tuesday',
        startTime: '10:00',
        endTime: '12:00',
        room: 'LT 1',
        userId: 'usr-001',
        isAttended: false,
        lectureContent: 'Agile Methodologies and Scrum Framework.',
      ),
      // WEDNESDAY
      TimetableEntry(
        id: 'tt-003',
        subject: 'Database Management Systems',
        dayOfWeek: 'Wednesday',
        startTime: '13:00',
        endTime: '15:00',
        room: 'Lab 1',
        userId: 'usr-001',
        isAttended: true,
        lectureContent: 'Complex SQL queries and Indexing.',
      ),
      // THURSDAY
      TimetableEntry(
        id: 'tt-004',
        subject: 'Professional Practices',
        dayOfWeek: 'Thursday',
        startTime: '08:00',
        endTime: '10:00',
        room: 'Online',
        userId: 'usr-001',
        lectureContent: 'ethics in Information Technology.',
      ),
      // FRIDAY
      TimetableEntry(
        id: 'tt-005',
        subject: 'Computer Networks',
        dayOfWeek: 'Friday',
        startTime: '08:00',
        endTime: '10:00',
        room: 'LT 2',
        userId: 'usr-001',
        lectureContent: 'OSI Model and TCP/IP protocols.',
      ),
      // ADDITIONAL SESSIONS / MANDATORY EVENTS
      TimetableEntry(
        id: 'tt-006',
        subject: 'Industry Guest Lecture',
        dayOfWeek: 'Wednesday',
        startTime: '15:30',
        endTime: '17:00',
        room: 'Main Hall',
        userId: 'usr-001',
        isAdditional: true,
        lectureContent: 'Future of Quantum Computing by Google Experts.',
      ),
      TimetableEntry(
        id: 'tt-007',
        subject: 'Student Union Meeting',
        dayOfWeek: 'Friday',
        startTime: '13:00',
        endTime: '14:30',
        room: 'Annex A',
        userId: 'usr-001',
        isAdditional: true,
        lectureContent: 'Discussing annual campus festival roadmap.',
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
        capacity: 200,
      ),
      Event(
        id: 'evt-002',
        title: 'Tech Expo 2026',
        description: 'Annual exhibition of final-year engineering projects.',
        date: '2026-04-05',
        venue: 'Engineering Block, Level 2',
        organizer: 'Faculty of Technology',
        capacity: 300,
      ),
      Event(
        id: 'evt-003',
        title: 'Career Fair',
        description: 'Connect with top employers and explore internship opportunities.',
        date: '2026-05-20',
        venue: 'Sports Complex',
        organizer: 'Career Guidance Unit',
        capacity: 500,
      ),
    ];
    for (final event in events) {
      await db.insert('events', event.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // --- Academic Results (usr-001) ---
    final academic = [
      {'subject': 'Mathematics for Computing', 'semester': 1, 'grade': 'A', 'gpa': 4.0},
      {'subject': 'Programming Fundamentals', 'semester': 1, 'grade': 'A-', 'gpa': 3.7},
      {'subject': 'Information Systems', 'semester': 1, 'grade': 'B+', 'gpa': 3.3},
      {'subject': 'Database Systems', 'semester': 2, 'grade': 'A', 'gpa': 4.0},
      {'subject': 'Object Oriented Programming', 'semester': 2, 'grade': 'B', 'gpa': 3.0},
      {'subject': 'Software Engineering', 'semester': 2, 'grade': 'A-', 'gpa': 3.7},
      {'subject': 'Computer Networks', 'semester': 3, 'grade': 'B+', 'gpa': 3.3},
      {'subject': 'Operating Systems', 'semester': 3, 'grade': 'A', 'gpa': 4.0},
    ];
    for (final res in academic) {
      await db.insert('academic_results', {
        ...res,
        'userId': 'usr-001',
      });
    }

    // --- Academic Calendar 2026 (6 Months) ---
    final calendar = [
      {'number': 1, 'label': 'Week 01', 'type': 'academic', 'start': '2026-03-02', 'end': '2026-03-08'},
      {'number': 2, 'label': 'Week 02', 'type': 'academic', 'start': '2026-03-09', 'end': '2026-03-15'},
      {'number': 3, 'label': 'Week 03', 'type': 'academic', 'start': '2026-03-16', 'end': '2026-03-22'},
      {'number': 4, 'label': 'Week 04', 'type': 'academic', 'start': '2026-03-23', 'end': '2026-03-29'},
      {'number': 5, 'label': 'Week 05', 'type': 'academic', 'start': '2026-03-30', 'end': '2026-04-05'},
      {'number': 6, 'label': 'Week 06', 'type': 'academic', 'start': '2026-04-06', 'end': '2026-04-12'}, // CURRENT WEEK IS HERE
      {'number': 7, 'label': 'Vacation', 'type': 'vacation', 'start': '2026-04-13', 'end': '2026-04-19'},
      {'number': 8, 'label': 'Week 07', 'type': 'academic', 'start': '2026-04-20', 'end': '2026-04-26'},
      {'number': 9, 'label': 'Week 08', 'type': 'academic', 'start': '2026-04-27', 'end': '2026-05-03'},
      {'number': 10, 'label': 'Week 09', 'type': 'academic', 'start': '2026-05-04', 'end': '2026-05-10'},
      {'number': 11, 'label': 'Week 10', 'type': 'academic', 'start': '2026-05-11', 'end': '2026-05-17'},
      {'number': 12, 'label': 'Week 11', 'type': 'academic', 'start': '2026-05-18', 'end': '2026-05-24'},
      {'number': 13, 'label': 'Week 12', 'type': 'academic', 'start': '2026-05-25', 'end': '2026-05-31'},
      {'number': 14, 'label': 'Week 13', 'type': 'academic', 'start': '2026-06-01', 'end': '2026-06-07'},
      {'number': 15, 'label': 'Week 14', 'type': 'academic', 'start': '2026-06-08', 'end': '2026-06-14'},
      {'number': 16, 'label': 'Study Break', 'type': 'vacation', 'start': '2026-06-15', 'end': '2026-06-21'},
      {'number': 17, 'label': 'Exams Week 01', 'type': 'exam', 'start': '2026-06-22', 'end': '2026-06-28'},
      {'number': 18, 'label': 'Exams Week 02', 'type': 'exam', 'start': '2026-06-29', 'end': '2026-07-05'},
      {'number': 19, 'label': 'Vacation', 'type': 'vacation', 'start': '2026-07-06', 'end': '2026-07-12'},
      {'number': 20, 'label': 'Result release', 'type': 'result', 'start': '2026-07-13', 'end': '2026-07-19'},
    ];
    for (final c in calendar) {
      await db.insert('academic_calendar', {
        'number': c['number'],
        'label': c['label'],
        'type': c['type'],
        'startDate': c['start'],
        'endDate': c['end'],
      });
    }

    // --- 3 Announcements ---
    final announcementList = [
      Announcement(
        id: 101,
        title: 'University Convocation 2026',
        body: 'The annual convocation ceremony for all faculties is scheduled for July 15th.',
        postedBy: 'Registrar Office',
        date: '2026-03-28',
      ),
      Announcement(
        id: 102,
        title: 'Semester Results Published',
        body: 'Results for Semester I examinations are now available on the management system.',
        postedBy: 'Exam Dept',
        date: '2026-03-25',
      ),
      Announcement(
        id: 103,
        title: 'Workshop: AI in Industry',
        body: 'Join the Faculty of Technology for a guest lecture on Generative AI. Room 402.',
        postedBy: 'CS Dept',
        date: '2026-03-20',
      ),
    ];
    for (final a in announcementList) {
      await db.insert('announcements', a.toMap());
    }

    // --- Modules (Course Registration) ---
    final modules = [
      {'id': 'mod-001', 'code': 'SE101', 'name': 'Software Engineering', 'credits': 3, 'level': 1, 'semester': 1},
      {'id': 'mod-002', 'code': 'CS102', 'name': 'Computer Systems', 'credits': 3, 'level': 1, 'semester': 1},
      {'id': 'mod-003', 'code': 'MD201', 'name': 'Mobile Application Development', 'credits': 4, 'level': 4, 'semester': 1},
      {'id': 'mod-004', 'code': 'WD202', 'name': 'Web Technologies', 'credits': 3, 'level': 4, 'semester': 1},
      {'id': 'mod-005', 'code': 'AI301', 'name': 'Artificial Intelligence', 'credits': 4, 'level': 4, 'semester': 1},
    ];
    for (final m in modules) {
      await db.insert('modules', m, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // --- Module Enrollments (usr-001 is a Level 4 student, so enroll in some modules) ---
    final enrollments = [
      {'userId': 'usr-001', 'moduleId': 'mod-003'},
      {'userId': 'usr-001', 'moduleId': 'mod-004'},
    ];
    for (final e in enrollments) {
      await db.insert('module_enrollments', e, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // --- LMS Materials ---
    final lmsMaterials = [
      {'id': 'lms-001', 'moduleId': 'mod-003', 'title': 'Week 1: Intro to Flutter', 'description': 'Slides from the first lecture.', 'fileUrl': 'https://example.com/flutter_intro.pdf', 'type': 'pdf', 'deadline': null},
      {'id': 'lms-002', 'moduleId': 'mod-003', 'title': 'Assignment 1: UI Layouts', 'description': 'Build a basic profile screen.', 'fileUrl': 'https://example.com/assignment1.pdf', 'type': 'assignment', 'deadline': '2026-05-15'},
      {'id': 'lms-003', 'moduleId': 'mod-004', 'title': 'Week 1: HTML & CSS', 'description': 'Web layout fundamentals.', 'fileUrl': 'https://example.com/web_intro.pdf', 'type': 'pdf', 'deadline': null},
    ];
    for (final l in lmsMaterials) {
      await db.insert('lms_materials', l, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
