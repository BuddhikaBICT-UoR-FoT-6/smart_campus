// =============================================================================
// presentation/screens/campus_contacts_screen.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';

class CampusContactsScreen extends StatelessWidget {
  const CampusContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOfficerCard(
            context,
            title: 'Dean',
            name: 'Prof. J.K. Abeysekara',
            email: 'dean@fot.uor.lk',
            phone: '+94 41 222 3344',
          ),
          _buildOfficerCard(
            context,
            title: 'Assistant Registrar',
            name: 'Mr. Sarath Gamage',
            email: 'ar@fot.uor.lk',
            phone: '+94 41 222 3456',
          ),
          const SizedBox(height: 24),
          const Text(
            'Department Lecturers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDepartmentSection(
            context,
            dept: 'Information & Communication Technology (ICT)',
            contacts: [
              {'name': 'Dr. K. Silva', 'email': 'ksilva@ict.uor.lk'},
              {'name': 'Mr. P. Gamage', 'email': 'pgamage@ict.uor.lk'},
            ],
          ),
          _buildDepartmentSection(
            context,
            dept: 'Biosystems Technology (BST)',
            contacts: [
              {'name': 'Dr. M. Perera', 'email': 'mperera@bst.uor.lk'},
              {'name': 'Ms. L. Jayasuriya', 'email': 'ljaya@bst.uor.lk'},
            ],
          ),
          _buildDepartmentSection(
            context,
            dept: 'Engineering Technology (ET)',
            contacts: [
              {'name': 'Dr. R. Kumara', 'email': 'rk@et.uor.lk'},
              {'name': 'Mr. S. Wickramasinghe', 'email': 'sw@et.uor.lk'},
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfficerCard(BuildContext context, {
    required String title,
    required String name,
    required String email,
    required String phone,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
        child: ListTile(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppTheme.primary : AppTheme.primary)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _launchUrl('mailto:$email'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(email, style: TextStyle(color: AppTheme.primary, decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () => _launchUrl('tel:$phone'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(phone, style: TextStyle(color: AppTheme.primary, decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentSection(BuildContext context, {
    required String dept,
    required List<Map<String, String>> contacts,
  }) {
    return ExpansionTile(
      title: Text(dept, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      children: contacts.map((c) => ListTile(
        title: Text(c['name']!),
        subtitle: Text(c['email']!),
        leading: const Icon(Icons.person_outline),
        trailing: IconButton(
          icon: Icon(Icons.mail_outline, color: AppTheme.primary),
          onPressed: () => _launchUrl('mailto:${c['email']}'),
        ),
      )).toList(),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Could not launch $urlString: $e');
    }
  }
}
