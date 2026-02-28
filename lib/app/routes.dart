// =============================================================================
// app/routes.dart
// =============================================================================
// CLEAN ARCHITECTURE — Presentation Layer (Navigation)
//
// RESPONSIBILITY:
//   Defines all named routes in one central place.
//   main.dart registers these; screens navigate using route names.
//
// VIVA POINT:
//   "Named routes mean we never hardcode screen class names in buttons.
//    We just call Navigator.pushNamed(context, AppRoutes.home).
//    Adding a new screen = add one line here — no other file changes."
// =============================================================================

import 'package:flutter/material.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/announcements_screen.dart';
import '../presentation/screens/timetable_screen.dart';
import '../presentation/screens/events_screen.dart';
import '../presentation/screens/qr_display_screen.dart';

class AppRoutes {
  AppRoutes._(); // prevent instantiation — utility class

  // ---------------------------------------------------------------------------
  // Route name constants
  // ---------------------------------------------------------------------------

  static const String login         = '/';
  static const String home          = '/home';
  static const String announcements = '/announcements';
  static const String timetable     = '/timetable';
  static const String events        = '/events';
  static const String qrDisplay     = '/qr-display';

  // ---------------------------------------------------------------------------
  // Route map — passed to MaterialApp.routes
  // ---------------------------------------------------------------------------

  static final Map<String, WidgetBuilder> routes = {
    login:         (_) => const LoginScreen(),
    home:          (_) => const HomeScreen(),
    announcements: (_) => const AnnouncementsScreen(),
    timetable:     (_) => const TimetableScreen(),
    events:        (_) => const EventsScreen(),
    qrDisplay:     (_) => const QrDisplayScreen(),
  };
}
