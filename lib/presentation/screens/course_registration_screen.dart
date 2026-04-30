// =============================================================================
// presentation/screens/course_registration_screen.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/module_provider.dart';
import '../../app/theme.dart';

class CourseRegistrationScreen extends StatefulWidget {
  const CourseRegistrationScreen({super.key});

  @override
  State<CourseRegistrationScreen> createState() => _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> {
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

  @override
  Widget build(BuildContext context) {
    final moduleProvider = context.watch<ModuleProvider>();
    final user = context.read<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Registration'),
      ),
      body: moduleProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : moduleProvider.allModules.isEmpty
              ? const Center(child: Text('No modules available for registration.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: moduleProvider.allModules.length,
                  itemBuilder: (context, index) {
                    final module = moduleProvider.allModules[index];
                    final isEnrolled = moduleProvider.isEnrolled(module.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${module.code} - ${module.name}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Credits: ${module.credits} • Lvl: ${module.level} • Sem: ${module.semester}',
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isEnrolled ? Colors.red.shade100 : AppTheme.primary,
                                foregroundColor: isEnrolled ? Colors.red : Colors.white,
                              ),
                              onPressed: () {
                                if (user != null) {
                                  if (isEnrolled) {
                                    moduleProvider.drop(user.id, module.id);
                                  } else {
                                    moduleProvider.enroll(user.id, module.id);
                                  }
                                }
                              },
                              child: Text(isEnrolled ? 'Drop' : 'Enroll'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
