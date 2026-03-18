import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_campus/presentation/screens/login_screen.dart';
import 'package:smart_campus/providers/auth_provider.dart';

void main() {
  Widget createLoginScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('Rendering check: shows title, text fields, and button', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Verify static elements
      expect(find.text('Smart Campus'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Verify text fields
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('Validation error when submitting empty form', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Tap sign in immediately
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Expect validation messages
      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
    });

    testWidgets('Validation error for invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'notanemail');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
      // We didn't enter a password so that error should appear too
      expect(find.text('Enter your password'), findsOneWidget);
    });
  });
}
