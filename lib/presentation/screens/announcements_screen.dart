// =============================================================================
// presentation/screens/announcements_screen.dart
// =============================================================================
// Displays campus announcements fetched from the REST API.
//
// STATE HANDLING (3-state pattern):
//   isLoading = true  → CircularProgressIndicator
//   errorMessage ≠ null → error message + retry button
//   else              → ListView of AnnouncementCards
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../domain/models/user.dart';
import '../../domain/models/announcement.dart';
import '../../providers/announcement_provider.dart';
import '../widgets/announcement_card.dart';
import '../../app/theme.dart';
import 'package:shimmer/shimmer.dart'; // Extracted package for advanced loading skeletons

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnnouncementProvider>();

    // ---------- Loading ----------
    if (provider.isLoading) {
      // 1. We completely rip out the legacy `CircularProgressIndicator` which causes "jumpy" UI rendering.
      // Instead, we use `Shimmer` skeletons to outline the structural bounds of the incoming DOM elements.
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // 2. Render exactly 5 ghost elements to fill standard screen vertical real-estate
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: AppTheme.primary.withValues(alpha: 0.1), // 3. Tint the base wireframe using brand language
          highlightColor: AppTheme.onPrimary,                 // 4. Highlight sweep geometry mapped to light mode colors
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 110, // 5. Hardcoded mock height matching the geometric footprint of an AnnouncementCard
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16), // 6. Card Radiuses enforced on ghost components
            ),
          ),
        ),
      );
    }

    // ---------- Error ----------
    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 56, color: AppTheme.textSecondary),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () =>
                    // Allow the user to manually overcome broken caches during an error bounds failure
                    context.read<AnnouncementProvider>().fetchAnnouncements(forceRefresh: true),
              ),
            ],
          ),
        ),
      );
    }

    // ---------- Main Content ----------
    Widget content;
    if (provider.announcements.isEmpty) {
      content = ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Text('No announcements available.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
        ],
      );
    } else {
      content = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: provider.announcements.length,
        itemBuilder: (_, i) {
          final announcement = provider.announcements[i];
          final user = context.read<AuthProvider>().currentUser;
          // Rule: Staff can edit/delete if they are the poster or if we want all staff to manage campus feed
          final canManage = user?.role == UserRole.staff; 

          return AnnouncementCard(
            announcement: announcement,
            onEdit: canManage ? () => _showEditAnnouncementDialog(context, announcement) : null,
            onDelete: canManage ? () => _showDeleteConfirmation(context, announcement.id) : null,
          );
        },
      );
    }

    final user = context.read<AuthProvider>().currentUser;
    final isStaff = user?.role == UserRole.staff;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            // Force the underlying Provider to ignore the 5 minute strict bounds and fetch newest payload
            context.read<AnnouncementProvider>().fetchAnnouncements(forceRefresh: true),
        child: content,
      ),
      floatingActionButton: isStaff
          ? FloatingActionButton.extended(
              onPressed: () {
                _showAddAnnouncementDialog(context, user!.name);
              },
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              icon: const Icon(Icons.add),
              label: const Text('Post'),
            )
          : null,
    );
  }

  void _showAddAnnouncementDialog(BuildContext context, String posterName) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isUrgent = false;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Announcement'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: 'Message Body'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return CheckboxListTile(
                    title: const Text('Mark as Urgent (Push Notification)'),
                    value: isUrgent,
                    onChanged: (val) {
                      setState(() {
                        isUrgent = val ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<AnnouncementProvider>().addAnnouncement(
                      titleController.text,
                      bodyController.text,
                      posterName,
                      isUrgent: isUrgent,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Announcement posted successfully!')),
                );
              }
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  void _showEditAnnouncementDialog(BuildContext context, Announcement announcement) {
    final titleController = TextEditingController(text: announcement.title);
    final bodyController = TextEditingController(text: announcement.body);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Announcement'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: 'Message Body'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<AnnouncementProvider>().updateAnnouncement(
                      announcement.id,
                      titleController.text,
                      bodyController.text,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Announcement updated!')),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Announcement?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AnnouncementProvider>().deleteAnnouncement(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Announcement deleted.')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

