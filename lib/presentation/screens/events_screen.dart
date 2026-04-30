// =============================================================================
// presentation/screens/events_screen.dart
// =============================================================================
// Shows all campus events with a Register button.
// Registered events show a "Registered ✓" chip and a QR button.
//
// VIVA POINT:
//   "The Register button checks EventProvider.isRegistered() to decide
//    its style. After registering, the provider updates its Set<String>
//    and notifyListeners() rebuilds this widget automatically."
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../domain/models/user.dart';
import '../../domain/models/event.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import 'package:shimmer/shimmer.dart'; // Advanced declarative skeleton framework component package

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => EventsScreenState();
}

class EventsScreenState extends State<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();

    // ---------- Loading ----------
    if (provider.isLoading) {
      // 1. Implementing structural Shimmer lists prevents Layout Shift (CLS) when network payloads eventually resolve
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4, // 2. Generating 4 synthetic event blocks
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: AppTheme.primary.withValues(alpha: 0.08), // 3. Base wireframe layout color bounds mapped to theme
          highlightColor: Colors.white, // 4. White flash overlay mapping
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 180, // 5. Simulating the much larger 180px height footprint of an Event Card vs an Announcement
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }

    // ---------- Error ----------
    if (provider.errorMessage != null) {
      return Center(
        child: Text(provider.errorMessage!,
            style: const TextStyle(color: AppTheme.textSecondary)),
      );
    }

    // ---------- Main Content ----------
    Widget content;
    if (provider.events.isEmpty) {
      content = ListView(
        children: const [
          SizedBox(height: 100),
          Center(
              child: Text('No upcoming events.',
                  style: TextStyle(color: AppTheme.textSecondary))),
        ],
      );
    } else {
      content = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: provider.events.length,
        itemBuilder: (_, i) => _EventCard(event: provider.events[i]),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        final userId = context.read<AuthProvider>().currentUser?.id ?? '';
        return context.read<EventProvider>().loadEvents(userId);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: content,
        floatingActionButton: context.read<AuthProvider>().currentUser?.role == UserRole.staff
            ? FloatingActionButton.extended(
                onPressed: () => _showEventDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Event'),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              )
            : null,
      ),
    );
  }

  void _showEventDialog(BuildContext context, {Event? event}) {
    final titleController = TextEditingController(text: event?.title);
    final descController = TextEditingController(text: event?.description);
    final venueController = TextEditingController(text: event?.venue);
    final dateController = TextEditingController(text: event?.date);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(event == null ? 'Create Event' : 'Edit Event'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Event Title'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: venueController,
                  decoration: const InputDecoration(labelText: 'Venue'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date (YYYY-MM-DD)',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(dateController.text) ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      dateController.text = picked.toIso8601String().split('T').first;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newEvent = Event(
                  id: event?.id ?? 'evt-${DateTime.now().millisecondsSinceEpoch}',
                  title: titleController.text,
                  description: descController.text,
                  venue: venueController.text,
                  date: dateController.text,
                  organizer: event?.organizer ?? context.read<AuthProvider>().currentUser?.name ?? 'Staff',
                );
                if (event == null) {
                  context.read<EventProvider>().createEvent(newEvent);
                } else {
                  context.read<EventProvider>().updateEvent(newEvent);
                }
                Navigator.pop(ctx);
              }
            },
            child: Text(event == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private event card widget
// ---------------------------------------------------------------------------
class _EventCard extends StatelessWidget {
  final Event event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final evtProvider = context.watch<EventProvider>();
    final authProvider = context.read<AuthProvider>();
    final isRegistered = evtProvider.isRegistered(event.id);
    final userId = authProvider.currentUser?.id ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Title row ----------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event,
                      color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.organizer,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (authProvider.currentUser?.role == UserRole.staff) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                    onPressed: () => (context.findAncestorStateOfType<EventsScreenState>() as dynamic)?._showEventDialog(context, event: event),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    onPressed: () => _showDeleteEventConfirmation(context, event.id),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),

            // ---------- Description ----------
            Text(
              event.description,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
            ),

            const SizedBox(height: 12),

            // ---------- Meta chips ----------
            Wrap(
              spacing: 8,
              children: [
                _MetaChip(icon: Icons.calendar_today, label: event.date),
                _MetaChip(icon: Icons.location_on_outlined, label: event.venue),
              ],
            ),

            const SizedBox(height: 14),

            // ---------- Action row ----------
            Row(
              children: [
                if (authProvider.currentUser?.role == UserRole.staff) ...[
                  Icon(Icons.people_outline, size: 16, color: AppTheme.primary.withValues(alpha: 0.6)),
                  const SizedBox(width: 4),
                  Text(
                    '${evtProvider.getRegistrationCount(event.id)} Registered',
                    style: TextStyle(
                      fontSize: 13, 
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary.withValues(alpha: 0.8),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.list_alt, size: 18),
                    label: const Text('Attendees'),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.attendeeLog),
                  ),
                ] else if (isRegistered) ...[
                  // Show "Registered" badge
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 18),
                  const SizedBox(width: 6),
                  const Text('Registered',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  const Spacer(),
                  // QR pass button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: const Text('View QR'),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.qrDisplay,
                      arguments: {
                        'userId': userId,
                        'eventId': event.id,
                        'eventTitle': event.title,
                      },
                    ),
                  ),
                ] else ...[
                  // Register button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await context
                            .read<EventProvider>()
                            .register(userId, event.id);
                      },
                      child: const Text('Register'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteEventConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event?'),
        content: const Text('This will permanently remove the event.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<EventProvider>().deleteEvent(id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.primary),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
        ],
      ),
    );
  }
}
