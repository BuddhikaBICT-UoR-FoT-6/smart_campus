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
import '../../app/routes.dart';
import 'announcements_screen.dart';
import 'timetable_screen.dart';
import 'events_screen.dart';

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
  ];

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Campus'),
        actions: [
          // User avatar + name
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                if (user != null)
                  Text(
                    user.name.split(' ').first, // first name only
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.onPrimary),
                  ),
                const SizedBox(width: 6),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.onPrimary.withValues(alpha: 0.2),
                  child: const Icon(Icons.person,
                      size: 18, color: AppTheme.onPrimary),
                ),
              ],
            ),
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () {
              // Clear providers then go back to login
              context.read<AuthProvider>().logout();
              context.read<EventProvider>().reset();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
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
