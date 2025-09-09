import 'package:flutter/material.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/theme/responsive_text_styles.dart';
import 'package:your_finance_flutter/widgets/trend_chart_widget.dart';

class OverviewTrendChart extends StatelessWidget {
  const OverviewTrendChart({
    required this.data,
    required this.title,
    required this.subtitle,
    super.key,
    this.color = const Color(0xFF007AFF),
  });
  final List<double> data;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(context.responsiveSpacing12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: context.responsiveBodyMedium.copyWith(
                    color: context.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.trending_up_outlined,
                  size: 16,
                  color: color,
                ),
              ],
            ),
            SizedBox(height: context.responsiveSpacing4),
            Text(
              subtitle,
              style: context.responsiveBodyMedium.copyWith(
                color: context.secondaryText,
              ),
            ),
            SizedBox(height: context.responsiveSpacing8),
            TrendChartWidget(
              data: data,
              lineColor: color,
              fillColor: color,
              height: 80,
              showDots: true,
              showGrid: true,
            ),
          ],
        ),
      );
}
