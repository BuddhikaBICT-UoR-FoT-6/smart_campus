import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/calendar_provider.dart';
import '../../../domain/models/academic_week.dart';

class CalendarAdminScreen extends StatelessWidget {
  const CalendarAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Calendar Admin'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.weeks.length,
              itemBuilder: (context, index) {
                final week = provider.weeks[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(week.number.toString())),
                  title: Text(week.label),
                  subtitle: Text('${week.type.name.toUpperCase()} • ${week.startDate.toString().split(' ')[0]} to ${week.endDate.toString().split(' ')[0]}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showWeekDialog(context, week),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => provider.deleteWeek(week.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWeekDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showWeekDialog(BuildContext context, AcademicWeek? week) {
    final labelController = TextEditingController(text: week?.label);
    final numberController = TextEditingController(text: week?.number.toString());
    WeekType selectedType = week?.type ?? WeekType.academic;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(week == null ? 'Add Week' : 'Edit Week'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: 'Week Number'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(labelText: 'Label (e.g. Week 01)'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<WeekType>(
                  initialValue: selectedType,
                  items: WeekType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase())))
                      .toList(),
                  onChanged: (val) => setState(() => selectedType = val!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newWeek = AcademicWeek(
                  id: week?.id,
                  number: int.parse(numberController.text),
                  label: labelController.text,
                  type: selectedType,
                  startDate: week?.startDate ?? DateTime.now(),
                  endDate: week?.endDate ?? DateTime.now().add(const Duration(days: 7)),
                );
                if (week == null) {
                  context.read<CalendarProvider>().addWeek(newWeek);
                } else {
                  context.read<CalendarProvider>().updateWeek(newWeek);
                }
                Navigator.pop(ctx);
              },
              child: Text(week == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
