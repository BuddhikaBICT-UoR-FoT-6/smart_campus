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

import '../../data/local/announcement_dao.dart';
import '../../domain/models/announcement.dart';

class AnnouncementRepository {
  final AnnouncementDao _dao;

  AnnouncementRepository({AnnouncementDao? dao})
      : _dao = dao ?? AnnouncementDao();

  /// Fetches announcements from the local database.
  Future<List<Announcement>> getAnnouncements() async {
    return await _dao.getAllAnnouncements();
  }

  Future<void> insertAnnouncement(Announcement announcement) async {
    await _dao.insertAnnouncement(announcement);
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    await _dao.updateAnnouncement(announcement);
  }

  Future<void> deleteAnnouncement(int id) async {
    await _dao.deleteAnnouncement(id);
  }
}
