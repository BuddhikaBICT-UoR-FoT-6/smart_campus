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
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Added for production-grade secure storage
import '../domain/models/user.dart';

class AuthProvider extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  // Initialize the secure storage instance. This encrypts data on disk.
  static const _secureStorage = FlutterSecureStorage();

  // Holds the active user object during runtime
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

  /// Checks local secure storage for a saved session.
  /// If found, restores the currentUser without requiring a password.
  Future<bool> checkLoginStatus() async {
    // Asynchronously read the encrypted 'user_email' key from device keychain/keystore
    final savedEmail = await _secureStorage.read(key: 'user_email');

    // If a saved email exists, it implies the user didn't log out
    if (savedEmail != null) {
      // Look up the user matching the securely stored email
      final match = _mockUsers.firstWhere(
        (u) => u['email'] == savedEmail, // Check email match
        orElse: () => {},                // Return empty map if not found
      );

      // Verify the match is valid and not an empty map
      if (match.isNotEmpty) {
        // Hydrate the User domain model with data from our mock DB
        _currentUser = User(
          id: match['id'] as String,             // Explicit cast to String
          name: match['name'] as String,         // Explicit cast to String
          email: match['email'] as String,       // Explicit cast to String
          role: UserRole.values.byName(match['role'] as String), // Enum parser
        );
        // Trigger a rebuild across the app so routers know we are logged in
        notifyListeners();
        // Return true indicating the session was restored successfully
        return true;
      }
    }
    // Return false if no saved session was found
    return false;
  }

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

    // Hydrate the runtime User object
    _currentUser = User(
      id: match['id'] as String,
      name: match['name'] as String,
      email: match['email'] as String,
      role: UserRole.values.byName(match['role'] as String),
    );

    // Write the email to secure storage to persist the session securely encrypted
    await _secureStorage.write(key: 'user_email', value: _currentUser!.email);

    // Notify all UI listeners to switch from LoginScreen to HomeScreen
    notifyListeners(); 
    // Return success
    return true;
  }

  /// Logs out the current user.
  ///
  /// Clears _currentUser and notifies listeners so the app redirects
  /// back to the Login screen.
  Future<void> logout() async {
    // 1. Wipe the in-memory user object
    _currentUser = null;
    
    // 2. Cryptographically delete the session key from device storage
    await _secureStorage.delete(key: 'user_email');

    // 3. Inform the app router to immediately navigate to the Login screen
    notifyListeners();
  }
}
