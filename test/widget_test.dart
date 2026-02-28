// =============================================================================
// test/widget_test.dart
// =============================================================================
// Basic smoke test that verifies the app widget tree can be built.
//
// Updated to use SmartCampusApp (the actual root widget) instead of
// the stale MyApp reference from the Flutter starter template.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/main.dart';

void main() {
  testWidgets('App builds without throwing', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const SmartCampusApp());

    // Verify the Login screen title is present
    expect(find.text('Smart Campus'), findsWidgets);
  });
}
