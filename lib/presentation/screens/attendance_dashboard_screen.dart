// =============================================================================
// presentation/screens/attendance_dashboard_screen.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/timetable_provider.dart';
import '../../domain/models/timetable_entry.dart';
import '../../app/theme.dart';

class AttendanceDashboardScreen extends StatefulWidget {
  const AttendanceDashboardScreen({super.key});

  @override
  State<AttendanceDashboardScreen> createState() => _AttendanceDashboardScreenState();
}

class _AttendanceDashboardScreenState extends State<AttendanceDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<TimetableProvider>().loadTimetable(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timetableProvider = context.watch<TimetableProvider>();

    // Calculate attendance statistics
    final entries = timetableProvider.entries.where((e) => e.isAttended != null).toList();
    
    // Group by subject
    final Map<String, List<TimetableEntry>> grouped = {};
    for (var e in entries) {
      if (!grouped.containsKey(e.subject)) {
        grouped[e.subject] = [];
      }
      grouped[e.subject]!.add(e);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Dashboard'),
      ),
      body: timetableProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : grouped.isEmpty
              ? const Center(child: Text('No attendance records available yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, index) {
                    final subject = grouped.keys.elementAt(index);
                    final subjectEntries = grouped[subject]!;
                    final attended = subjectEntries.where((e) => e.isAttended == true).length;
                    final total = subjectEntries.length;
                    final percentage = total > 0 ? (attended / total) * 100 : 0.0;
                    
                    Color statusColor = Colors.green;
                    if (percentage < 80) statusColor = Colors.red;
                    else if (percentage < 90) statusColor = Colors.orange;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    value: total > 0 ? (attended / total) : 0,
                                    color: statusColor,
                                    backgroundColor: Colors.grey.shade200,
                                    strokeWidth: 6,
                                  ),
                                ),
                                Text('${percentage.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('Attended: $attended / $total classes', style: const TextStyle(color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
