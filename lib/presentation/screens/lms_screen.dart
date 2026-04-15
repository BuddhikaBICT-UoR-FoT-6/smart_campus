// =============================================================================
// presentation/screens/lms_screen.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/module_provider.dart';
import '../../providers/lms_provider.dart';
import '../../providers/theme_provider.dart';
import '../../domain/models/lms_material.dart';
import '../../domain/models/user.dart';
import '../../app/theme.dart';

class LmsScreen extends StatefulWidget {
  const LmsScreen({super.key});

  @override
  State<LmsScreen> createState() => _LmsScreenState();
}

class _LmsScreenState extends State<LmsScreen> {
  int _selectedLevel = 1;
  int _selectedSemester = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<ModuleProvider>().loadModules(user.id);
        if (user.role == UserRole.staff) {
          setState(() {
            _selectedLevel = 1;
            _selectedSemester = 1;
          });
        }
      }
    });
  }

  void _showAddContentDialog(BuildContext context, String moduleId) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedType = 'pdf';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add LMS Material'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  items: const [
                    DropdownMenuItem(value: 'pdf', child: Text('PDF Document')),
                    DropdownMenuItem(value: 'assignment', child: Text('Assignment')),
                  ],
                  onChanged: (val) => setDialogState(() => selectedType = val!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final material = LmsMaterial(
                  id: 'mat-${DateTime.now().millisecondsSinceEpoch}',
                  moduleId: moduleId,
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  fileUrl: 'mock_url_${DateTime.now().millisecondsSinceEpoch}.pdf',
                  type: selectedType,
                );
                context.read<LmsProvider>().addMaterial(material);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Material added successfully!')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMaterials(BuildContext context, String moduleId, String moduleName) {
    context.read<LmsProvider>().loadMaterialsForModule(moduleId);
    final isStaff = context.read<AuthProvider>().currentUser?.role == UserRole.staff;

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
            return Consumer<LmsProvider>(
              builder: (context, lmsProvider, child) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              moduleName, 
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isStaff)
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                              onPressed: () => _showAddContentDialog(context, moduleId),
                            ),
                        ],
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = context.watch<ModuleProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final isStaff = user?.role == UserRole.staff;

    final displayModules = isStaff 
        ? moduleProvider.getModulesByLevelAndSemester(_selectedLevel, _selectedSemester)
        : moduleProvider.enrolledModules;

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
      body: Column(
        children: [
          if (isStaff) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedLevel,
                      items: [1, 2, 3, 4].map((l) => DropdownMenuItem(value: l, child: Text('Level $l'))).toList(),
                      onChanged: (val) => setState(() => _selectedLevel = val!),
                      decoration: const InputDecoration(labelText: 'Level', contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedSemester,
                      items: [1, 2].map((s) => DropdownMenuItem(value: s, child: Text('Sem $s'))).toList(),
                      onChanged: (val) => setState(() => _selectedSemester = val!),
                      decoration: const InputDecoration(labelText: 'Semester', contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
          Expanded(
            child: moduleProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayModules.isEmpty
                    ? Center(child: Text(isStaff ? 'No modules found for this level/semester.' : 'You are not enrolled in any modules.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayModules.length,
                        itemBuilder: (context, index) {
                          final module = displayModules[index];
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
          ),
        ],
      ),
    );
  }
}
