// =============================================================================
// presentation/widgets/academic_performance_widget.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme.dart';

class AcademicPerformanceWidget extends StatelessWidget {
  const AcademicPerformanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. GPA Trend Graph
        const Text(
          'GPA Trend',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 1: return const Text('S1', style: TextStyle(fontSize: 10));
                        case 2: return const Text('S2', style: TextStyle(fontSize: 10));
                        case 3: return const Text('S3', style: TextStyle(fontSize: 10));
                        default: return const Text('');
                      }
                    },
                    reservedSize: 22,
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0.5,
              maxX: 3.5,
              minY: 0,
              maxY: 4.5,
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(1, 3.65), // Semester 1 GPA
                    const FlSpot(2, 3.82), // Semester 2 GPA
                    const FlSpot(3, 3.91), // Semester 3 GPA
                  ],
                  isCurved: true,
                  color: AppTheme.primary,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // 2. Results Table
        const Text(
          'Semester Wise Grades',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Subject')),
              DataColumn(label: Text('Sem')),
              DataColumn(label: Text('Grade')),
              DataColumn(label: Text('GPA')),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('Mathematics')),
                DataCell(Text('1')),
                DataCell(Text('A')),
                DataCell(Text('4.0')),
              ]),
              DataRow(cells: [
                DataCell(Text('Programming')),
                DataCell(Text('1')),
                DataCell(Text('A-')),
                DataCell(Text('3.7')),
              ]),
              DataRow(cells: [
                DataCell(Text('Software Eng')),
                DataCell(Text('2')),
                DataCell(Text('B+')),
                DataCell(Text('3.3')),
              ]),
              DataRow(cells: [
                DataCell(Text('DB Systems')),
                DataCell(Text('2')),
                DataCell(Text('A')),
                DataCell(Text('4.0')),
              ]),
              DataRow(cells: [
                DataCell(Text('Networks')),
                DataCell(Text('3')),
                DataCell(Text('A')),
                DataCell(Text('4.0')),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
