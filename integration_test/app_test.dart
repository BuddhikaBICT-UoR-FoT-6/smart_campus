// =============================================================================
// integration_test/app_test.dart
// =============================================================================
// CLEAN ARCHITECTURE — Test Layer (Integration)
//
// RESPONSIBILITY:
//   Executes full end-to-end (E2E) workflow tests running implicitly on a physical
//   emulated hardware environment. Instead of mocking the database layer, this triggers
//   real frame rendering to verify the mathematical soundness of the UI routing graph.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_campus/main.dart' as app;

void main() {
  // 1. Architecturally hook into the native device bindings before test invocation
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-End master authorization navigation bypass execution loop', (tester) async {
    // 2. Inflate the core routing system natively via the app entrypoint
    app.main();

    // 3. Command the engine to halt execution until all geometric frames are completely painted
    await tester.pumpAndSettle();

    // 4. Verify the structural initial route mathematically resolved to the Login Bounds
    expect(find.text('Sign in to continue'), findsOneWidget);

    // 5. Autonomously inject the mock authorization string payloads securely into the Form bounds
    await tester.enterText(find.byType(TextFormField).first, 'student@campus.lk');
    await tester.enterText(find.byType(TextFormField).last, '1234');
    
    // 6. Mechanically trigger the UI submit gesture to invoke the internal Provider protocols
    await tester.tap(find.text('Sign In'));

    // 7. Statically halt again to allow all network mocks and SharedPreferences to sync
    await tester.pumpAndSettle();

    // 8. Prove the spatial integrity of the transition by verifying the bottom navigation bar rendered
    expect(find.text('Announcements'), findsWidgets); // Label exists on the tab bar
  });
}
