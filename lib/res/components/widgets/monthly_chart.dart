import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyChart extends StatelessWidget {
  MonthlyChart({super.key});

  final List<String> months = [
    "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov",
    "Dec", "Jan", "Feb", "Mar"
  ];

  final List<double> audValues = [
    900, 600, 350, 200, 150, 300, 500, 1200, 3300, 2100, 3100, 5200
  ];

  final List<double> orderValues = [
    8, 5, 4, 3, 2, 6, 10, 12, 20, 15, 30, 50
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)
        ],
      ),
      child: Stack(
        children: [
          /// ------------------- BAR CHART (AUD) -------------------
          BarChart(
            BarChartData(
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),

              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1000,
                    reservedSize: 40,
                    getTitlesWidget: (v, meta) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (i, meta) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        months[i.toInt()],
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ),
                topTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),

              barGroups: List.generate(months.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: audValues[i],
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.blueAccent,
                    ),
                  ],
                );
              }),
            ),
          ),

          /// ------------------- LINE CHART (Orders) -------------------
          Positioned.fill(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(
                  leftTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      reservedSize: 35,
                      getTitlesWidget: (v, meta) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      orderValues.length,
                          (i) =>
                          FlSpot(i.toDouble(), orderValues[i].toDouble()),
                    ),
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.orange,
                    dotData: FlDotData(show: true),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
