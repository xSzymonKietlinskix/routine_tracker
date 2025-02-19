import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskBarChart extends StatelessWidget {
  final List<Map<String, int>> taskData;

  TaskBarChart({super.key, required this.taskData});

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

    // Obliczanie maxY na podstawie danych (największa wartość + 2)
    int maxTaskCount = taskData.fold<int>(0, (max, data) {
      int total = data['total'] ?? 0;
      return total > max ? total : max;
    });

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDarkTheme
                ? const Color.fromARGB(211, 33, 33, 34)
                : Color.fromARGB(255, 247, 243, 248),
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
                    barsSpace: 2,
                    barRods: [
                      BarChartRodData(
                        toY: taskData[index]['total']!.toDouble(),
                        color: Colors.purple.shade200,
                        width: 13,
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
                        width: 13,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40, // Zwiększenie przestrzeni na osi Y
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.bold, // Pogrubienie czcionki
                              color: textColor,
                            ),
                          ),
                        );
                      },
                      interval: 1, // Ustawienie odstępu na osi Y co 1
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
                            style: TextStyle(
                              fontSize: 8,
                              // fontWeight:
                              //     FontWeight.bold, // Pogrubienie czcionki
                              color: textColor,
                            ),
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
                  drawVerticalLine: true,
                  drawHorizontalLine: false,
                  // getDrawingHorizontalLine: (value) {
                  //   return FlLine(
                  //     color: Colors.purple.shade100,
                  //     strokeWidth: 1,
                  //   );
                  // },
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
                maxY: (maxTaskCount + 1)
                    .toDouble(), // Dynamiczne dopasowanie maxY
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
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold, // Pogrubienie czcionki w legendzie
            color: textColor,
          ),
        ),
      ],
    );
  }
}
