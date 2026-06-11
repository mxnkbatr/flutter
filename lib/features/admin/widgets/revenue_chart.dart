import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/formatters.dart';
import 'package:sacred_app/features/admin/models/admin_dashboard_data.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key, required this.monthlyData});

  final List<MonthlyRevenue> monthlyData;

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return const Center(
        child: Text('Өгөгдөл байхгүй', style: AppText.bodySmall),
      );
    }

    final peak = monthlyData
        .map((e) => e.amount.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final maxY = peak > 0 ? peak : 1.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barGroups: monthlyData.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.amount.toDouble(),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.goldMuted, AppColors.goldPrime],
                ),
                width: 22,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        backgroundColor: AppColors.transparent,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.inkLight,
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= monthlyData.length) {
                  return const SizedBox.shrink();
                }
                return Text(monthlyData[i].label, style: AppText.caption);
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.goldLight,
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              Formatters.currency(rod.toY.toInt()),
              AppText.bodySmall.copyWith(
                color: AppColors.inkDeep,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
