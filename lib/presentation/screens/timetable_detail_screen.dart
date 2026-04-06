// =============================================================================
// presentation/screens/timetable_detail_screen.dart
// =============================================================================

import 'package:flutter/material.dart';
import '../../domain/models/timetable_entry.dart';
import '../../app/theme.dart';

class TimetableDetailScreen extends StatelessWidget {
  final TimetableEntry entry;

  const TimetableDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.subject,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(entry.room, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                      const Spacer(),
                      const Icon(Icons.access_time, size: 18, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('${entry.startTime} - ${entry.endTime}', 
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Attendance Section (for past lectures)
            if (entry.isAttended != null) ...[
              const Text(
                'Attendance Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: entry.isAttended! ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: entry.isAttended! ? Colors.green : Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(
                      entry.isAttended! ? Icons.check_circle_outline : Icons.highlight_off,
                      color: entry.isAttended! ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      entry.isAttended! ? 'Attended' : 'Missed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: entry.isAttended! ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Content Section
            const Text(
              'Session Content Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              entry.lectureContent ?? 'No detailed content description available for this session.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Additional Note
            if (entry.isAdditional)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is a mandatory additional event. Attendance is strictly recorded.',
                        style: TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
