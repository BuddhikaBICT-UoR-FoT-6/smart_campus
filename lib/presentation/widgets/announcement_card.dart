// =============================================================================
// presentation/widgets/announcement_card.dart
// =============================================================================
// Reusable card widget that displays a single campus announcement.
//
// VIVA POINT:
//   "This widget knows nothing about network or state management.
//    It just receives an Announcement object and renders it.
//    Separation of UI from data is a key Clean Architecture principle."
// =============================================================================

import 'package:flutter/material.dart';
import '../../domain/models/announcement.dart';
import '../../app/theme.dart';

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementCard({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Header row ----------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.campaign_rounded,
                      color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                // Title (flexible so long titles wrap)
                Expanded(
                  child: Text(
                    announcement.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ---------- Body ----------
            Text(
              announcement.body,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            // ---------- Footer meta ----------
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(announcement.postedBy,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                const Spacer(),
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(announcement.date,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
