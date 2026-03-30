// =============================================================================
// providers/announcement_provider.dart
// =============================================================================
// CLEAN ARCHITECTURE — Presentation Layer (State Management)
//
// RESPONSIBILITY:
//   Manages the state of the Announcements screen:
//     - Loading state (show spinner)
//     - Success state (show list)
//     - Error state (show message)
//
// DATA FLOW (important for viva):
//   AnnouncementsScreen
//     → calls AnnouncementProvider.fetchAnnouncements()
//     → Provider calls GetAnnouncements use-case
//     → Use-case calls AnnouncementRepository
//     → Repository calls AnnouncementApi (HTTP GET)
//     → Result bubbles back up as List<Announcement>
//     → Provider calls notifyListeners()
//     → Screen rebuilds and displays the list
//
// VIVA POINT:
//   "Three boolean/value states = isLoading, announcements list, errorMessage.
//    This is the standard pattern for async data in Provider apps."
// =============================================================================

import 'package:flutter/material.dart';

import '../domain/models/announcement.dart';
import '../data/repositories/announcement_repository.dart';
import '../core/services/notification_service.dart';

class AnnouncementProvider extends ChangeNotifier {
  final AnnouncementRepository _repository;

  AnnouncementProvider({AnnouncementRepository? repository})
      : _repository = repository ?? AnnouncementRepository();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<Announcement> _announcements = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Public getters — widgets read these, never access _private fields directly
  List<Announcement> get announcements => List.unmodifiable(_announcements);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Fetches announcements from the database.
  Future<void> fetchAnnouncements({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _announcements = await _repository.getAnnouncements();
    } catch (e) {
      _errorMessage = 'Could not load announcements.';
      debugPrint('[AnnouncementProvider] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  Future<void> addAnnouncement(String title, String body, String posterName, {bool isUrgent = false}) async {
    final newId = DateTime.now().millisecondsSinceEpoch;
    final newAnnouncement = Announcement(
      id: newId,
      title: title,
      body: body,
      postedBy: posterName,
      date: DateTime.now().toString().split(' ')[0], // YYYY-MM-DD
    );

    await _repository.insertAnnouncement(newAnnouncement);
    await fetchAnnouncements();

    if (isUrgent) {
      NotificationService().showNotification(
        id: newId, 
        title: '🚨 $title', 
        body: body,
      );
    }
  }

  void simulateUrgentAnnouncement() {
    addAnnouncement('Campus Closure', 'All classes are cancelled today due to severe weather.', 'Administration', isUrgent: true);
  }

  Future<void> updateAnnouncement(int id, String title, String body) async {
    final index = _announcements.indexWhere((a) => a.id == id);
    if (index != -1) {
      final old = _announcements[index];
      final updated = Announcement(
        id: old.id,
        title: title,
        body: body,
        postedBy: old.postedBy,
        date: old.date,
      );
      await _repository.updateAnnouncement(updated);
      await fetchAnnouncements();
    }
  }

  Future<void> deleteAnnouncement(int id) async {
    await _repository.deleteAnnouncement(id);
    await fetchAnnouncements();
  }
}
