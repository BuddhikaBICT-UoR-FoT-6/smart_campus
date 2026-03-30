// =============================================================================
// providers/timetable_provider.dart
// =============================================================================
// Manages timetable state — loads entries for the logged-in user from SQLite.
//
// VIVA POINT:
//   "TimetableProvider follows the same pattern as AnnouncementProvider:
//    isLoading, data, error. The UI just watches the provider — it never
//    calls the DAO or repository directly."
// =============================================================================

import 'package:flutter/material.dart';

import '../domain/models/timetable_entry.dart';
import '../domain/usecases/get_timetable.dart';
import '../data/repositories/timetable_repository.dart';

class TimetableProvider extends ChangeNotifier {
  final GetTimetable _getTimetable;

  TimetableProvider({GetTimetable? getTimetable})
      : _getTimetable = getTimetable ?? GetTimetable(TimetableRepository());

  // State
  List<TimetableEntry> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TimetableEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads timetable entries for [userId] from local SQLite.
  Future<void> loadTimetable(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = await _getTimetable(userId);
    } catch (e) {
      _errorMessage = 'Could not load timetable. Please restart the app.';
      debugPrint('[TimetableProvider] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  final TimetableRepository _repository = TimetableRepository();

  void addEntry(TimetableEntry entry) async {
    await _repository.insertEntry(entry);
    _entries = [..._entries, entry];
    notifyListeners();
  }

  void updateEntry(TimetableEntry entry) async {
    await _repository.updateEntry(entry);
    final i = _entries.indexWhere((e) => e.id == entry.id);
    if (i != -1) {
      _entries[i] = entry;
      notifyListeners();
    }
  }

  void deleteEntry(String id) async {
    await _repository.deleteEntry(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
