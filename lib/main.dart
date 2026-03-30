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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()..loadCalendar()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
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
