// =============================================================================
// presentation/screens/semester_overview_screen.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/calendar_provider.dart';
import '../../domain/models/academic_week.dart';
import '../../app/theme.dart';

class SemesterOverviewScreen extends StatelessWidget {
  const SemesterOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calendar = context.watch<CalendarProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Semester 2026'),
      ),
      body: calendar.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: calendar.weeks.length,
              itemBuilder: (context, index) {
                final week = calendar.weeks[index];
                final isCurrent = calendar.currentWeek?.number == week.number;

                return _AcademicWeekTile(week: week, isCurrent: isCurrent);
              },
            ),
    );
  }
}

class _AcademicWeekTile extends StatelessWidget {
  final AcademicWeek week;
  final bool isCurrent;

  const _AcademicWeekTile({required this.week, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    switch (week.type) {
      case WeekType.academic:
        typeColor = AppTheme.primary;
        break;
      case WeekType.vacation:
        typeColor = Colors.green;
        break;
      case WeekType.exam:
        typeColor = Colors.red;
        break;
      case WeekType.result:
        typeColor = Colors.orange;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrent 
            ? typeColor.withOpacity(0.1) 
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isCurrent ? Border.all(color: typeColor, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: typeColor,
          child: Text(
            '${week.number}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          week.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCurrent ? typeColor : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${_formatDate(week.startDate)} - ${_formatDate(week.endDate)}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
        trailing: isCurrent 
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'CURRENT',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : null,
      ),
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
