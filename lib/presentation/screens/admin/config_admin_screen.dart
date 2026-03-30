import 'package:flutter/material.dart';

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
          _buildHeader('Student Controls'),
          SwitchListTile(
            title: const Text('Allow New Registrations'),
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
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuration saved successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Configuration'),
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
