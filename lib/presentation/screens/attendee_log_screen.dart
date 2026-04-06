import 'package:flutter/material.dart';
import '../../app/theme.dart';

class AttendeeLogScreen extends StatelessWidget {
  const AttendeeLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for attendees
    final List<Map<String, String>> attendees = [
      {'name': 'Kasun Jayawardena', 'time': '10:05 AM', 'id': 'IT21001'},
      {'name': 'Tharushi Perera', 'time': '10:12 AM', 'id': 'IT21045'},
      {'name': 'Nimna Silva', 'time': '10:15 AM', 'id': 'IT21023'},
      {'name': 'Akila Madushan', 'time': '10:20 AM', 'id': 'IT21102'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendee Log'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: attendees.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final attendee = attendees[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              child: Text(attendee['name']![0], style: const TextStyle(color: AppTheme.primary)),
            ),
            title: Text(attendee['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('ID: ${attendee['id']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Verified', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(attendee['time']!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          );
        },
      ),
    );
  }
}
