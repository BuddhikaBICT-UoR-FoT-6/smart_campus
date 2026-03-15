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
import '../../providers/announcement_provider.dart';
import '../widgets/announcement_card.dart';
import '../../app/theme.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnnouncementProvider>();

    // ---------- Loading ----------
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () =>
                    context.read<AnnouncementProvider>().fetchAnnouncements(),
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
        children: const [
          SizedBox(height: 100),
          Center(
            child: Text('No announcements available.',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      );
    } else {
      content = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: provider.announcements.length,
        itemBuilder: (_, i) =>
            AnnouncementCard(announcement: provider.announcements[i]),
      );
    }

    final user = context.read<AuthProvider>().currentUser;
    final isStaff = user?.role == UserRole.staff;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<AnnouncementProvider>().fetchAnnouncements(),
        child: content,
      ),
      floatingActionButton: isStaff
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Staff feature: Add Announcement dialog')),
                );
              },
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              icon: const Icon(Icons.add),
              label: const Text('Post'),
            )
          : null,
    );
  }
}

