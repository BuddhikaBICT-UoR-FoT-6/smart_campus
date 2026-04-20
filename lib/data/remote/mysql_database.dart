// =============================================================================
// data/remote/mysql_database.dart
// =============================================================================
// DATA ACCESS LAYER
//
// RESPONSIBILITY:
//   Establishes direct native TCP connections to a remote MySQL server instance.
//   *NOTE:* Direct DB connections from mobile clients violate Zero-Trust 
//   production rules, but was explicitly configured here per the assessment spec.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:mysql1/mysql1.dart';

class MySqlDatabase {
  // 1. Maintain a singleton pattern to prevent socket exhaustion on the DB Server
  static MySqlConnection? _connection;

  // 2. Centralized connection routing to the database
  static Future<MySqlConnection> getConnection() async {
    if (_connection != null) return _connection!;

    final settings = ConnectionSettings(
      host: '10.0.2.2', 
      port: 3306,
      user: 'root',
      password: '', 
      timeout: const Duration(seconds: 10),
    );

    try {
      _connection = await MySqlConnection.connect(settings);
      
      // 1. Create and select DB dynamically
      await _connection!.query('CREATE DATABASE IF NOT EXISTS smart_campus_db');
      await _connection!.query('USE smart_campus_db');

      // 2. Setup structural schemas
      await _createTables();
      
      // 3. Populate default records
      await _seedMockData();

      debugPrint('[MySQL] Connection & schema preparation successfully established.');
      return _connection!;
    } catch (e) {
      debugPrint('[MySQL] FATAL SOCKET ERROR: $e');
      rethrow;
    }
  }

  static Future<void> _createTables() async {
    await _connection!.query('''
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(50) PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        role ENUM('student', 'staff', 'superadmin') NOT NULL,
        address TEXT,
        emergencyName TEXT,
        emergencyPhone TEXT,
        profilePic TEXT,
        level INT,
        semester INT,
        isRepeat BOOLEAN DEFAULT FALSE
      )
    ''');

    await _connection!.query('''
      CREATE TABLE IF NOT EXISTS timetable (
        id VARCHAR(50) PRIMARY KEY,
        subject VARCHAR(100) NOT NULL,
        dayOfWeek VARCHAR(20) NOT NULL,
        startTime VARCHAR(10) NOT NULL,
        endTime VARCHAR(10) NOT NULL,
        room VARCHAR(50) NOT NULL,
        userId VARCHAR(50) NOT NULL,
        isAttended BOOLEAN DEFAULT FALSE,
        isAdditional BOOLEAN DEFAULT FALSE,
        lectureContent TEXT,
        level INT,
        semester INT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await _connection!.query('''
      CREATE TABLE IF NOT EXISTS academic_calendar (
        id INT PRIMARY KEY AUTO_INCREMENT,
        number INT NOT NULL,
        label VARCHAR(100) NOT NULL,
        type VARCHAR(50) NOT NULL,
        startDate VARCHAR(50) NOT NULL,
        endDate VARCHAR(50) NOT NULL
      )
    ''');

    await _connection!.query('''
      CREATE TABLE IF NOT EXISTS academic_results (
        id INT PRIMARY KEY AUTO_INCREMENT,
        subject VARCHAR(100) NOT NULL,
        semester INT NOT NULL,
        grade VARCHAR(5) NOT NULL,
        gpa REAL NOT NULL,
        userId VARCHAR(50) NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await _connection!.query('''
      CREATE TABLE IF NOT EXISTS events (
        id VARCHAR(50) PRIMARY KEY,
        title VARCHAR(150) NOT NULL,
        description TEXT,
        date VARCHAR(50) NOT NULL,
        venue VARCHAR(100) NOT NULL,
        organizer VARCHAR(100) NOT NULL,
        capacity INT DEFAULT 50
      )
    ''');

    await _connection!.query('''
      CREATE TABLE IF NOT EXISTS user_events (
        userId VARCHAR(50),
        eventId VARCHAR(50),
        PRIMARY KEY (userId, eventId),
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (eventId) REFERENCES events(id) ON DELETE CASCADE
      )
    ''');

    await _connection!.query('''
      CREATE TABLE IF NOT EXISTS announcements (
        id VARCHAR(50) PRIMARY KEY,
        title VARCHAR(200) NOT NULL,
        body TEXT,
        postedBy VARCHAR(100),
        date VARCHAR(50)
      )
    ''');

    await _connection!.query('''
      CREATE TABLE IF NOT EXISTS medical_submissions (
        id VARCHAR(50) PRIMARY KEY,
        userId VARCHAR(50) NOT NULL,
        week INT NOT NULL,
        date VARCHAR(50) NOT NULL,
        photoPath VARCHAR(255) NOT NULL,
        status VARCHAR(20) NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _seedMockData() async {
    final usersCount = await _connection!.query('SELECT COUNT(*) FROM users');
    if (usersCount.first[0] == 0) {
      await _connection!.query('''
        INSERT INTO users (id, name, email, password, role, address, emergencyName, emergencyPhone) VALUES 
        ('usr-000', 'Super Admin', 'admin@campus.lk', '1234', 'superadmin', 'Administrative Block, UoR', 'Director Office', '0412224444'),
        ('usr-001', 'Ashan Perera', 'student@campus.lk', '1234', 'student', 'No 45, Flower Road, Colombo 07', 'Sumanasiri Perera (Father)', '0712345678'),
        ('usr-002', 'Dr. Nilufar Silva', 'staff@campus.lk', '1234', 'staff', 'Faculty of Engineering, UoR', 'Security Desk', '0412223334')
      ''');
      
      await _connection!.query('''
        INSERT INTO announcements (id, title, body, postedBy, date) VALUES 
        ('ann-001', 'Campus Closed on Friday', 'Due to extreme weather, campus is closed.', 'Admin', '2026-04-01'),
        ('ann-002', 'Exam Results Released', 'Log in to the LMS to view your final semester results.', 'Exam Branch', '2026-04-02')
      ''');
    }
  }

  // 7. Prevent ghosted native processes by explicitly destroying connection streams
  static Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
      debugPrint('[MySQL] Connection securely torn down.');
    }
  }
}
