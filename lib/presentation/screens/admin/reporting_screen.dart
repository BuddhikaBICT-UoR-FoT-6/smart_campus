import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportingScreen extends StatelessWidget {
  const ReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Analytics & Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Overall Attendance Rate'),
            const SizedBox(height: 16),
            _buildAttendanceChart(),
            const SizedBox(height: 32),
            _buildSectionTitle('GPA Distribution (Semester 1)'),
            const SizedBox(height: 16),
            _buildGPADistributionChart(),
            const SizedBox(height: 32),
            _buildSectionTitle('Event Participation (Monthly)'),
            const SizedBox(height: 16),
            _buildParticipationChart(),
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

  Widget _buildAttendanceChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 85, title: '85%', color: Colors.green, radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            PieChartSectionData(value: 15, title: '15%', color: Colors.red.withOpacity(0.7), radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildGPADistributionChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 4.0,
          barGroups: [
            _makeGroupData(0, 3.8, Colors.blue),
            _makeGroupData(1, 3.2, Colors.blue),
            _makeGroupData(2, 4.0, Colors.blue),
            _makeGroupData(3, 2.5, Colors.blue),
            _makeGroupData(4, 3.5, Colors.blue),
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const labels = ['S1', 'S2', 'S3', 'S4', 'S5'];
                  return Text(labels[value.toInt()], style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y, color: color, width: 16, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }

  Widget _buildParticipationChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.2))),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 10),
                FlSpot(1, 25),
                FlSpot(2, 18),
                FlSpot(3, 45),
                FlSpot(4, 30),
              ],
              isCurved: true,
              color: Colors.orange,
              barWidth: 4,
              belowBarData: BarAreaData(show: true, color: Colors.orange.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }
}
