// =============================================================================
// presentation/screens/course_registration_screen.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_campus/providers/auth_provider.dart';
import 'package:smart_campus/providers/module_provider.dart';
import 'package:smart_campus/domain/models/module.dart';
import 'package:smart_campus/providers/system_config_provider.dart';
import 'package:smart_campus/providers/theme_provider.dart';
import 'package:smart_campus/app/theme.dart';

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
        context.read<SystemConfigProvider>().loadConfig();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = context.watch<ModuleProvider>();
    final configProvider = context.watch<SystemConfigProvider>();
    final user = context.read<AuthProvider>().currentUser;

    if (user == null) return const Scaffold(body: Center(child: Text('Please login first')));

    final isDeadlinePassed = configProvider.isRegistrationClosed;

    // Filtering logic
    final availableModules = moduleProvider.allModules.where((m) {
      final isEnrolled = moduleProvider.isEnrolled(m.id);
      final isCorrectLevel = m.level == user.level;
      final isCorrectSemester = m.semester == user.semester;
      return !isEnrolled && isCorrectLevel && isCorrectSemester;
    }).toList();

    final registeredModules = moduleProvider.enrolledModules;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Course Registration'),
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
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Available'),
              Tab(text: 'Registered'),
            ],
            indicatorColor: Theme.of(context).brightness == Brightness.light ? Colors.black : AppTheme.primary,
            labelColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
            unselectedLabelColor: Theme.of(context).brightness == Brightness.light ? Colors.black54 : Colors.grey,
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: isDeadlinePassed ? Colors.red.shade100 : Colors.blue.shade100,
              child: Row(
                children: [
                  Icon(
                    isDeadlinePassed ? Icons.lock_clock : Icons.info_outline,
                    color: isDeadlinePassed ? Colors.red : Colors.blue.shade800,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isDeadlinePassed 
                        ? 'Registration Closed (Deadline: ${configProvider.registrationDeadline})'
                        : 'Registration Deadline: ${configProvider.registrationDeadline}',
                      style: TextStyle(
                        color: isDeadlinePassed ? Colors.red.shade900 : Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildModuleList(context, availableModules, isAvailable: true, isLocked: isDeadlinePassed),
                  _buildModuleList(context, registeredModules, isAvailable: false, isLocked: isDeadlinePassed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleList(BuildContext context, List<Module> modules, {required bool isAvailable, bool isLocked = false}) {
    final moduleProvider = context.read<ModuleProvider>();
    final user = context.read<AuthProvider>().currentUser;

    if (moduleProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (modules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isAvailable ? Icons.auto_stories_outlined : Icons.app_registration,
                size: 64,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                isAvailable
                    ? 'No new modules available for your level/semester.'
                    : 'You have not registered for any modules yet.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];

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
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLocked 
                        ? Colors.grey 
                        : (isAvailable ? AppTheme.primary : Theme.of(context).colorScheme.errorContainer),
                    foregroundColor: isLocked 
                        ? Colors.white70 
                        : (isAvailable ? Colors.white : Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  onPressed: isLocked ? null : () {
                    if (user != null) {
                      if (isAvailable) {
                        moduleProvider.enroll(user.id, module.id, isLocked);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Enrolled in ${module.code}')),
                        );
                      } else {
                        moduleProvider.drop(user.id, module.id, isLocked);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Dropped ${module.code}')),
                        );
                      }
                    }
                  },
                  child: Text(isAvailable ? 'Enroll' : 'Drop'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
