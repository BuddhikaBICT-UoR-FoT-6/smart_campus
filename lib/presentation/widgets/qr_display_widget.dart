// =============================================================================
// presentation/widgets/qr_display_widget.dart
// =============================================================================
// Wraps the qr_flutter QrImageView — displays a QR code for an event pass.
//
// The QR data string encodes: "CAMPUS_EVENT|{userId}|{eventId}"
// This is enough for a door scanner (or viva demo) to verify registration.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../app/theme.dart';

class QrDisplayWidget extends StatelessWidget {
  /// The data encoded inside the QR code.
  final String qrData;

  /// Optional label shown below the QR code (e.g. event title).
  final String? label;

  const QrDisplayWidget({
    super.key,
    required this.qrData,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---------- QR code container ----------
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 220.0,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppTheme.primary,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppTheme.textPrimary,
            ),
          ),
        ),

        // ---------- Label ----------
        if (label != null) ...[
          const SizedBox(height: 16),
          Text(
            label!,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
