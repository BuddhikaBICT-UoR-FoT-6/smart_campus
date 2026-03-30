// =============================================================================
// providers/event_provider.dart
// =============================================================================
// CLEAN ARCHITECTURE — Presentation Layer (State Management)
//
// RESPONSIBILITY:
//   - Loads all campus events from SQLite
//   - Tracks which events the logged-in student has registered for
//   - Handles the register action, updating state optimistically
//
// VIVA POINT:
//   "EventProvider keeps a Set<String> of registeredEventIds. A Set is
//    used because lookup (contains) is O(1) — very fast for checking
//    whether a button should say 'Register' or 'Registered ✓'."
// =============================================================================

import 'package:flutter/material.dart';

import '../domain/models/event.dart';
import '../domain/usecases/register_for_event.dart';
import '../data/repositories/event_repository.dart';

class EventProvider extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final EventRepository _repository;
  final RegisterForEvent _registerForEvent;

  EventProvider({EventRepository? repository})
      : _repository = repository ?? EventRepository(),
        _registerForEvent =
            RegisterForEvent(repository ?? EventRepository());

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<Event> _events = [];
  Set<String> _registeredEventIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, int> _registrationCounts = {}; // eventId -> count

  List<Event> get events => List.unmodifiable(_events);
  Set<String> get registeredEventIds => Set.unmodifiable(_registeredEventIds);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Loads all events and the current user's registration status.
  ///
  /// [userId] — the ID of the logged-in user (from AuthProvider).
  Future<void> loadEvents(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _repository.getAllEvents();
      _registeredEventIds = await _repository.getRegisteredEventIds(userId);
      // Simulate registration counts for demonstration
      _registrationCounts = {
        for (var e in _events) e.id: (e.id.length % 5) + 3 
      };
    } catch (e) {
      _errorMessage = 'Could not load events. Please try again.';
      debugPrint('[EventProvider] Error loading events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registers the current user for an event.
  ///
  /// - Calls the [RegisterForEvent] use-case (which guards against duplicates)
  /// - On success, adds [eventId] to the local set (no reload needed)
  /// - On failure, stores the error message
  Future<void> register(String userId, String eventId) async {
    try {
      await _registerForEvent(userId, eventId);
      _registeredEventIds = {..._registeredEventIds, eventId}; // immutable update
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[EventProvider] Registration error: $e');
    }
    notifyListeners();
  }

  /// Returns true if the current user is registered for [eventId].
  bool isRegistered(String eventId) => _registeredEventIds.contains(eventId);

  /// Clears all event state when the user logs out.
  void reset() {
    _events = [];
    _registeredEventIds = {};
    _isLoading = false;
    _errorMessage = null;
    _registrationCounts = {};
    notifyListeners();
  }

  int getRegistrationCount(String eventId) => _registrationCounts[eventId] ?? 0;

  Future<void> createEvent(Event event) async {
    await _repository.insertEvent(event);
    _events = [event, ..._events];
    _registrationCounts[event.id] = 0;
    notifyListeners();
  }

  Future<void> updateEvent(Event event) async {
    await _repository.updateEvent(event);
    final i = _events.indexWhere((e) => e.id == event.id);
    if (i != -1) {
      _events[i] = event;
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    await _repository.deleteEvent(eventId);
    _events.removeWhere((e) => e.id == eventId);
    _registrationCounts.remove(eventId);
    notifyListeners();
  }
}
