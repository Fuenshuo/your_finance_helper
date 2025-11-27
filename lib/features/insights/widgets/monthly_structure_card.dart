import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';

/// Monthly structure card showing survival vs lifestyle spending breakdown
/// in a Bento grid layout as designed for the CFO monthly report
class MonthlyStructureCard extends StatelessWidget {
  const MonthlyStructureCard({
    super.key,
    required this.monthlyHealth,
    this.onCardTap,
  });

  final MonthlyHealthScore monthlyHealth;
  final VoidCallback? onCardTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        padding: const EdgeInsets.all(AppDesignTokens.spacing16),
        decoration: BoxDecoration(
          color: AppDesignTokens.surface(context),
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '月度结构分析',
                  style: AppDesignTokens.headline(context),
                ),
                _buildGradeBadge(context),
              ],
            ),
            const SizedBox(height: AppDesignTokens.spacing16),

            // Bento Grid Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 400;
                return isWide ? _buildWideLayout(context) : _buildNarrowLayout(context);
              },
            ),

            // CFO Report Section
            const SizedBox(height: AppDesignTokens.spacing24),
            _buildCFOReport(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeBadge(BuildContext context) {
    final gradeColor = _getGradeColor(context);
    final gradeText = _getGradeText();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing12,
        vertical: AppDesignTokens.spacing4,
      ),
      decoration: BoxDecoration(
        color: gradeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius8),
        border: Border.all(
          color: gradeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        gradeText,
        style: AppDesignTokens.body(context).copyWith(
          color: gradeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Survival vs Lifestyle donut chart
        Expanded(
          flex: 2,
          child: _buildDonutChart(context),
        ),
        const SizedBox(width: AppDesignTokens.spacing16),
        // Right side: Top spending categories
        Expanded(
          flex: 3,
          child: _buildTopCategories(context),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      children: [
        _buildDonutChart(context),
        const SizedBox(height: AppDesignTokens.spacing16),
        _buildTopCategories(context),
      ],
    );
  }

  Widget _buildDonutChart(BuildContext context) {
    final survivalPercent = monthlyHealth.metrics['survivalPercentage'] as double? ?? 0.0;
    final lifestylePercent = monthlyHealth.metrics['lifestylePercentage'] as double? ?? 0.0;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppDesignTokens.spacing16),
      decoration: BoxDecoration(
        color: AppDesignTokens.surface(context),
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
      ),
      child: Column(
        children: [
          Text(
            '生存 vs 生活',
            style: AppDesignTokens.body(context),
          ),
          const SizedBox(height: AppDesignTokens.spacing12),
          Expanded(
            child: CustomPaint(
              painter: _DonutChartPainter(
                survivalPercent: survivalPercent,
                lifestylePercent: lifestylePercent,
                survivalColor: AppDesignTokens.amountPositiveColor(context),
                lifestyleColor: AppDesignTokens.amountNegativeColor(context),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(survivalPercent * 100).round()}%',
                      style: AppDesignTokens.largeTitle(context).copyWith(
                        color: AppDesignTokens.primaryAction(context),
                      ),
                    ),
                    Text(
                      '生存支出',
                      style: AppDesignTokens.caption(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(context, '生存', AppDesignTokens.amountPositiveColor(context)),
              const SizedBox(width: AppDesignTokens.spacing16),
              _buildLegendItem(context, '生活', AppDesignTokens.amountNegativeColor(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategories(BuildContext context) {
    // Mock top categories - in real implementation, this would come from the health score
    final mockCategories = [
      {'category': '餐饮', 'amount': 2500.0, 'percentage': 0.25},
      {'category': '购物', 'amount': 1800.0, 'percentage': 0.18},
      {'category': '娱乐', 'amount': 1200.0, 'percentage': 0.12},
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppDesignTokens.spacing16),
      decoration: BoxDecoration(
        color: AppDesignTokens.surface(context),
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '消费Top 3',
            style: AppDesignTokens.body(context),
          ),
          const SizedBox(height: AppDesignTokens.spacing12),
          ...mockCategories.map((category) => Padding(
            padding: const EdgeInsets.only(bottom: AppDesignTokens.spacing8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category['category'] as String,
                  style: AppDesignTokens.body(context),
                ),
                Text(
                  '¥${(category['amount'] as double).toStringAsFixed(0)}',
                  style: AppDesignTokens.body(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCFOReport(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDesignTokens.spacing16),
      decoration: BoxDecoration(
        color: _getGradeColor(context).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(
                PhosphorIconsRegular.briefcase,
                size: 20,
                color: _getGradeColor(context),
              ),
              const SizedBox(width: AppDesignTokens.spacing8),
              Text(
                'CFO 月度诊断',
                style: AppDesignTokens.body(context).copyWith(
                  color: _getGradeColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignTokens.spacing12),
          Text(
            monthlyHealth.diagnosis,
            style: AppDesignTokens.body(context),
          ),
          if (monthlyHealth.recommendations.isNotEmpty) ...[
            const SizedBox(height: AppDesignTokens.spacing12),
            Text(
              '建议行动：',
              style: AppDesignTokens.body(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDesignTokens.spacing8),
            ...monthlyHealth.recommendations.take(2).map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: AppDesignTokens.spacing4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: AppDesignTokens.body(context)),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: AppDesignTokens.body(context),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
          const SizedBox(width: AppDesignTokens.spacing4),
        Text(
          label,
          style: AppDesignTokens.caption(context),
        ),
      ],
    );
  }

  Color _getGradeColor(BuildContext context) {
    switch (monthlyHealth.grade) {
      case LetterGrade.A:
        return AppDesignTokens.successColor(context);
      case LetterGrade.B:
        return AppDesignTokens.primaryAction(context);
      case LetterGrade.C:
        return AppDesignTokens.accentColor;
      case LetterGrade.D:
        return AppDesignTokens.warningColor;
      case LetterGrade.F:
        return AppDesignTokens.amountNegativeColor(context);
    }
  }

  String _getGradeText() {
    switch (monthlyHealth.grade) {
      case LetterGrade.A:
        return 'A';
      case LetterGrade.B:
        return 'B';
      case LetterGrade.C:
        return 'C';
      case LetterGrade.D:
        return 'D';
      case LetterGrade.F:
        return 'F';
    }
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.survivalPercent,
    required this.lifestylePercent,
    required this.survivalColor,
    required this.lifestyleColor,
  });

  final double survivalPercent;
  final double lifestylePercent;
  final Color survivalColor;
  final Color lifestyleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.7;
    final strokeWidth = 20.0;

    final survivalSweep = survivalPercent * 2 * 3.14159;
    final lifestyleSweep = lifestylePercent * 2 * 3.14159;

    // Draw survival arc (FluxBlue - Apple Health positive color)
    final survivalPaint = Paint()
      ..color = survivalColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      survivalSweep,
      false,
      survivalPaint,
    );

    // Draw lifestyle arc (Neon Red - Apple Health negative color)
    final lifestylePaint = Paint()
      ..color = lifestyleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2 + survivalSweep, // Start after survival arc
      lifestyleSweep,
      false,
      lifestylePaint,
    );
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) {
    return oldDelegate.survivalPercent != survivalPercent ||
           oldDelegate.lifestylePercent != lifestylePercent ||
           oldDelegate.survivalColor != survivalColor ||
           oldDelegate.lifestyleColor != lifestyleColor;
  }
}
