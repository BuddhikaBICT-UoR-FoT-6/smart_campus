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
    final textColor = isDark ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. GPA Trend Graph (Bar Chart)
        const Text(
          'GPA Progress',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 4.0,
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      String label = '';
                      switch (value.toInt()) {
                        case 0: label = 'L1 S1'; break;
                        case 1: label = 'L1 S2'; break;
                        case 2: label = 'L2 S1'; break;
                        case 3: label = 'L2 S2'; break;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          label,
                          style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.6)),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                _buildBarGroup(0, 3.85, isDark), // L1 S1
                _buildBarGroup(1, 3.70, isDark), // L1 S2
                _buildBarGroup(2, 3.92, isDark), // L2 S1
                _buildBarGroup(3, 3.40, isDark, isPlaceholder: true), // L2 S2 (Future)
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
              DataColumn(label: Text('Level')),
              DataColumn(label: Text('Sem')),
              DataColumn(label: Text('Grade')),
              DataColumn(label: Text('GPA')),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('Mathematics')),
                DataCell(Text('1')),
                DataCell(Text('1')),
                DataCell(Text('A')),
                DataCell(Text('4.0')),
              ]),
              DataRow(cells: [
                DataCell(Text('Programming')),
                DataCell(Text('1')),
                DataCell(Text('1')),
                DataCell(Text('A-')),
                DataCell(Text('3.7')),
              ]),
              DataRow(cells: [
                DataCell(Text('Software Eng')),
                DataCell(Text('1')),
                DataCell(Text('2')),
                DataCell(Text('B+')),
                DataCell(Text('3.3')),
              ]),
              DataRow(cells: [
                DataCell(Text('DB Systems')),
                DataCell(Text('1')),
                DataCell(Text('2')),
                DataCell(Text('A')),
                DataCell(Text('4.0')),
              ]),
              DataRow(cells: [
                DataCell(Text('Networks')),
                DataCell(Text('2')),
                DataCell(Text('1')),
                DataCell(Text('A')),
                DataCell(Text('4.0')),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, bool isDark, {bool isPlaceholder = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isPlaceholder 
            ? Colors.grey.withValues(alpha: 0.3) 
            : AppTheme.primary,
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 4.0,
            color: isDark ? Colors.white10 : Colors.grey.shade100,
          ),
        ),
      ],
    );
  }
}
