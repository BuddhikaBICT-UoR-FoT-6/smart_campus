// =============================================================================
// data/repositories/announcement_repository.dart
// =============================================================================
// CLEAN ARCHITECTURE — Data Layer (Repository Implementation)
//
// RESPONSIBILITY:
//   Abstracts the remote data source (HTTP API) behind a simple method.
//   Future extension: add a local cache here — the use-case never changes.
//
// VIVA POINT:
//   "If we later want to cache announcements in SQLite after fetching,
//    we only change this file — nowhere else in the app needs to know."
// =============================================================================

import '../../data/remote/announcement_api.dart';
import '../../domain/models/announcement.dart';

class AnnouncementRepository {
  final AnnouncementApi _api;

  AnnouncementRepository({AnnouncementApi? api})
      : _api = api ?? AnnouncementApi();

  /// Fetches announcements from the remote mock API.
  Future<List<Announcement>> getAnnouncements() {
    return _api.fetchAnnouncements();
  }
}
