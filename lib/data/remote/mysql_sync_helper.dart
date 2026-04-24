import 'package:flutter/foundation.dart';
import '../../domain/models/user.dart';
import '../../domain/models/timetable_entry.dart';
import '../../domain/models/medical_submission.dart';
import 'mysql_database.dart';

class MySqlSyncHelper {
  static Future<void> syncUserInsert(User user) async {
    try {
      final conn = await MySqlDatabase.getConnection();
      await conn.query('''
        INSERT INTO users (id, name, email, password, role, address, emergencyName, emergencyPhone, profilePic, level, semester, isRepeat)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
          name = VALUES(name),
          email = VALUES(email),
          role = VALUES(role),
          address = VALUES(address),
          emergencyName = VALUES(emergencyName),
          emergencyPhone = VALUES(emergencyPhone),
          profilePic = VALUES(profilePic),
          level = VALUES(level),
          semester = VALUES(semester),
          isRepeat = VALUES(isRepeat)
      ''', [
        user.id,
        user.name,
        user.email,
        '1234', 
        user.role.name,
        user.address,
        user.emergencyName,
        user.emergencyPhone,
        user.profilePic,
        user.level,
        user.semester,
        user.isRepeat ? 1 : 0
      ]);
      debugPrint('[MySQL Sync] User ${user.id} inserted/updated successfully.');
    } catch (e) {
      debugPrint('[MySQL Sync Error] Failed to sync user insertion: $e');
    }
  }

  static Future<void> syncUserDelete(String id) async {
    try {
      final conn = await MySqlDatabase.getConnection();
      await conn.query('DELETE FROM users WHERE id = ?', [id]);
      debugPrint('[MySQL Sync] User $id deleted successfully.');
    } catch (e) {
      debugPrint('[MySQL Sync Error] Failed to delete user: $e');
    }
  }

  static Future<void> syncTimetableInsert(TimetableEntry entry) async {
    try {
      final conn = await MySqlDatabase.getConnection();
      await conn.query('''
        INSERT INTO timetable (id, subject, dayOfWeek, startTime, endTime, room, userId, isAttended, isAdditional, lectureContent, level, semester)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
          subject = VALUES(subject),
          dayOfWeek = VALUES(dayOfWeek),
          startTime = VALUES(startTime),
          endTime = VALUES(endTime),
          room = VALUES(room),
          isAttended = VALUES(isAttended),
          isAdditional = VALUES(isAdditional),
          lectureContent = VALUES(lectureContent),
          level = VALUES(level),
          semester = VALUES(semester)
      ''', [
        entry.id,
        entry.subject,
        entry.dayOfWeek,
        entry.startTime,
        entry.endTime,
        entry.room,
        entry.userId,
        entry.isAttended == true ? 1 : 0,
        entry.isAdditional ? 1 : 0,
        entry.lectureContent,
        entry.level,
        entry.semester
      ]);
      debugPrint('[MySQL Sync] Timetable entry ${entry.id} synced successfully.');
    } catch (e) {
      debugPrint('[MySQL Sync Error] Failed to sync timetable: $e');
    }
  }

  static Future<void> syncTimetableDelete(String id) async {
    try {
      final conn = await MySqlDatabase.getConnection();
      await conn.query('DELETE FROM timetable WHERE id = ?', [id]);
      debugPrint('[MySQL Sync] Timetable entry $id deleted successfully.');
    } catch (e) {
      debugPrint('[MySQL Sync Error] Failed to delete timetable: $e');
    }
  }

  static Future<void> syncMedicalSubmissionInsert(MedicalSubmission submission) async {
    try {
      final conn = await MySqlDatabase.getConnection();
      await conn.query('''
        INSERT INTO medical_submissions (id, userId, week, date, photoPath, status)
        VALUES (?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
          status = VALUES(status)
      ''', [
        submission.id,
        submission.userId,
        submission.week,
        submission.date,
        submission.photoPath,
        submission.status,
      ]);
      debugPrint('[MySQL Sync] Medical Submission ${submission.id} synced successfully.');
    } catch (e) {
      debugPrint('[MySQL Sync Error] Failed to sync medical submission: $e');
    }
  }
}
