import 'package:ahec_task_manager/view_models/controller/dashboard_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MonthlyChart extends StatelessWidget {
  const MonthlyChart({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Obx(() {
      // ✅ Get data from controller
      final monthNames = controller.monthNames;
      final audAmounts = controller.audAmounts;
      final orderCounts = controller.orderCounts;

      // ✅ Show loading if no data
      if (monthNames.isEmpty || audAmounts.isEmpty || orderCounts.isEmpty) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // ✅ Calculate max values for proper scaling
      final maxOrders = orderCounts.reduce((a, b) => a > b ? a : b).toDouble();
      final maxAud = audAmounts.reduce((a, b) => a > b ? a : b);

      // ✅ Round up max values for cleaner axis
      final maxOrdersRounded = ((maxOrders / 10).ceil() * 10).toDouble();
      final maxAudRounded = ((maxAud / 1000).ceil() * 1000).toDouble();

      // ✅ Colorful bar colors (cycling pattern)
      final List<Color> barColors = [
        Colors.blue,
        Colors.purple,
        Colors.pink,
        Colors.orange,
        Colors.cyan,
        Colors.red,
        Colors.yellow,
        Colors.green,
        Colors.teal,
        Colors.indigo,
        Colors.lime,
        Colors.deepOrange,
      ];

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Title
            Text(
              "Monthly AUD and total number of orders, ${controller.currentYear}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // ✅ Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.grey, "Total Orders"),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.blue, "Total AUD"),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ Chart - Scrollable for many months
            SizedBox(
              height: 280,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: monthNames.length * 35.0, // 35px per month
                  child: Stack(
                    children: [
                      // ✅ Bar Chart (Orders)
                      BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxOrdersRounded,
                          minY: 0,
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade300,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            // Left axis - AUD
                            leftTitles: AxisTitles(
                              axisNameWidget: const Padding(
                                padding: EdgeInsets.only(bottom: 6),
                                child: Text(
                                  "Total AUD",
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ),
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45,
                                getTitlesWidget: (value, meta) {
                                  // Show only every 1000 or so
                                  if (value % 1000 == 0) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 8, color: Colors.black54),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),

                            // Bottom axis - Months
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index < 0 || index >= monthNames.length) {
                                    return const SizedBox.shrink();
                                  }
                                  // Show month name (abbreviated)
                                  String monthName = monthNames[index];
                                  String abbr = monthName.substring(0, 3);

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      abbr,
                                      style: const TextStyle(fontSize: 8),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Right axis - Orders
                            rightTitles: AxisTitles(
                              axisNameWidget: const Padding(
                                padding: EdgeInsets.only(bottom: 6),
                                child: Text(
                                  "Total Orders",
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ),
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 35,
                                getTitlesWidget: (value, meta) {
                                  // Show every 20 orders
                                  if (value % 20 == 0) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 8, color: Colors.black54),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),

                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          barGroups: List.generate(orderCounts.length, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: orderCounts[i].toDouble(),
                                  width: 10,
                                  borderRadius: BorderRadius.circular(2),
                                  color: barColors[i % barColors.length],
                                ),
                              ],
                            );
                          }),
                        ),
                      ),

                      // ✅ Line Chart (AUD) - Overlayed
                      Positioned.fill(
                        child: LineChart(
                          LineChartData(
                            maxY: maxAudRounded,
                            minY: 0,
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  audAmounts.length,
                                      (i) => FlSpot(i.toDouble(), audAmounts[i]),
                                ),
                                isCurved: true,
                                curveSmoothness: 0.3,
                                barWidth: 2.5,
                                color: Colors.blue,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 3,
                                      color: Colors.blue,
                                      strokeWidth: 1.5,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ✅ Legend item widget
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}