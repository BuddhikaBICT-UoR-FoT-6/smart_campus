// =============================================================================
// presentation/screens/timetable_screen.dart
// =============================================================================
// Displays the logged-in student's weekly timetable with modern tabbed navigation.
// Features: 
//   - 5-day Week Selector
//   - Additional Mandatory Events section
//   - Automatic current-day focus
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/timetable_provider.dart';
import '../../domain/models/timetable_entry.dart';
import '../widgets/timetable_tile.dart';
import '../../app/theme.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  static const List<String> _weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'
  ];

  @override
  void initState() {
    super.initState();
    // 1. Calculate the current weekday index (0-4) to auto-select the tab
    final now = DateTime.now();
    // DateTime.weekday: 1 = Mon, 7 = Sun. We clamp to 0-4 for Mon-Fri.
    int initialIndex = now.weekday - 1;
    if (initialIndex > 4) initialIndex = 0; // Fallback to Monday if weekend
    
    _tabController = TabController(length: _weekDays.length, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimetableProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return _buildErrorState(context, provider.errorMessage!);
    }

    return Column(
      children: [
        // 2. Weekday Selector fulfilling Tabbed UI requirement
        Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0.5,
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            tabs: _weekDays.map((d) => Tab(text: d.substring(0, 3))).toList(),
          ),
        ),

        // 3. Main Schedule List
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _weekDays.map((day) {
              final dayEntries = provider.entries.where((e) {
                final isSameDay = e.dayOfWeek == day;
                final isReg = !(e.isAdditional);
                return isSameDay && isReg;
              }).toList();
              
              final additionalEntries = provider.entries.where((e) {
                final isSameDay = e.dayOfWeek == day;
                final isAdd = e.isAdditional;
                return isSameDay && isAdd;
              }).toList();

              if (dayEntries.isEmpty && additionalEntries.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  final userId = context.read<AuthProvider>().currentUser?.id ?? '';
                  await context.read<TimetableProvider>().loadTimetable(userId);
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    // Regular Sessions
                    if (dayEntries.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text('Regular Lectures', 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 13, 
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            )),
                      ),
                      ...dayEntries.map((e) => TimetableTile(entry: e)),
                    ],

                    // 4. Additional Mandatory Section fulfilling UI requirement
                    if (additionalEntries.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.star_outline, size: 16, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Additional & Mandatory Sessions', 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange)),
                          ],
                        ),
                      ),
                      ...additionalEntries.map((e) => TimetableTile(entry: e)),
                    ],
                    const SizedBox(height: 100), // Spacing for fab/bottom bar
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final userId = context.read<AuthProvider>().currentUser?.id ?? '';
              context.read<TimetableProvider>().loadTimetable(userId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No sessions scheduled for this day.', 
              style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
