// =============================================================================
// presentation/screens/past_week_detail_screen.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/academic_week.dart';
import '../../providers/timetable_provider.dart';
import '../widgets/timetable_tile.dart';
import '../../app/theme.dart';

class PastWeekDetailScreen extends StatelessWidget {
  final AcademicWeek week;

  const PastWeekDetailScreen({super.key, required this.week});

  @override
  Widget build(BuildContext context) {
    // For realism in our mock scenario, we reuse the currently loaded timetable entries,
    // as our seed data contains a generic 1-week curriculum that repeats.
    final provider = context.watch<TimetableProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(week.label),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboard(context, provider),
    );
  }

  Widget _buildDashboard(BuildContext context, TimetableProvider provider) {
    if (provider.entries.isEmpty) {
      return const Center(child: Text('No attendance data found for this week.'));
    }

    final regularEntries = provider.entries.where((e) => !e.isAdditional).toList();
    final events = provider.entries.where((e) => e.isAdditional).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Week ${week.number} Overview', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(week.startDate)} - ${_formatDate(week.endDate)}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 12),
              // Simulated attendance stat
              _buildAttendanceStat(regularEntries),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        Text('Curriculum Attendance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        ...regularEntries.map((e) => TimetableTile(entry: e)),
        
        if (events.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('Past Events & Mandatory Check-ins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
          const SizedBox(height: 8),
          ...events.map((e) => TimetableTile(entry: e)),
        ],
      ],
    );
  }

  Widget _buildAttendanceStat(List<dynamic> entries) {
    int total = entries.length;
    int attended = entries.where((e) => e.isAttended == true).length;
    double percentage = total > 0 ? (attended / total) * 100 : 0.0;

    return Row(
      children: [
        const Icon(Icons.analytics_outlined, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          'Total Attendance: ${percentage.toStringAsFixed(1)}%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)}';
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
