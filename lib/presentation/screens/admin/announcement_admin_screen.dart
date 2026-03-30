import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/announcement_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../domain/models/announcement.dart';

class AnnouncementAdminScreen extends StatefulWidget {
  const AnnouncementAdminScreen({super.key});

  @override
  State<AnnouncementAdminScreen> createState() => _AnnouncementAdminScreenState();
}

class _AnnouncementAdminScreenState extends State<AnnouncementAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().fetchAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnnouncementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Management'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.announcements.isEmpty
              ? const Center(child: Text('No announcements found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: provider.announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = provider.announcements[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(announcement.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${announcement.postedBy} • ${announcement.date}\n${announcement.body}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showDialog(announcement),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => provider.deleteAnnouncement(announcement.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDialog(Announcement? announcement) {
    final titleCtrl = TextEditingController(text: announcement?.title);
    final bodyCtrl = TextEditingController(text: announcement?.body);
    bool isUrgent = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(announcement == null ? 'Post Announcement' : 'Edit Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 12),
                TextField(controller: bodyCtrl, decoration: const InputDecoration(labelText: 'Body'), maxLines: 4),
                if (announcement == null)
                  CheckboxListTile(
                    title: const Text('Send Push Notification (Urgent)'),
                    value: isUrgent,
                    onChanged: (val) => setState(() => isUrgent = val!),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (announcement == null) {
                  final userName = context.read<AuthProvider>().currentUser?.name ?? 'Admin';
                  context.read<AnnouncementProvider>().addAnnouncement(
                    titleCtrl.text,
                    bodyCtrl.text,
                    userName,
                    isUrgent: isUrgent,
                  );
                } else {
                  context.read<AnnouncementProvider>().updateAnnouncement(
                    announcement.id,
                    titleCtrl.text,
                    bodyCtrl.text,
                  );
                }
                Navigator.pop(ctx);
              },
              child: Text(announcement == null ? 'Post' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
