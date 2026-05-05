// =============================================================================
// domain/usecases/get_announcements.dart
// =============================================================================
// CLEAN ARCHITECTURE — Domain Layer (Use-Case)
//
// VIVA POINT:
//   "GetAnnouncements encapsulates the rule: 'fetch announcements from the
//    network'. The Provider calls this use-case; it doesn't call the API
//    directly. This means we could switch from JSONPlaceholder to a real
//    university API by only changing AnnouncementRepository — not this class."
// =============================================================================

import '../models/announcement.dart';
import '../../data/repositories/announcement_repository.dart';

class GetAnnouncements {
  final AnnouncementRepository _repository;

  GetAnnouncements(this._repository);

  /// Fetches the latest campus announcements from the mock REST API.
  Future<List<Announcement>> call() {
    return _repository.getAnnouncements();
  }
}
