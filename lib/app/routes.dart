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
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/semester_overview_screen.dart';
import '../presentation/screens/qr_scanner_screen.dart';
import '../presentation/screens/campus_map_screen.dart';
import '../presentation/screens/attendee_log_screen.dart';

class AppRoutes {
  AppRoutes._(); // prevent instantiation — utility class

  // ---------------------------------------------------------------------------
  // Route name constants
  // ---------------------------------------------------------------------------

  static const String splash          = '/';
  static const String login           = '/login';
  static const String home            = '/home';
  static const String announcements   = '/announcements';
  static const String timetable       = '/timetable';
  static const String events          = '/events';
  static const String qrDisplay       = '/qr-display';
  static const String semesterOverview = '/semester-overview';
  static const String qrScanner       = '/qr-scanner';
  static const String campusMap       = '/campus-map';
  static const String attendeeLog     = '/attendee-log';

  // ---------------------------------------------------------------------------
  // Route map — passed to MaterialApp.routes
  // ---------------------------------------------------------------------------

  static Map<String, WidgetBuilder> get routes {
    return {
      splash:        (context) => const SplashScreen(),
      login:         (context) => const LoginScreen(),
      home:          (context) => const HomeScreen(),
      announcements: (context) => const AnnouncementsScreen(),
      timetable:     (context) => const TimetableScreen(),
      events:        (context) => const EventsScreen(),
      qrDisplay:     (context) => const QrDisplayScreen(),
      semesterOverview: (context) => const SemesterOverviewScreen(),
      qrScanner:     (context) => const QrScannerScreen(),
      campusMap:     (context) => const CampusMapScreen(),
      attendeeLog:   (context) => const AttendeeLogScreen(),
    };
  }
}
