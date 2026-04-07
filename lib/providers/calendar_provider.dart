// =============================================================================
// providers/calendar_provider.dart
// =============================================================================

import 'package:flutter/material.dart';
import '../domain/models/academic_week.dart';
import '../data/local/database_helper.dart';

class CalendarProvider extends ChangeNotifier {
  List<AcademicWeek> _weeks = [];
  AcademicWeek? _currentWeek;
  bool _isLoading = false;

  List<AcademicWeek> get weeks => List.unmodifiable(_weeks);
  AcademicWeek? get currentWeek => _currentWeek;
  bool get isLoading => _isLoading;

  Future<void> loadCalendar() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query('academic_calendar', orderBy: 'number ASC');

      _weeks = maps.map((m) => AcademicWeek.fromMap(m)).toList();

      // Determine current week
      final now = DateTime.now();
      _currentWeek = _weeks.firstWhere(
        (w) => now.isAfter(w.startDate) && now.isBefore(w.endDate.add(const Duration(days: 1))),
        orElse: () => _weeks.last, // Fallback
      );
    } catch (e) {
      debugPrint('[CalendarProvider] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
