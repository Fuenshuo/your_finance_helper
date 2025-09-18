import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';

class TrendChartWidget extends StatelessWidget {
  const TrendChartWidget({
    required this.data,
    super.key,
    this.lineColor = const Color(0xFF007AFF),
    this.fillColor = const Color(0xFF007AFF),
    this.height = 60,
    this.showDots = false,
    this.showGrid = false,
  });
  final List<double> data;
  final Color lineColor;
  final Color fillColor;
  final double height;
  final bool showDots;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            '暂无数据',
            style: TextStyle(
              color: context.secondaryText,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: showGrid,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.dividerColor.withOpacity(0.3),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(
            show: false,
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: _getMinValue(),
          maxY: _getMaxValue(),
          lineBarsData: [
            LineChartBarData(
              spots: _generateSpots(),
              isCurved: true,
              color: lineColor,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: showDots,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: lineColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: fillColor.withOpacity(0.1),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    fillColor.withOpacity(0.3),
                    fillColor.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(
            enabled: false,
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots() => data
      .asMap()
      .entries
      .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
      .toList();

  double _getMinValue() {
    final min = data.reduce((a, b) => a < b ? a : b);
    return min * 0.95; // 留5%的边距
  }

  double _getMaxValue() {
    final max = data.reduce((a, b) => a > b ? a : b);
    return max * 1.05; // 留5%的边距
  }
}

// 简化的趋势图组件（用于列表项）- 使用自定义绘制提升性能
class SimpleTrendChart extends StatelessWidget {
  const SimpleTrendChart({
    required this.data,
    super.key,
    this.color = const Color(0xFF007AFF),
    this.height = 24,
    this.width = 60,
  });
  final List<double> data;
  final Color color;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) =>
      PerformanceMonitor.monitorBuild('SimpleTrendChart', () {
        if (data.isEmpty) {
          return SizedBox(
            height: height,
            width: width,
            child: Container(
              decoration: BoxDecoration(
                color: context.dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }

        return SizedBox(
          height: height,
          width: width,
          child: CustomPaint(
            painter: _TrendLinePainter(
              data: data,
              color: color,
            ),
          ),
        );
      });
}

// 自定义绘制器 - 比 fl_chart 更轻量级
class _TrendLinePainter extends CustomPainter {
  _TrendLinePainter({
    required this.data,
    required this.color,
  });

  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    PerformanceMonitor.monitorPaint(
      '_TrendLinePainter',
      () => _paintChart(canvas, size),
    );
  }

  void _paintChart(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0 // 减少线条宽度
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) return;

    // 简化绘制，直接绘制线段而不是路径
    for (var i = 0; i < data.length - 1; i++) {
      final x1 = (i / (data.length - 1)) * size.width;
      final y1 = size.height - ((data[i] - minValue) / range) * size.height;
      final x2 = ((i + 1) / (data.length - 1)) * size.width;
      final y2 = size.height - ((data[i + 1] - minValue) / range) * size.height;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _TrendLinePainter) {
      return oldDelegate.data != data || oldDelegate.color != color;
    }
    return true;
  }
}
