import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/timetable_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../domain/models/timetable_entry.dart';
import '../../../domain/models/user.dart';
import '../../../data/local/database_helper.dart';

class TimetableAdminScreen extends StatefulWidget {
  const TimetableAdminScreen({super.key});

  @override
  State<TimetableAdminScreen> createState() => _TimetableAdminScreenState();
}

class _TimetableAdminScreenState extends State<TimetableAdminScreen> {
  List<User> _users = [];
  User? _selectedUser;
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('users');
    setState(() {
      _users = rows.map((r) => User.fromMap(r)).toList();
      _isLoadingUsers = false;
    });
  }

  void _selectUser(User user) {
    setState(() {
      _selectedUser = user;
    });
    context.read<TimetableProvider>().loadTimetable(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final timetableProvider = context.watch<TimetableProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Administration'),
        actions: [
          if (_selectedUser != null)
            IconButton(
              icon: const Icon(Icons.person_search),
              onPressed: () => setState(() => _selectedUser = null),
            ),
        ],
      ),
      body: _isLoadingUsers
          ? const Center(child: CircularProgressIndicator())
          : _selectedUser == null
              ? _buildUserList()
              : _buildTimetableEditor(timetableProvider),
      floatingActionButton: _selectedUser != null
          ? FloatingActionButton(
              onPressed: () => _showEntryDialog(null),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(user.name),
          subtitle: Text('${user.role.name.toUpperCase()} • ${user.email}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _selectUser(user),
        );
      },
    );
  }

  Widget _buildTimetableEditor(TimetableProvider provider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Row(
            children: [
              const Icon(Icons.edit_calendar, color: Colors.blue),
              const SizedBox(width: 12),
              Text(
                'Managing Timetable for: ${_selectedUser!.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.entries.isEmpty
                  ? const Center(child: Text('No entries found for this user.'))
                  : ListView.builder(
                      itemCount: provider.entries.length,
                      itemBuilder: (context, index) {
                        final entry = provider.entries[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(entry.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${entry.dayOfWeek} • ${entry.startTime} - ${entry.endTime}\nRoom: ${entry.room}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEntryDialog(entry),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => provider.deleteEntry(entry.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showEntryDialog(TimetableEntry? entry) {
    final subjectCtrl = TextEditingController(text: entry?.subject);
    final roomCtrl = TextEditingController(text: entry?.room);
    final startCtrl = TextEditingController(text: entry?.startTime ?? '08:00');
    final endCtrl = TextEditingController(text: entry?.endTime ?? '10:00');
    String day = entry?.dayOfWeek ?? 'Monday';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(entry == null ? 'Add Entry' : 'Edit Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
                DropdownButtonFormField<String>(
                  initialValue: day,
                  items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) => setState(() => day = val!),
                  decoration: const InputDecoration(labelText: 'Day'),
                ),
                TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Start Time (HH:mm)')),
                TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'End Time (HH:mm)')),
                TextField(controller: roomCtrl, decoration: const InputDecoration(labelText: 'Room')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newEntry = TimetableEntry(
                  id: entry?.id ?? 'tt-${DateTime.now().millisecondsSinceEpoch}',
                  subject: subjectCtrl.text,
                  dayOfWeek: day,
                  startTime: startCtrl.text,
                  endTime: endCtrl.text,
                  room: roomCtrl.text,
                  userId: _selectedUser!.id,
                );
                if (entry == null) {
                  context.read<TimetableProvider>().addEntry(newEntry);
                } else {
                  context.read<TimetableProvider>().updateEntry(newEntry);
                }
                Navigator.pop(ctx);
              },
              child: Text(entry == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
