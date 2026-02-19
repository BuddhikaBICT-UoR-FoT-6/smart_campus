// =============================================================================
// main.dart — Application Entry Point
// =============================================================================
// Responsibility:
//   - Initialises the Flutter app
//   - Registers all Providers at the root so every screen can access them
//   - Sets the initial route to the Login screen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/event_provider.dart';

void main() {
  // Ensures Flutter engine is fully initialised before any plugin is used
  // (required when using SQLite or other native plugins at startup)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SmartCampusApp());
}

/// Root widget of the Smart Campus Operations System.
///
/// MultiProvider is placed here at the top of the widget tree so that
/// AuthProvider, AnnouncementProvider, and EventProvider are available
/// to every screen without needing to be re-created on navigation.
class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Handles mock login / logout and current user role (Student / Staff)
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Fetches campus announcements from the mock REST API
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),

        // Manages event list and student event registrations
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Campus',
        debugShowCheckedModeBanner: false,

        // Named routes defined centrally in app/routes.dart
        routes: AppRoutes.routes,

        // App starts at the Login screen
        initialRoute: AppRoutes.login,
      ),
    );
  }
}
