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
import '../presentation/screens/admin/admin_dashboard_screen.dart';
import '../presentation/screens/admin/user_management_screen.dart';
import '../presentation/screens/admin/calendar_admin_screen.dart';
import '../presentation/screens/admin/reporting_screen.dart';
import '../presentation/screens/admin/event_admin_screen.dart';
import '../presentation/screens/admin/announcement_admin_screen.dart';
import '../presentation/screens/admin/timetable_admin_screen.dart';
import '../presentation/screens/admin/results_admin_screen.dart';
import '../presentation/screens/admin/config_admin_screen.dart';

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
  static const String adminDashboard  = '/admin/dashboard';
  static const String adminUsers      = '/admin/users';
  static const String adminCalendar   = '/admin/calendar';
  static const String adminReporting  = '/admin/reporting';
  static const String adminTimetable  = '/admin/timetable';
  static const String adminEvents     = '/admin/events';
  static const String adminResults    = '/admin/results';
  static const String adminAnnouncements = '/admin/announcements';
  static const String adminConfig     = '/admin/config';

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
      adminDashboard: (context) => const AdminDashboardScreen(),
      adminUsers:    (context) => const UserManagementScreen(),
      adminCalendar: (context) => const CalendarAdminScreen(),
      adminReporting: (context) => const ReportingScreen(),
      adminTimetable: (context) => const TimetableAdminScreen(),
      adminEvents:    (context) => const EventAdminScreen(),
      adminResults:   (context) => const ResultsAdminScreen(),
      adminAnnouncements: (context) => const AnnouncementAdminScreen(),
      adminConfig:    (context) => const ConfigAdminScreen(),
    };
  }
}
