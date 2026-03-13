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
  
  // 1. Maintain a memory cache timestamp. This prevents the app from hammering external APIs on tab switches.
  DateTime? _lastFetchTime;

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
  /// 
  /// The [forceRefresh] flag bypasses the 5-minute memory cache constraint.
  Future<void> fetchAnnouncements({bool forceRefresh = false}) async {
    // 2. Performance Engineering: Ensure we do not refetch if data is < 5 minutes old
    if (!forceRefresh && _lastFetchTime != null) {
      final age = DateTime.now().difference(_lastFetchTime!);
      if (age.inMinutes < 5) {
        // Cache is considered warm and strictly valid. Skip network processing.
        debugPrint('[AnnouncementProvider] Cache warm (${age.inSeconds}s old). Skipping API.');
        return;
      }
    }

    // 3. Purge existing UI states to immediately display loading boundary
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // triggers loading spinner in UI

    try {
      // 4. Delegate to the architectural Use-Case bridging the Domain block
      _announcements = await _getAnnouncements();
      // 5. Success! Record the atomic timestamp to strictly anchor the new 5-minute cache lifespan
      _lastFetchTime = DateTime.now();
    } catch (e) {
      // Surface a user-friendly message, log the technical detail
      _errorMessage = 'Could not load announcements. Check your connection.';
      debugPrint('[AnnouncementProvider] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // triggers rebuild with data or error
    }
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Simulates adding a new announcement locally without an API request.
  void addAnnouncement(String title, String body, String posterName) {
    final newId = DateTime.now().millisecondsSinceEpoch;
    final newAnnouncement = Announcement(
      id: newId,
      title: title,
      body: body,
      postedBy: posterName,
      date: DateTime.now().toString().split(' ')[0], // YYYY-MM-DD
    );

    // Insert at top of list
    _announcements.insert(0, newAnnouncement);
    notifyListeners();
  }
}
