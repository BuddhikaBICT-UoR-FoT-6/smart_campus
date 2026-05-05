// =============================================================================
// presentation/screens/lms_screen.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/module_provider.dart';
import '../../providers/lms_provider.dart';
import '../../providers/theme_provider.dart';
import '../../app/theme.dart';

class LmsScreen extends StatefulWidget {
  const LmsScreen({super.key});

  @override
  State<LmsScreen> createState() => _LmsScreenState();
}

class _LmsScreenState extends State<LmsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<ModuleProvider>().loadModules(user.id);
      }
    });
  }

  void _showMaterials(BuildContext context, String moduleId, String moduleName) {
    context.read<LmsProvider>().loadMaterialsForModule(moduleId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, controller) {
            final lmsProvider = ctx.watch<LmsProvider>();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    moduleName, 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: lmsProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : lmsProvider.materials.isEmpty
                          ? Center(child: Text('No materials uploaded yet.', style: Theme.of(context).textTheme.bodyMedium))
                          : ListView.builder(
                              controller: controller,
                              itemCount: lmsProvider.materials.length,
                              itemBuilder: (context, index) {
                                final mat = lmsProvider.materials[index];
                                final isPdf = mat.type == 'pdf';
                                return ListTile(
                                  leading: Icon(
                                    isPdf ? Icons.picture_as_pdf : Icons.assignment,
                                    color: isPdf ? Colors.red : Colors.blue,
                                  ),
                                  title: Text(mat.title),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(mat.description),
                                      if (mat.deadline != null)
                                        Text(
                                          'Due: ${mat.deadline}', 
                                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Downloading ${mat.title}...')),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = context.watch<ModuleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Management System'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode 
                    ? Icons.light_mode_rounded 
                    : Icons.dark_mode_rounded),
                tooltip: 'Toggle Theme',
                onPressed: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: moduleProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : moduleProvider.enrolledModules.isEmpty
              ? const Center(child: Text('You are not enrolled in any modules.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: moduleProvider.enrolledModules.length,
                  itemBuilder: (context, index) {
                    final module = moduleProvider.enrolledModules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.primary,
                          child: Icon(Icons.book, color: Colors.white),
                        ),
                        title: Text('${module.code} - ${module.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Credits: ${module.credits}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showMaterials(context, module.id, module.name),
                      ),
                    );
                  },
                ),
    );
  }
}
