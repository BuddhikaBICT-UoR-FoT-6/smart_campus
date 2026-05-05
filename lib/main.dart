// =============================================================================
// main.dart — Application Entry Point (updated)
// =============================================================================
// Changes from initial scaffold:
//   - Added AppTheme.light as the MaterialApp theme
//   - Added TimetableProvider to MultiProvider so all screens can access it
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/routes.dart';
import 'app/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/event_provider.dart';
import 'providers/timetable_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/user_management_provider.dart';
import 'providers/results_provider.dart';
import 'providers/medical_provider.dart';
import 'providers/module_provider.dart';
import 'providers/lms_provider.dart';
import 'providers/campus_contact_provider.dart';
import 'data/remote/mysql_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize MySQL background pathways seamlessly
  try {
    await MySqlDatabase.getConnection();
  } catch (e) {
    debugPrint('[MySQL Startup] Failed to connect: $e');
  }

  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()..loadCalendar()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProvider(create: (_) => ResultsProvider()),
        ChangeNotifierProvider(create: (_) => MedicalProvider()),
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
        ChangeNotifierProvider(create: (_) => LmsProvider()),
        ChangeNotifierProvider(create: (_) => CampusContactProvider()..loadContacts()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Smart Campus',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            routes: AppRoutes.routes,
            initialRoute: AppRoutes.splash,
          );
        },
      ),
    );
  }
}
