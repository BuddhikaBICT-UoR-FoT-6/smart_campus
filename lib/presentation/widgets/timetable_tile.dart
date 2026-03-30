// =============================================================================
// presentation/widgets/timetable_tile.dart
// =============================================================================
// A single row in the timetable list — shows time, subject, and room.
// Now includes attendance status and navigation to details.
// =============================================================================

import 'package:flutter/material.dart';
import '../../domain/models/timetable_entry.dart';
import '../../app/theme.dart';
import '../screens/timetable_detail_screen.dart';

class TimetableTile extends StatelessWidget {
  final TimetableEntry entry;

  const TimetableTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TimetableDetailScreen(entry: entry),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // ---------- Time column ----------
              Container(
                width: 64,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.startTime,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text('|',
                        style:
                            TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 10)),
                    Text(
                      entry.endTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // ---------- Subject + room ----------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.subject,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.room_outlined,
                            size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: 4),
                        Text(
                          entry.room,
                          style: TextStyle(
                              fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ---------- Status Indicators (Attendance) ----------
              if (entry.isAttended != null)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Icon(
                    entry.isAttended! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 20,
                    color: entry.isAttended! ? Colors.green : Colors.red,
                  ),
                ),
              
              // ---------- Additional Flag ----------
              if (entry.isAdditional)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Event',
                    style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
              
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
