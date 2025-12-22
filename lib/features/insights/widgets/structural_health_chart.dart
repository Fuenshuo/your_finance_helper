import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/features/insights/models/allocation_data.dart';
import 'package:your_finance_flutter/features/insights/models/health_score.dart';
import 'package:your_finance_flutter/features/insights/services/financial_calculation_service.dart';

/// Structural Health Chart Widget
///
/// Displays financial allocation with score-centric donut chart:
/// - Thin 15px ring donut chart
/// - Centered score display
/// - Color-coded breakdown (fixed=red, flexible=blue)
/// - Formatted monetary values
/// - Zero allocation empty state
///
/// Usage:
/// ```dart
/// StructuralHealthChart(
///   allocationData: AllocationData(
///     fixedAmount: 750.0,
///     flexibleAmount: 250.0,
///     period: DateTime.now(),
///   ),
/// )
/// ```
class StructuralHealthChart extends StatefulWidget {
  const StructuralHealthChart({
    super.key,
    this.allocationData,
  });
  final AllocationData? allocationData;

  @override
  State<StructuralHealthChart> createState() => _StructuralHealthChartState();
}

class _StructuralHealthChartState extends State<StructuralHealthChart> {
  HealthScore? _healthScore;
  final FinancialCalculationService _calculationService =
      FinancialCalculationService();

  @override
  void initState() {
    super.initState();
    _calculateHealthScore();
  }

  @override
  void didUpdateWidget(StructuralHealthChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allocationData != oldWidget.allocationData) {
      _calculateHealthScore();
    }
  }

  Future<void> _calculateHealthScore() async {
    if (widget.allocationData == null) {
      if (!mounted) return;
      setState(() => _healthScore = null);
      return;
    }

    try {
      final score = await _calculationService
          .calculateHealthScore(widget.allocationData!);
      if (!mounted) return;
      setState(() => _healthScore = score);
    } catch (e) {
      print('[StructuralHealthChart] Error calculating health score: $e');
      if (!mounted) return;
      setState(() => _healthScore = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allocation = widget.allocationData;

    // Handle zero/null allocation case
    if (allocation == null || allocation.totalAmount == 0) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Donut Chart with centered score overlay
          SizedBox(
            height: 240,
            child: AspectRatio(
              aspectRatio: 1.0, // Square aspect ratio for donut chart
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Donut chart background
                  PieChart(
                    PieChartData(
                      sections: _buildChartSections(allocation),
                      centerSpaceRadius:
                          60, // Thin 15px ring (60 radius - 45 inner = 15px)
                      sectionsSpace:
                          0, // No space between sections for thin ring
                      centerSpaceColor: Colors.transparent,
                    ),
                  ),

                  // Centered Score Display (overlay on chart center)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _healthScore?.score.toStringAsFixed(0) ?? '75',
                        style: AppDesignTokens.largeTitle(context).copyWith(
                          color: AppDesignTokens.primaryText(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Health Score',
                        style: AppDesignTokens.caption(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Color-coded breakdown list
          _buildBreakdownList(allocation, context),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections(AllocationData allocation) {
    final sections = <PieChartSectionData>[];

    // Fixed expenses section (red)
    if (allocation.fixedAmount > 0) {
      sections.add(
        PieChartSectionData(
          value: allocation.fixedAmount,
          title: '',
          color: AppDesignTokens.amountNegativeColor(context), // Red for fixed
          radius: 15, // 15px ring thickness
        ),
      );
    }

    // Flexible expenses section (blue)
    if (allocation.flexibleAmount > 0) {
      sections.add(
        PieChartSectionData(
          value: allocation.flexibleAmount,
          title: '',
          color:
              AppDesignTokens.amountPositiveColor(context), // Blue for flexible
          radius: 15, // 15px ring thickness
        ),
      );
    }

    return sections;
  }

  Widget _buildBreakdownList(AllocationData allocation, BuildContext context) =>
      Column(
        children: [
          // Fixed expenses row
          _buildBreakdownRow(
            context,
            label: 'Fixed Expenses',
            amount: allocation.fixedAmount,
            formattedAmount: _formatAmount(allocation.fixedAmount),
            color: AppDesignTokens.amountNegativeColor(context),
          ),

          const SizedBox(height: 8),

          // Flexible expenses row
          _buildBreakdownRow(
            context,
            label: 'Flexible Expenses',
            amount: allocation.flexibleAmount,
            formattedAmount: _formatAmount(allocation.flexibleAmount),
            color: AppDesignTokens.amountPositiveColor(context),
          ),

          const SizedBox(height: 8),

          // Total row
          _buildBreakdownRow(
            context,
            label: 'Total',
            amount: allocation.totalAmount,
            formattedAmount: _formatAmount(allocation.totalAmount),
            color: AppDesignTokens.primaryText(context),
            isTotal: true,
          ),
        ],
      );

  String _formatAmount(double amount) => '¥${amount.toStringAsFixed(0)}';

  Widget _buildBreakdownRow(
    BuildContext context, {
    required String label,
    required double amount,
    required String formattedAmount,
    required Color color,
    bool isTotal = false,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: isTotal
                    ? AppDesignTokens.headline(context)
                    : AppDesignTokens.body(context),
              ),
            ],
          ),
          Text(
            formattedAmount,
            style: isTotal
                ? AppDesignTokens.headline(context).copyWith(color: color)
                : AppDesignTokens.body(context).copyWith(color: color),
          ),
        ],
      );

  Widget _buildEmptyState(BuildContext context) => Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Complete spending setup to see health score',
              style: AppDesignTokens.caption(context).copyWith(
                color: AppDesignTokens.secondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Placeholder donut ring
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppDesignTokens.inputFill(context),
                  width: 15,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '--',
                style: AppDesignTokens.largeTitle(context).copyWith(
                  color: AppDesignTokens.secondaryText(context),
                ),
              ),
            ),
          ],
        ),
      );
}
