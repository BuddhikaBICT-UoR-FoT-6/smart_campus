import '../../data/repositories/event_repository.dart';

class RegisterForEvent {
  final EventRepository _repository;

  RegisterForEvent(this._repository);

  Future<void> call(String userId, String eventId) async {
    final alreadyRegistered = await _repository.isRegistered(userId, eventId);
    if (alreadyRegistered) {
      throw Exception('You are already registered for this event.');
    }
    await _repository.registerForEvent(userId, eventId);
  }
}
