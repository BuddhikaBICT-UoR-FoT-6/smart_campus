// =============================================================================
// presentation/screens/profile_screen.dart
// =============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';

import '../../domain/models/user.dart';
import '../../providers/event_provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../widgets/academic_performance_widget.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- 1. Avatar & Hero Section ----------
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      backgroundImage: user.profilePic != null && user.profilePic!.isNotEmpty
                          ? FileImage(File(user.profilePic!))
                          : null,
                      child: user.profilePic == null || user.profilePic!.isEmpty
                        ? Text(
                            user.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary),
                          )
                        : null,
                    ),
                    Container(
                      decoration: const BoxDecoration(color: AppTheme.secondary, shape: BoxShape.circle),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.isRepeat ? Colors.amber : AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.role.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.w600, 
                          color: user.isRepeat ? Colors.black : AppTheme.primary
                        ),
                      ),
                    ),
                    if (user.role == UserRole.student && user.level != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.isRepeat ? Colors.amber : AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'LEVEL ${user.level}',
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.w600, 
                            color: user.isRepeat ? Colors.black : AppTheme.primary
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.isRepeat ? Colors.amber : AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'SEM ${user.semester}',
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.w600, 
                            color: user.isRepeat ? Colors.black : AppTheme.primary
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // ---------- 2. Personal Details Section ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow(context, Icons.email_outlined, 'Email', user.email),
          _buildInfoRow(context, Icons.location_on_outlined, 'Address', user.address ?? 'Not specified'),
          
          const SizedBox(height: 32),

          // ---------- 3. Emergency Details Section ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Emergency Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              IconButton.filledTonal(
                onPressed: () async {
                  final phone = user.emergencyPhone;
                  if (phone != null && phone.isNotEmpty) {
                    final uri = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not launch dialer for $phone')),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No emergency contact number saved.')),
                    );
                  }
                },
                icon: const Icon(Icons.emergency_share, color: Colors.red),
                tooltip: 'Emergency Call',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(context, Icons.person_outline, 'Contact Person', user.emergencyName ?? 'Not specified'),
          _buildInfoRow(context, Icons.phone_outlined, 'Phone', user.emergencyPhone ?? 'Not specified'),

          const SizedBox(height: 16),

          // ---------- 5. Academic Portal Section (Student Only) ----------
          if (user.role == UserRole.student) ...[
            const Text(
              'Academic Portal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.app_registration),
                label: const Text('Course Registration'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.courseRegistration);
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.laptop_chromebook),
                label: const Text('Learning Management System (LMS)'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.lms);
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Attendance Dashboard'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.attendanceDashboard);
                },
              ),
            ),
            const SizedBox(height: 24),
            const AcademicPerformanceWidget(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.medical_services),
                label: const Text('Submit Medical Clearance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.medicalSubmission);
                },
              ),
            ),
            const SizedBox(height: 64),
          ],
          
          // ---------- 6. Notifications & Settings ----------
          const Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildToggleRow(
            context,
            Icons.email_outlined,
            'Email Alerts',
            user.emailAlerts,
            (val) {
              final updatedUser = user.copyWith(emailAlerts: val);
              context.read<AuthProvider>().updateUserProfile(updatedUser);
            },
          ),
          const SizedBox(height: 12),
          
          // ---------- 6. Session Actions ----------
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline, color: AppTheme.error),
              label: const Text('Clear Storage Cache', style: TextStyle(color: AppTheme.error)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.error)),
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              onPressed: () {
                context.read<AuthProvider>().logout();
                context.read<EventProvider>().reset();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppTheme.textSecondary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Text(
                value, 
                style: TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(BuildContext context, IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppTheme.textSecondary),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
