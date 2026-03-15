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
      return Center(
        child: Text(provider.errorMessage!,
            style: const TextStyle(color: AppTheme.textSecondary)),
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

