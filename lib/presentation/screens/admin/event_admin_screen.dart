import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/event_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../domain/models/event.dart';

class EventAdminScreen extends StatefulWidget {
  const EventAdminScreen({super.key});

  @override
  State<EventAdminScreen> createState() => _EventAdminScreenState();
}

class _EventAdminScreenState extends State<EventAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<EventProvider>().loadEvents(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Administration'),
      ),
      body: eventProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : eventProvider.events.isEmpty
              ? const Center(child: Text('No events found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: eventProvider.events.length,
                  itemBuilder: (context, index) {
                    final event = eventProvider.events[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Date: ${event.date} • Venue: ${event.venue}'),
                            Text('Capacity: ${event.capacity}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEventDialog(event),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(event),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEventDialog(Event? event) {
    final titleCtrl = TextEditingController(text: event?.title);
    final descCtrl = TextEditingController(text: event?.description);
    final venueCtrl = TextEditingController(text: event?.venue);
    final dateCtrl = TextEditingController(text: event?.date);
    final capacityCtrl = TextEditingController(text: event?.capacity.toString() ?? '50');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(event == null ? 'Create Event' : 'Edit Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Event Title')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              TextField(controller: venueCtrl, decoration: const InputDecoration(labelText: 'Venue')),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
              TextField(controller: capacityCtrl, decoration: const InputDecoration(labelText: 'Capacity'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newEvent = Event(
                id: event?.id ?? 'ev-${DateTime.now().millisecondsSinceEpoch}',
                title: titleCtrl.text,
                description: descCtrl.text,
                venue: venueCtrl.text,
                date: dateCtrl.text,
                capacity: int.tryParse(capacityCtrl.text) ?? 50,
                organizerId: event?.organizerId ?? context.read<AuthProvider>().currentUser?.id ?? 'admin',
              );
              if (event == null) {
                context.read<EventProvider>().createEvent(newEvent);
              } else {
                context.read<EventProvider>().updateEvent(newEvent);
              }
              Navigator.pop(ctx);
            },
            child: Text(event == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Event event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<EventProvider>().deleteEvent(event.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
