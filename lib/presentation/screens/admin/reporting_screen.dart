import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../providers/reporting_provider.dart';
import '../../../domain/models/user.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({super.key});

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportingProvider>().loadReportData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Analytics & Reports'),
        actions: [
          IconButton(
            onPressed: () => provider.loadReportData(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('User Role Distribution'),
                  const SizedBox(height: 16),
                  _buildUserRoleChart(provider.userRoleDistribution),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Event Participation (Total Registered)'),
                  const SizedBox(height: 16),
                  _buildParticipationChart(provider.eventRegistrationDistribution),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Academic Performance Overview'),
                  const SizedBox(height: 16),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Total Students: 8\nAverage GPA: 3.42\nPassing Rate: 98%',
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
    );
  }

  Widget _buildUserRoleChart(Map<UserRole, int> distribution) {
    if (distribution.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('No user data')));
    
    final colors = {
      UserRole.student: Colors.blue,
      UserRole.staff: Colors.orange,
      UserRole.superadmin: Colors.red,
    };

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: distribution.entries.map((e) {
            return PieChartSectionData(
              value: e.value.toDouble(),
              title: '${e.key.name.toUpperCase()}\n${e.value}',
              color: colors[e.key] ?? Colors.grey,
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildParticipationChart(Map<String, int> distribution) {
    if (distribution.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('No event data')));

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (distribution.values.isEmpty ? 10 : distribution.values.reduce((a, b) => a > b ? a : b).toDouble() + 2),
          barGroups: distribution.entries.toList().asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value.toDouble(),
                  color: Colors.teal,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= distribution.length) return const SizedBox();
                  final label = distribution.keys.elementAt(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      label.length > 8 ? '${label.substring(0, 5)}...' : label,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
