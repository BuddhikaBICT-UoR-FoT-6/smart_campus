// =============================================================================
// data/repositories/event_repository.dart
// =============================================================================
// CLEAN ARCHITECTURE — Data Layer (Repository Implementation)
//
// RESPONSIBILITY:
//   All event and registration data operations, delegated to [EventDao].
// =============================================================================

import '../../data/remote/mysql_event_dao.dart';
import '../../domain/models/event.dart';

class EventRepository {
  final MysqlEventDao _dao;

  EventRepository({MysqlEventDao? dao}) : _dao = dao ?? MysqlEventDao();

  /// Returns all campus events stored locally.
  Future<List<Event>> getAllEvents() => _dao.getAllEvents();

  /// Registers [userId] for [eventId].
  Future<void> registerForEvent(String userId, String eventId) =>
      _dao.registerForEvent(userId, eventId);

  /// Returns true if [userId] is already registered for [eventId].
  Future<bool> isRegistered(String userId, String eventId) =>
      _dao.isRegistered(userId, eventId);

  /// Returns the set of all event IDs that [userId] has registered for.
  Future<Set<String>> getRegisteredEventIds(String userId) =>
      _dao.getRegisteredEventIds(userId);
}
