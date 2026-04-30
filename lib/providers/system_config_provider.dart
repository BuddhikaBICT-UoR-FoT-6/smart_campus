import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import '../data/local/database_helper.dart';

class SystemConfigProvider extends ChangeNotifier {
  String _registrationDeadline = '2026-05-30';
  bool _isLoading = false;

  String get registrationDeadline => _registrationDeadline;
  bool get isLoading => _isLoading;

  bool get isRegistrationClosed {
    final deadline = DateTime.tryParse(_registrationDeadline);
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline);
  }

  Future<void> loadConfig() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final results = await db.query(
        'system_settings',
        where: 'key = ?',
        whereArgs: ['course_registration_deadline'],
      );

      if (results.isNotEmpty) {
        _registrationDeadline = results.first['value'] as String;
      }
    } catch (e) {
      debugPrint('[SystemConfigProvider] Error loading config: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDeadline(String newDeadline) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert(
        'system_settings',
        {'key': 'course_registration_deadline', 'value': newDeadline},
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );
      _registrationDeadline = newDeadline;
      notifyListeners();
    } catch (e) {
      debugPrint('[SystemConfigProvider] Error updating deadline: $e');
    }
  }
}
