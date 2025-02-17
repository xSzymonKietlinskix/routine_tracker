import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskBarChart extends StatelessWidget {

   final List<Task> tasks;

  TaskBarChart({super.key, required this.tasks});

  final List<Map<String, int>> taskData = [
    {'total': 10, 'done': 7},
    {'total': 8, 'done': 6},
    {'total': 12, 'done': 9},
    {'total': 9, 'done': 5},
    {'total': 11, 'done': 8},
    {'total': 7, 'done': 3},
    {'total': 15, 'done': 12},
  ];

  List<String> getWeekDays() {
    return List.generate(7, (index) {
      DateTime date = DateTime.now().subtract(Duration(days: 6 - index));
      return DateFormat('dd.MM E', 'en_US').format(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> labels = getWeekDays();
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkTheme ? Colors.white70 : Colors.purple.shade900;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDarkTheme ? Colors.black54 : Colors.white10,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(16),
          child: AspectRatio(
            aspectRatio: 2.5,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(taskData.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 6,
                    barRods: [
                      BarChartRodData(
                        toY: taskData[index]['total']!.toDouble(),
                        color: Colors.purple.shade200,
                        width: 25,
                        borderRadius: BorderRadius.circular(7),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: taskData[index]['total']!.toDouble(),
                          color: Colors.purple.shade100,
                        ),
                      ),
                      BarChartRodData(
                        toY: taskData[index]['done']!.toDouble(),
                        color: Colors.purple.shade700,
                        width: 25,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 12, color: textColor),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            labels[value.toInt()],
                            style: TextStyle(fontSize: 12, color: textColor),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.purple.shade100,
                      strokeWidth: 1,
                    );
                  },
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} tasks',
                        TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
              ),
              duration: Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.purple.shade700, 'Completed', textColor),
            SizedBox(width: 10),
            _buildLegendItem(Colors.purple.shade200, 'Total', textColor),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text, Color textColor) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: color),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: textColor)),
      ],
    );
  }
}
