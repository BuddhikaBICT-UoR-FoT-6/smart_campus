import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/module_provider.dart';
import '../../../domain/models/module.dart';
import '../../../app/theme.dart';

class ModuleManagementScreen extends StatefulWidget {
  const ModuleManagementScreen({super.key});

  @override
  State<ModuleManagementScreen> createState() => _ModuleManagementScreenState();
}

class _ModuleManagementScreenState extends State<ModuleManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModuleProvider>().loadAllModulesOnly();
    });
  }

  void _showAddModuleDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final creditsCtrl = TextEditingController(text: '3');
    int selectedLevel = 1;
    int selectedSemester = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Subject'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Module Code (e.g. ICT1101)')),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Module Name')),
                TextField(controller: creditsCtrl, decoration: const InputDecoration(labelText: 'Credits'), keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: selectedLevel,
                        items: [1, 2, 3, 4].map((l) => DropdownMenuItem(value: l, child: Text('L$l'))).toList(),
                        onChanged: (val) => setDialogState(() => selectedLevel = val!),
                        decoration: const InputDecoration(labelText: 'Level'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: selectedSemester,
                        items: [1, 2].map((s) => DropdownMenuItem(value: s, child: Text('S$s'))).toList(),
                        onChanged: (val) => setDialogState(() => selectedSemester = val!),
                        decoration: const InputDecoration(labelText: 'Semester'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (codeCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
                
                final module = Module(
                  id: codeCtrl.text.toUpperCase(),
                  code: codeCtrl.text.toUpperCase(),
                  name: nameCtrl.text,
                  credits: int.tryParse(creditsCtrl.text) ?? 3,
                  level: selectedLevel,
                  semester: selectedSemester,
                );
                context.read<ModuleProvider>().addModule(module);
                Navigator.pop(ctx);
              },
              child: const Text('Add Module'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = context.watch<ModuleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Management'),
      ),
      body: moduleProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: moduleProvider.allModules.length,
              itemBuilder: (context, index) {
                final module = moduleProvider.allModules[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      child: Text('L${module.level}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ),
                    title: Text('${module.code} - ${module.name}'),
                    subtitle: Text('Sem ${module.semester} • ${module.credits} Credits'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Module?'),
                            content: Text('Are you sure you want to delete ${module.code}? This will also remove student enrollments.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () {
                                  context.read<ModuleProvider>().deleteModule(module.id);
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddModuleDialog,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
