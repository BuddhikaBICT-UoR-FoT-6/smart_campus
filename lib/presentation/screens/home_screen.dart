// =============================================================================
// presentation/screens/home_screen.dart
// =============================================================================
// Root screen after login — BottomNavigationBar switches between the
// three main sections: Announcements, Timetable, Events.
//
// VIVA POINT:
//   "HomeScreen uses an IndexedStack to keep all tab screens alive in
//    memory. The BottomNav just changes which index is visible.
//    This is the standard Flutter pattern for persistent tab navigation."
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/timetable_provider.dart';
import 'announcements_screen.dart';
import 'timetable_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';
import 'campus_contacts_screen.dart';
import '../../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Tab definitions — keep labels and icons co-located with index
  static const List<_TabItem> _tabs = [
    _TabItem(label: 'Announcements', icon: Icons.campaign_outlined,
        activeIcon: Icons.campaign),
    _TabItem(label: 'Timetable', icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month),
    _TabItem(label: 'Events', icon: Icons.event_outlined,
        activeIcon: Icons.event),
    _TabItem(label: 'Profile', icon: Icons.person_outline,
        activeIcon: Icons.person),
  ];

  @override
  void initState() {
    super.initState();
    // Trigger initial data loads as soon as the home screen mounts
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoad());
  }

  Future<void> _initialLoad() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id ?? '';

    // Fire all three loads concurrently — don't await sequentially
    await Future.wait([
      context.read<AnnouncementProvider>().fetchAnnouncements(),
      context.read<TimetableProvider>().loadTimetable(userId),
      context.read<EventProvider>().loadEvents(userId),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Tab screens (kept alive via IndexedStack)
  // ---------------------------------------------------------------------------
  static const List<Widget> _screens = [
    AnnouncementsScreen(),
    TimetableScreen(),
    EventsScreen(),
    ProfileScreen(),
  ];

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CampusContactsScreen()),
          ),
          child: const Text('Smart Campus'),
        ),
        actions: [
          // 0. Global Refresh fulfilling UI requirement
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Data',
            onPressed: () => _initialLoad(),
          ),
          // 1. Theme Toggle Integration fulfilling UI requirement
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode 
                    ? Icons.light_mode_rounded 
                    : Icons.dark_mode_rounded),
                tooltip: 'Toggle Light/Dark Mode',
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // IndexedStack keeps all screens mounted — tab switches are instant
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: _tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  activeIcon: Icon(t.activeIcon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

// Simple data class for tab metadata
class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _TabItem(
      {required this.label, required this.icon, required this.activeIcon});
}
