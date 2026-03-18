import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/providers/auth_provider.dart';
import 'package:smart_campus/domain/models/user.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    test('Initial state should be logged out', () {
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isLoggedIn, isFalse);
    });

    test('login() with valid student credentials sets currentUser', () async {
      final success = await authProvider.login('student@campus.lk', '1234');

      expect(success, isTrue);
      expect(authProvider.isLoggedIn, isTrue);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.role, equals(UserRole.student));
    });

    test('login() with valid staff credentials sets currentUser', () async {
      final success = await authProvider.login('staff@campus.lk', '1234');

      expect(success, isTrue);
      expect(authProvider.isLoggedIn, isTrue);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.role, equals(UserRole.staff));
    });

    test('login() with invalid credentials returns false and stays logged out', () async {
      final success = await authProvider.login('wrong@campus.lk', 'wrongpass');

      expect(success, isFalse);
      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.currentUser, isNull);
    });

    test('logout() clears the currentUser', () async {
      // First login
      await authProvider.login('student@campus.lk', '1234');
      expect(authProvider.isLoggedIn, isTrue);

      // Then logout
      authProvider.logout();
      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.currentUser, isNull);
    });
  });
}
