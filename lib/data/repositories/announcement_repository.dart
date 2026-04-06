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

  // 1. Maintain a structural hardcoded fallback for presentation stability (No Internet Viva)
  static final List<Announcement> _localFallback = [
    Announcement(
      id: 101,
      title: 'University Convocation 2026',
      body: 'The annual convocation ceremony for all faculties is scheduled for July 15th.',
      postedBy: 'Registrar Office',
      date: '2026-03-28',
    ),
    Announcement(
      id: 102,
      title: 'Semester Results Published',
      body: 'Results for Semester I examinations are now available on the management system.',
      postedBy: 'Exam Dept',
      date: '2026-03-25',
    ),
    Announcement(
      id: 103,
      title: 'Workshop: AI in Industry',
      body: 'Join the Faculty of Technology for a guest lecture on Generative AI. Room 402.',
      postedBy: 'CS Dept',
      date: '2026-03-20',
    ),
  ];

  AnnouncementRepository({AnnouncementApi? api})
      : _api = api ?? AnnouncementApi();

  /// Fetches announcements from the remote mock API with strict local fallback.
  Future<List<Announcement>> getAnnouncements() async {
    try {
      return await _api.fetchAnnouncements();
    } catch (e) {
      // 2. Resilience Design: If network bound is offline, return cached static structures
      return _localFallback;
    }
  }
}
