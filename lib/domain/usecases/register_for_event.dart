// =============================================================================
// domain/usecases/register_for_event.dart
// =============================================================================
// CLEAN ARCHITECTURE — Domain Layer (Use-Case)
//
// VIVA POINT:
//   "RegisterForEvent is a command use-case — it changes state (writes to DB).
//    It takes the student's ID and the event ID, checks if already registered,
//    and delegates to the repository. No widget logic lives here."
// =============================================================================

import '../../data/repositories/event_repository.dart';

class RegisterForEvent {
  final EventRepository _repository;

  RegisterForEvent(this._repository);

  /// Registers the student for an event.
  ///
  /// [userId]  — ID of the logged-in student.
  /// [eventId] — ID of the event to register for.
  ///
  /// Throws an [Exception] if the student is already registered.
  Future<void> call(String userId, String eventId) async {
    final alreadyRegistered = await _repository.isRegistered(userId, eventId);
    if (alreadyRegistered) {
      throw Exception('You are already registered for this event.');
    }
    await _repository.registerForEvent(userId, eventId);
  }
}
