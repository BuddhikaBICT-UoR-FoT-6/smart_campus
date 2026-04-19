import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/medical_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/user_management_provider.dart';
import '../../../providers/event_provider.dart';
import '../../../app/routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<UserManagementProvider>().loadUsers();
        context.read<EventProvider>().loadEvents(user.id);
        context.read<MedicalProvider>().loadAllSubmissions(); // Optional, but good for sync
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institutional Administration'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
              );
            },
          ),
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null && mounted) {
            final userMgmt = context.read<UserManagementProvider>();
            final eventProv = context.read<EventProvider>();
            final medicalProv = context.read<MedicalProvider>();
            
            await userMgmt.loadUsers();
            await eventProv.loadEvents(user.id);
            await medicalProv.loadAllSubmissions();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(user?.name ?? 'Admin'),
              const SizedBox(height: 24),
              _buildStatsOverview(context),
              const SizedBox(height: 24),
              const Text(
                'Management Modules',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildAdminMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.admin_panel_settings, size: 35, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $name',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Superadmin Level Access',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context) {
    final medicals = context.watch<MedicalProvider>().submissions;
    final pendingMedicals = medicals.where((m) => m.status == 'pending').length;
    
    final userCount = context.watch<UserManagementProvider>().users.length;
    final eventCount = context.watch<EventProvider>().events.length;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/admin/users'),
            child: _buildStatCard('Users', userCount.toString(), Icons.people, Colors.blue),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/admin/events'),
            child: _buildStatCard('Events', eventCount.toString(), Icons.event, Colors.orange),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminMedicalReview),
            child: _buildStatCard(
              'Medicals',
              pendingMedicals.toString(),
              Icons.medical_services_rounded,
              pendingMedicals > 0 ? Colors.red : Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildAdminMenu(BuildContext context) {
    final modules = [
      {'title': 'User Management', 'icon': Icons.person_add, 'color': Colors.indigo, 'route': '/admin/users'},
      {'title': 'Academic Calendar', 'icon': Icons.calendar_today, 'color': Colors.teal, 'route': '/admin/calendar'},
      {'title': 'Timetable Admin', 'icon': Icons.schedule, 'color': Colors.purple, 'route': '/admin/timetable'},
      {'title': 'Event Admin', 'icon': Icons.campaign, 'color': Colors.orange, 'route': '/admin/events'},
      {'title': 'Results Management', 'icon': Icons.grade, 'color': Colors.green, 'route': '/admin/results'},
      {'title': 'Announcements', 'icon': Icons.notification_important, 'color': Colors.red, 'route': '/admin/announcements'},
      {'title': 'System Config', 'icon': Icons.settings, 'color': Colors.grey, 'route': '/admin/config'},
      {'title': 'Reporting', 'icon': Icons.bar_chart, 'color': Colors.blueGrey, 'route': '/admin/reporting'},
      {'title': 'Subject Management', 'icon': Icons.menu_book_rounded, 'color': Colors.indigoAccent, 'route': AppRoutes.adminModules},
      {'title': 'Medical Approvals', 'icon': Icons.medical_services_outlined, 'color': Colors.pink, 'route': '/admin/medical-review'},
      {'title': 'Campus Map', 'icon': Icons.map, 'color': Colors.amber, 'route': '/campus-map'},
      {'title': 'QR Scanner', 'icon': Icons.qr_code_scanner, 'color': Colors.cyan, 'route': '/qr-scanner'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final m = modules[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return InkWell(
          onTap: () => Navigator.pushNamed(context, m['route'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(m['icon'] as IconData, color: m['color'] as Color, size: 30),
                const SizedBox(height: 8),
                Text(
                  m['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
