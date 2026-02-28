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
import '../domain/usecases/get_announcements.dart';
import '../data/repositories/announcement_repository.dart';

class AnnouncementProvider extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Dependencies (injected via constructor)
  // ---------------------------------------------------------------------------

  final GetAnnouncements _getAnnouncements;

  AnnouncementProvider({GetAnnouncements? getAnnouncements})
      : _getAnnouncements =
            getAnnouncements ?? GetAnnouncements(AnnouncementRepository());

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

  /// Fetches announcements from the REST API.
  ///
  /// Follows the loading → success/error pattern:
  ///   1. Set isLoading = true, clear error
  ///   2. Await use-case result
  ///   3a. On success: store list, isLoading = false
  ///   3b. On failure: store error message, isLoading = false
  ///   4. notifyListeners() in both cases so UI updates
  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // triggers loading spinner in UI

    try {
      _announcements = await _getAnnouncements();
    } catch (e) {
      // Surface a user-friendly message, log the technical detail
      _errorMessage = 'Could not load announcements. Check your connection.';
      debugPrint('[AnnouncementProvider] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // triggers rebuild with data or error
    }
  }
}
