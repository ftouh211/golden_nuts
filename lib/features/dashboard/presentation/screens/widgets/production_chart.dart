import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';

class ProductionChart extends StatelessWidget {
  final List<double> productionData;
  final List<String> days;

  const ProductionChart({
    super.key,
    required this.productionData,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد أعلى قيمة للإنتاج تلقائيًا
    final maxProduction = productionData.isEmpty
        ? 0.0
        : productionData.reduce((a, b) => a > b ? a : b);

    final chartMaxY = maxProduction <= 0
        ? 10.0
        : ((maxProduction / 10).ceil() * 10).toDouble() + 25;

    return Container(
      height: 230,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
      decoration: BoxDecoration(
        color: ColorManager.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorManager.border),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: chartMaxY,
          minX: 0,
          maxX: 6,
          clipData: const FlClipData.all(),

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: chartMaxY / 5,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: ColorManager.divider, strokeWidth: 1),
          ),

          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: chartMaxY / 5,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: ColorManager.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= days.length) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[index],
                      style: const TextStyle(
                        color: ColorManager.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                productionData.length,
                (index) => FlSpot(index.toDouble(), productionData[index]),
              ),

              isCurved: true,
              curveSmoothness: 0.25,
              color: ColorManager.primary,
              barWidth: 3,
              isStrokeCapRound: true,

              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: ColorManager.gold,
                    strokeWidth: 2,
                    strokeColor: ColorManager.surface,
                  );
                },
              ),

              belowBarData: BarAreaData(
                show: true,
                color: ColorManager.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
