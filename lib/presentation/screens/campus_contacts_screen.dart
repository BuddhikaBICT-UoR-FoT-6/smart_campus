// =============================================================================
// presentation/screens/campus_contacts_screen.dart
// =============================================================================

import 'package:flutter/material.dart';
import '../../app/theme.dart';

class CampusContactsScreen extends StatelessWidget {
  const CampusContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Directory'),
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
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppTheme.primary : AppTheme.primary)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 14),
                const SizedBox(width: 8),
                Text(email),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14),
                const SizedBox(width: 8),
                Text(phone),
              ],
            ),
          ],
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
          icon: const Icon(Icons.mail_outline),
          onPressed: () {},
        ),
      )).toList(),
    );
  }
}
