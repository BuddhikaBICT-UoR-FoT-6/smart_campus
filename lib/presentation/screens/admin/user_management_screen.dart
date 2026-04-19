import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_management_provider.dart';
import '../../../domain/models/user.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            onPressed: () => provider.loadUsers(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : ListView.builder(
                  itemCount: provider.users.length,
                  itemBuilder: (context, index) {
                    final user = provider.users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user.name[0]),
                      ),
                      title: Text(user.name),
                      subtitle: Text('${user.role.name} • ${user.email}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showUserDialog(user),
                          ),
                          IconButton(
                            icon: Icon(
                              user.name.contains('[SUSPENDED]') ? Icons.play_arrow : Icons.pause,
                              color: Colors.orange,
                            ),
                            onPressed: () => provider.toggleSuspension(
                                user.id, !user.name.contains('[SUSPENDED]')),
                          ),
                          IconButton(
                            icon: const Icon(Icons.lock_reset, color: Colors.green),
                            onPressed: () => _showResetPasswordDialog(user),
                            tooltip: 'Reset Password',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(user),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showUserDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showUserDialog(User? user) {
    final nameController = TextEditingController(text: user?.name);
    final emailController = TextEditingController(text: user?.email);
    UserRole selectedRole = user?.role ?? UserRole.student;
    int? selectedLevel = user?.level ?? 1;
    int? selectedSemester = user?.semester ?? 1;

    bool isRepeat = user?.isRepeat ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(user == null ? 'Create User' : 'Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  items: UserRole.values
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedRole = val!),
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
                if (selectedRole == UserRole.student) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: selectedLevel,
                    items: [1, 2, 3, 4]
                        .map((l) => DropdownMenuItem(
                              value: l,
                              child: Text('Level $l'),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => selectedLevel = val),
                    decoration: const InputDecoration(labelText: 'Level/Year'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: selectedSemester,
                    items: [1, 2]
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text('Semester $s'),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => selectedSemester = val),
                    decoration: const InputDecoration(labelText: 'Semester'),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Repeat Student'),
                    value: isRepeat,
                    onChanged: (val) => setState(() => isRepeat = val),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newUser = User(
                  id: user?.id ?? 'usr-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text,
                  email: emailController.text,
                  role: selectedRole,
                  level: selectedRole == UserRole.student ? selectedLevel : null,
                  semester: selectedRole == UserRole.student ? selectedSemester : null,
                  isRepeat: selectedRole == UserRole.student ? isRepeat : false,
                );
                if (user == null) {
                  context.read<UserManagementProvider>().createUser(newUser);
                } else {
                  context.read<UserManagementProvider>().updateUser(newUser);
                }
                Navigator.pop(ctx);
              },
              child: Text(user == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<UserManagementProvider>().deleteUser(user.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(User user) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset Password for ${user.name}'),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: 'New Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 4 characters')),
                );
                return;
              }
              context.read<UserManagementProvider>().resetPassword(user.id, passwordController.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset successfully')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
