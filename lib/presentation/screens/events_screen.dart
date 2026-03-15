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
import '../../domain/models/event.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();

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
      child: content,
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
                if (isRegistered) ...[
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
