import 'package:flutter/material.dart';
import '../data/local/database_helper.dart';
import '../domain/models/user.dart';

class ReportingProvider extends ChangeNotifier {
  Map<UserRole, int> _userRoleDistribution = {};
  Map<String, int> _eventRegistrationDistribution = {};
  bool _isLoading = false;

  Map<UserRole, int> get userRoleDistribution => _userRoleDistribution;
  Map<String, int> get eventRegistrationDistribution => _eventRegistrationDistribution;
  bool get isLoading => _isLoading;

  Future<void> loadReportData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;

      // 1. User Role Distribution
      final userRows = await db.query('users');
      final distribution = <UserRole, int>{};
      for (var row in userRows) {
        final roleStr = row['role'] as String;
        final role = UserRole.values.firstWhere((r) => r.name == roleStr);
        distribution[role] = (distribution[role] ?? 0) + 1;
      }
      _userRoleDistribution = distribution;

      // 2. Event Participation
      final eventRows = await db.query('events');
      final participation = <String, int>{};
      for (var event in eventRows) {
        final eventId = event['id'] as String;
        final title = event['title'] as String;
        final regRows = await db.query('registrations', where: 'eventId = ?', whereArgs: [eventId]);
        participation[title] = regRows.length;
      }
      _eventRegistrationDistribution = participation;

    } catch (e) {
      debugPrint('[ReportingProvider] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
