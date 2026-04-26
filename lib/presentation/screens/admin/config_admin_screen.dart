import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus/providers/system_config_provider.dart';

class ConfigAdminScreen extends StatefulWidget {
  const ConfigAdminScreen({super.key});

  @override
  State<ConfigAdminScreen> createState() => _ConfigAdminScreenState();
}

class _ConfigAdminScreenState extends State<ConfigAdminScreen> {
  bool _maintenanceMode = false;
  bool _globalNotifications = true;
  bool _allowStudentRegistration = true;
  final String _appVersion = '1.0.0+5';

  @override
  Widget build(BuildContext context) {
    final configProvider = context.watch<SystemConfigProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Configuration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader('General Settings'),
          SwitchListTile(
            title: const Text('Maintenance Mode'),
            subtitle: const Text('Disables all non-admin access to the app.'),
            value: _maintenanceMode,
            onChanged: (val) => setState(() => _maintenanceMode = val),
          ),
          SwitchListTile(
            title: const Text('Global Notifications'),
            subtitle: const Text('Allow system-wide push notifications.'),
            value: _globalNotifications,
            onChanged: (val) => setState(() => _globalNotifications = val),
          ),
          const Divider(),
          _buildHeader('Student & Academic Controls'),
          ListTile(
            title: const Text('Course Registration Deadline'),
            subtitle: Text('Deadline: ${configProvider.registrationDeadline}'),
            trailing: const Icon(Icons.calendar_today, color: Colors.blue),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(configProvider.registrationDeadline) ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                final dateStr = picked.toIso8601String().split('T').first;
                configProvider.updateDeadline(dateStr);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deadline updated to $dateStr')),
                  );
                }
              }
            },
          ),
          SwitchListTile(
            title: const Text('Allow New Event Registrations'),
            subtitle: const Text('Allow students to register for events.'),
            value: _allowStudentRegistration,
            onChanged: (val) => setState(() => _allowStudentRegistration = val),
          ),
          const Divider(),
          _buildHeader('System Info'),
          ListTile(
            title: const Text('App Version'),
            subtitle: Text(_appVersion),
            trailing: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
