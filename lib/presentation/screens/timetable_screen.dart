// =============================================================================
// presentation/screens/timetable_screen.dart
// =============================================================================
// Displays the logged-in student's weekly timetable from local SQLite.
// Entries are grouped by day-of-week for readability.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/timetable_provider.dart';
import '../../domain/models/timetable_entry.dart';
import '../widgets/timetable_tile.dart';
import '../../app/theme.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  // Ordered days so the list always appears Monday → Friday
  static const List<String> _dayOrder = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
    'Saturday', 'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimetableProvider>();

    // ---------- Loading ----------
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ---------- Error ----------
    if (provider.errorMessage != null) {
      // 1. If an error is detected, bypass the main UI rendering and surface the Error boundary
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 2. Render a visually commanding error icon to signal immediate system failure
              const Icon(Icons.error_outline_rounded,
                  size: 56, color: AppTheme.textSecondary),
              const SizedBox(height: 16),
              // 3. Output the exact exception message bubbled up from the Provider layer
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              // 4. Implement a distinct Retry button to fulfill Tri-State bounds requirement
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () {
                  // 5. Safely extract the globally authenticated UserId to re-trigger the data fetch
                  final userId = context.read<AuthProvider>().currentUser?.id ?? '';
                  context.read<TimetableProvider>().loadTimetable(userId);
                },
              ),
            ],
          ),
        ),
      );
    }

    // ---------- Empty ----------
    Widget content;
    if (provider.entries.isEmpty) {
      content = ListView(
        children: const [
          SizedBox(height: 100),
          Center(
            child: Text('No timetable entries found.',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      );
    } else {
      // ---------- Group entries by day ----------
      final Map<String, List<TimetableEntry>> grouped = {};
      for (final entry in provider.entries) {
        grouped.putIfAbsent(entry.dayOfWeek, () => []).add(entry);
      }

      // Collect only days that have entries, in canonical order
      final presentDays = _dayOrder
          .where((d) => grouped.containsKey(d))
          .toList();

      content = ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 20),
        itemCount: presentDays.length,
        itemBuilder: (_, i) {
          final day = presentDays[i];
          final dayEntries = grouped[day]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Entries for this day
              ...dayEntries.map((e) => TimetableTile(entry: e)),
              const SizedBox(height: 4),
            ],
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        final userId = context.read<AuthProvider>().currentUser?.id ?? '';
        return context.read<TimetableProvider>().loadTimetable(userId);
      },
      child: content,
    );
  }
}

