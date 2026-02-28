// =============================================================================
// providers/auth_provider.dart
// =============================================================================
// CLEAN ARCHITECTURE — Presentation Layer (State Management)
//
// PATTERN: Provider (ChangeNotifier)
//
// RESPONSIBILITY:
//   - Stores the currently logged-in user
//   - Provides login() with mock credentials
//   - Provides logout() to clear the session
//   - Notifies all listening widgets when auth state changes
//
// WHY PROVIDER?
//   Provider is Flutter's officially recommended state management for
//   beginner/intermediate projects. It uses ChangeNotifier + InheritedWidget
//   under the hood — both topics covered in Flutter's own documentation.
//   It's easy to explain in a viva: "Any widget that watches AuthProvider
//   is automatically rebuilt when notifyListeners() is called."
//
// VIVA POINT:
//   "AuthProvider holds the current user. When login() succeeds it sets
//    _currentUser and calls notifyListeners(). Every widget that uses
//    context.watch<AuthProvider>() will rebuild with the new state."
// =============================================================================

import 'package:flutter/material.dart';
import '../domain/models/user.dart';

class AuthProvider extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  User? _currentUser;

  /// The currently authenticated user, or null if logged out.
  User? get currentUser => _currentUser;

  /// Convenience getter — true when a user is logged in.
  bool get isLoggedIn => _currentUser != null;

  // ---------------------------------------------------------------------------
  // Mock credentials (hardcoded — no real server needed)
  // ---------------------------------------------------------------------------

  /// Mock user database. In a real app this would hit a backend API.
  ///
  /// Credentials for demonstration / viva:
  ///   student@campus.lk  / 1234   → Student role
  ///   staff@campus.lk    / 1234   → Staff role
  static const List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 'usr-001',
      'name': 'Ashan Perera',
      'email': 'student@campus.lk',
      'password': '1234',
      'role': 'student',
    },
    {
      'id': 'usr-002',
      'name': 'Dr. Nilufar Silva',
      'email': 'staff@campus.lk',
      'password': '1234',
      'role': 'staff',
    },
  ];

  // ---------------------------------------------------------------------------
  // Auth operations
  // ---------------------------------------------------------------------------

  /// Attempts to log in with the given [email] and [password].
  ///
  /// Returns true on success, false if credentials do not match.
  ///
  /// *Simulates an async operation* with a short delay so the UI can
  /// show a loading spinner — realistic without needing a real server.
  Future<bool> login(String email, String password) async {
    // Simulate network latency (300 ms)
    await Future.delayed(const Duration(milliseconds: 300));

    final match = _mockUsers.firstWhere(
      (u) => u['email'] == email.trim() && u['password'] == password,
      orElse: () => {},
    );

    if (match.isEmpty) {
      return false; // invalid credentials
    }

    _currentUser = User(
      id: match['id'] as String,
      name: match['name'] as String,
      email: match['email'] as String,
      role: UserRole.values.byName(match['role'] as String),
    );

    notifyListeners(); // rebuilds every widget watching AuthProvider
    return true;
  }

  /// Logs out the current user.
  ///
  /// Clears _currentUser and notifies listeners so the app redirects
  /// back to the Login screen.
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
