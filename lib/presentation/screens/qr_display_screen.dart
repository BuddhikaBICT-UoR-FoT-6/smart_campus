// =============================================================================
// presentation/screens/qr_display_screen.dart
// =============================================================================
// Displays the event registration QR code pass.
//
// RECEIVES via Navigator arguments (Map<String, String>):
//   userId     — the registered student's ID
//   eventId    — the event ID
//   eventTitle — shown as the label under the QR code
//
// QR data format: "CAMPUS_EVENT|{userId}|{eventId}"
// This is enough for a real scanner to verify registration.
// =============================================================================

import 'package:flutter/material.dart';

import '../widgets/qr_display_widget.dart';
import '../../app/theme.dart';

class QrDisplayScreen extends StatelessWidget {
  const QrDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Read arguments passed via Navigator.pushNamed
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    final userId     = args?['userId']     ?? 'unknown';
    final eventId    = args?['eventId']    ?? 'unknown';
    final eventTitle = args?['eventTitle'] ?? 'Event';

    // The data string encoded in the QR code
    final qrData = 'CAMPUS_EVENT|$userId|$eventId';

    return Scaffold(
      appBar: AppBar(title: const Text('Your Registration Pass')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // ---------- Header ----------
              const Text(
                'Registration Confirmed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Show this QR code at the event entrance.',
                style:
                    TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              // ---------- QR code ----------
              Center(
                child: QrDisplayWidget(
                  qrData: qrData,
                  label: eventTitle,
                ),
              ),

              const SizedBox(height: 36),

              // ---------- Details card ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pass Details',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary)),
                    const Divider(height: 16),
                    _DetailRow(label: 'Event', value: eventTitle),
                    _DetailRow(label: 'User ID', value: userId),
                    _DetailRow(label: 'Event ID', value: eventId),
                    _DetailRow(label: 'Status', value: '✅ Registered'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ---------- Done button ----------
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
