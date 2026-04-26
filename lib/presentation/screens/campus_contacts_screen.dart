// =============================================================================
// presentation/screens/campus_contacts_screen.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../providers/campus_contact_provider.dart';
import '../../providers/auth_provider.dart';
import '../../domain/models/campus_contact.dart';
import '../../domain/models/user.dart';

class CampusContactsScreen extends StatefulWidget {
  const CampusContactsScreen({super.key});

  @override
  State<CampusContactsScreen> createState() => _CampusContactsScreenState();
}

class _CampusContactsScreenState extends State<CampusContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CampusContactProvider>().loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CampusContactProvider>();
    final auth = context.watch<AuthProvider>();
    final userRole = auth.currentUser?.role ?? UserRole.student;

    // Group contacts by category
    final groupedContacts = <String, List<CampusContact>>{};
    for (final contact in provider.contacts) {
      groupedContacts.putIfAbsent(contact.category, () => []).add(contact);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Details'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.contacts.isEmpty
              ? const Center(child: Text('No contacts found.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: groupedContacts.entries.map((entry) {
                    return _buildCategorySection(context, entry.key, entry.value);
                  }).toList(),
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showAddContactDialog(context, userRole),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String category, List<CampusContact> contacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
          child: Text(
            category,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...contacts.map((contact) => _buildContactCard(context, contact)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context, CampusContact contact) {

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
        child: ListTile(
          title: Text(
            contact.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact.name, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              if (contact.email.isNotEmpty)
                _buildActionRow(
                  context,
                  Icons.email_outlined,
                  contact.email,
                  () => _launchUrl('mailto:${contact.email}'),
                ),
              if (contact.phone.isNotEmpty)
                _buildActionRow(
                  context,
                  Icons.phone_outlined,
                  contact.phone,
                  () => _launchUrl('tel:${contact.phone}'),
                ),
              const SizedBox(height: 4),
              Text(
                'Added by: ${contact.addedByRole.name.toUpperCase()}',
                style: TextStyle(fontSize: 10, color: Colors.grey.withValues(alpha: 0.7)),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => _confirmDelete(context, contact),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: AppTheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context, UserRole role) {
    final nameController = TextEditingController();
    final titleController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final categoryController = TextEditingController(
      text: role == UserRole.student ? 'Student Union' : 'Department',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add ${role.name.toUpperCase()} Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Job Title / Role'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && titleController.text.isNotEmpty) {
                final newContact = CampusContact(
                  id: 'cc-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text,
                  title: titleController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                  category: categoryController.text,
                  addedByRole: role,
                );
                context.read<CampusContactProvider>().addContact(newContact);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CampusContact contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<CampusContactProvider>().deleteContact(contact.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
