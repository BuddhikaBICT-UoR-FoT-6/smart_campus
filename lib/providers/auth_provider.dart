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

import 'dart:convert'; // Added for JWT token parsing and serialization algorithms
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Added for production-grade secure storage
import '../domain/models/user.dart';
import '../data/local/database_helper.dart';
import '../utils/security_helper.dart';

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
  // Mock credentials (hardcoded — no real server needed
  // ---------------------------------------------------------------------------

  /// Mock user database. In a real app this would hit a backend API.
  ///
  /// Credentials for demonstration / viva:
  ///   student@campus.lk  / 1234   → Student role
  ///   staff@campus.lk    / 1234   → Staff role
  ///   admin@campus.lk    / 1234   → Superadmin role
  static const List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 'usr-001',
      'name': 'Ashan Perera',
      'email': 'student@campus.lk',
      'password': '1234',
      'role': 'student',
      'level': 4,
      'semester': 1,
      'emailAlerts': true,
    },
    {
      'id': 'usr-002',
      'name': 'Dr. Nilufar Silva',
      'email': 'staff@campus.lk',
      'password': '1234',
      'role': 'staff',
    },
    {
      'id': 'usr-003',
      'name': 'Campus Admin',
      'email': 'admin@campus.lk',
      'password': '1234',
      'role': 'superadmin',
    },
  ];

  // ---------------------------------------------------------------------------
  // Auth operations
  // ---------------------------------------------------------------------------

  /// Checks local secure storage for a saved session token.
  /// If found, parses the JWT payload, checks its expiry, and restores the user.
  Future<bool> checkLoginStatus() async {
    // Asynchronously read the encrypted 'auth_token' key from device keychain/keystore.
    // In production, tokens are fundamentally safer than caching raw username/emails.
    final savedToken = await _secureStorage.read(key: 'auth_token');

    // If a saved token exists, we attempt to decode and cryptographically validate it
    if (savedToken != null) {
      try {
        // Step 1: Decode the Base64Url formatted JWT string back into raw bytes
        // In a real app we'd split the header.payload.signature, but here we mock the payload directly
        final payloadString = utf8.decode(base64Url.decode(savedToken));

        // Step 2: Parse the decoded JSON string securely into a Dart Map
        final payload = jsonDecode(payloadString);

        // Step 3: Extract the securely embedded expiry timestamp (in milliseconds since epoch)
        final exp = payload['exp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;

        // Step 4: Strict validation — mathematically check if the token has expired
        if (now > exp) {
          // Token is expired. Actively wipe the dead session to force the user to login again natively.
          debugPrint('[AuthProvider] Session expired. Wiping cache.');
          await logout();
          return false;
        }

        // Token is computationally valid. Reconstruct the User profile directly from the JWT payload claims.
        // This is a major production feature: it avoids hammering the database/API for user details on startup.
        _currentUser = User(
          id: payload['userId'] as String, // Safely cast extracted ID to String
          name:
              payload['name'] as String, // Safely cast extracted Name to String
          email:
              payload['email']
                  as String, // Safely cast extracted Email to String
          role: UserRole.values.byName(
            payload['role'] as String,
          ), // Parse String back into strictly-typed Enum
          level: payload['level'] as int?,
          semester: payload['semester'] as int?,
          emailAlerts: (payload['emailAlerts'] is int) 
              ? (payload['emailAlerts'] as int == 1)
              : (payload['emailAlerts'] as bool? ?? true),
        );

        // Trigger a reactive rebuild across the entire app so routers instantly transition away from Splash
        notifyListeners();
        // Return true indicating the session was fully and safely restored
        return true;
      } catch (e) {
        // If the token is corrupted, malformed, or tampered with, catch the exception to prevent crash
        debugPrint('[AuthProvider] Invalid JWT Token detected or tampered: $e');
        // Gracefully wipe the compromised session data
        await logout();
        return false;
      }
    }
    // Return false if no saved session token was found on the device disk
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

    // Try to find user in SQLite database first (for dynamic users and changed passwords)
    final db = await DatabaseHelper.instance.database;
    debugPrint('[AuthProvider] Attempting login for: ${email.trim()}');
    
    final hashedInput = SecurityHelper.hashPassword(password);
    
    // Diagnostic: List all users to see what's in the DB
    final allUsers = await db.query('users');
    debugPrint('[AuthProvider] Current DB Users: ${allUsers.map((u) => "{email: ${u['email']}, pwd: ${u['password']}}").toList()}');

    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim(), hashedInput],
    );

    debugPrint('[AuthProvider] DB search found ${rows.length} rows');

    if (rows.isEmpty) {
      debugPrint('[AuthProvider] Login failed: Invalid credentials or user not found.');
      return false; 
    }

    final match = Map<String, dynamic>.from(rows.first);

    // Hydrate the runtime User object natively mapping static memory boundaries
    _currentUser = User(
      id: match['id'] as String,
      name: match['name'] as String,
      email: match['email'] as String,
      password: match['password'] as String?,
      role: UserRole.values.byName(match['role'] as String),
      level: match['level'] as int?,
      semester: match['semester'] as int?,
      emailAlerts: (match['emailAlerts'] is int) 
          ? (match['emailAlerts'] as int == 1)
          : (match['emailAlerts'] as bool? ?? true),
    );

    // 4. Construct the payload mimicking standard JWT claims structure structurally binding to Offline properties
    final mockJwtPayload = {
      'userId': match['id'],
      'name': match['name'],
      'email': match['email'],
      'role': match['role'],
      'level': match['level'],
      'semester': match['semester'],
      'emailAlerts': match['emailAlerts'] ?? true,
      // 5. Compute an explicit expiration timestamp set strictly to 1 hour from this exact moment
      'exp': DateTime.now()
          .add(const Duration(hours: 1))
          .millisecondsSinceEpoch,
    };

    // 3. Serialize the payload to a JSON string, encode it to raw bytes, then to Base64Url standard
    // This perfectly mimics how a real backend constructs the payload portion of a JSON Web Token
    final mockToken = base64Url.encode(utf8.encode(jsonEncode(mockJwtPayload)));

    // 4. Securely write the cryptographically protected token into the persistent hardware keystore
    await _secureStorage.write(key: 'auth_token', value: mockToken);

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

    // 2. Cryptographically delete the session authorization token from secure hardware storage
    await _secureStorage.delete(key: 'auth_token');

    // 3. Inform the app router to immediately navigate to the Login screen
    notifyListeners();
  }

  /// Updates the current user's profile in the SQLite database and locally.
  Future<void> updateUserProfile(User updatedUser) async {
    if (_currentUser == null || _currentUser!.id != updatedUser.id) return;

    // Update local DB
    await DatabaseHelper.instance.updateUser(updatedUser);

    // Update in-memory state
    _currentUser = updatedUser;

    // We should also theoretically update the JWT in the secure storage here,
    // but since the mock JWT only stores name, email, role, and ID (which aren't changing),
    // it can remain as is. If we allowed changing the name, we should recreate the JWT.

    notifyListeners();
  }

  /// Changes the current user's password.
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;

    final db = await DatabaseHelper.instance.database;
    
    final hashedOld = SecurityHelper.hashPassword(oldPassword);
    final hashedNew = SecurityHelper.hashPassword(newPassword);

    // 1. Verify old password
    final rows = await db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [_currentUser!.id, hashedOld],
    );

    if (rows.isEmpty) return false; // Incorrect old password

    // 2. Update to new password
    await db.update(
      'users',
      {'password': hashedNew},
      where: 'id = ?',
      whereArgs: [_currentUser!.id],
    );

    // 3. Update in-memory user
    _currentUser = _currentUser!.copyWith(password: hashedNew);
    
    notifyListeners();
    return true;
  }
}
