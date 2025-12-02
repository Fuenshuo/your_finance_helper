import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/insights/models/allocation_data.dart';
import 'package:your_finance_flutter/features/insights/models/budget_data.dart';
import 'package:your_finance_flutter/features/insights/models/health_score.dart';
import 'package:your_finance_flutter/features/insights/models/trend_data.dart';
import 'package:your_finance_flutter/features/insights/services/financial_calculation_service.dart';
import 'package:your_finance_flutter/features/insights/widgets/daily_budget_velocity.dart';
import 'package:your_finance_flutter/features/insights/widgets/trend_radar_chart.dart';
import 'package:your_finance_flutter/features/insights/widgets/structural_health_chart.dart';

/// Flux Insights Premium High-Density UI Screen
///
/// Features:
/// - Dynamic theme-aware backgrounds and colors
/// - Premium high-density UI with Apple Health-like design
/// - Financial health score calculation
/// - Budget velocity tracking
/// - Trend radar chart
/// - Structural health donut chart
class FluxInsightsScreen extends StatefulWidget {
  const FluxInsightsScreen({super.key});

  @override
  State<FluxInsightsScreen> createState() => _FluxInsightsScreenState();
}

class _FluxInsightsScreenState extends State<FluxInsightsScreen> {
  late FinancialCalculationService _calculationService;
  HealthScore? _healthScore;
  late List<TrendData> _trendData = [];
  late AllocationData _allocationData = AllocationData(
    fixedAmount: 0.0,
    flexibleAmount: 0.0,
    period: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _calculationService = FinancialCalculationService();
    _loadPersistedData();
  }

  Future<void> _loadPersistedData() async {
    try {
      // Load trend data
      final savedTrendData = await _calculationService.loadTrendData();
      if (savedTrendData.isNotEmpty) {
        setState(() {
          _trendData = savedTrendData;
        });
      } else {
        _initializeSampleData();
      }

      // Load allocation data
      final savedAllocationData = await _calculationService.loadAllocationData();
      if (savedAllocationData != null) {
        setState(() {
          _allocationData = savedAllocationData;
        });
      }

      // Calculate health score after loading data
      _calculateHealthScore();
    } catch (e) {
      print('[FluxInsightsScreen] Error loading persisted data: $e');
      _initializeSampleData();
      _calculateHealthScore();
    }
  }

  void _initializeSampleData() {
    // Sample trend data for the past week
    _trendData = [
      TrendData(date: DateTime.now().subtract(const Duration(days: 6)), amount: 1200.0, dayLabel: 'Mon'),
      TrendData(date: DateTime.now().subtract(const Duration(days: 5)), amount: 800.0, dayLabel: 'Tue'),
      TrendData(date: DateTime.now().subtract(const Duration(days: 4)), amount: 1500.0, dayLabel: 'Wed'),
      TrendData(date: DateTime.now().subtract(const Duration(days: 3)), amount: 900.0, dayLabel: 'Thu'),
      TrendData(date: DateTime.now().subtract(const Duration(days: 2)), amount: 2000.0, dayLabel: 'Fri'),
      TrendData(date: DateTime.now().subtract(const Duration(days: 1)), amount: 600.0, dayLabel: 'Sat'),
      TrendData(date: DateTime.now(), amount: 1100.0, dayLabel: 'Sun'),
    ];

    // Sample allocation data: 75% fixed, 25% flexible
    _allocationData = AllocationData(
      fixedAmount: 750.0,
      flexibleAmount: 250.0,
      period: DateTime.now(),
    );
  }

  Future<void> _calculateHealthScore() async {
    try {
      final score = await _calculationService.calculateHealthScore(_allocationData);
      setState(() {
        _healthScore = score;
      });
    } catch (e) {
      print('[FluxInsightsScreen] Error calculating health score: $e');
      // Fallback to default values
      final fallbackAllocation = AllocationData(
        fixedAmount: 750.0,
        flexibleAmount: 250.0,
        period: DateTime.now(),
      );
      final fallbackScore = HealthScore.calculate(fallbackAllocation);
      setState(() {
        _healthScore = fallbackScore;
      });
    }
  }

  Future<void> _persistCurrentData() async {
    try {
      await _calculationService.saveTrendData(_trendData);
      await _calculationService.saveAllocationData(_allocationData);
    } catch (e) {
      print('[FluxInsightsScreen] Error persisting data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Monitor build performance
    PerformanceMonitor.startOperation('FluxInsightsScreen.build');

    final result = Container(
      color: AppDesignTokens.pageBackground(context),
      child: CustomScrollView(
        slivers: [
          // Immersive Header - NO Scaffold AppBar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 60, // Account for status bar
                left: 24,
                right: 24,
                bottom: 32,
              ),
              child: Text(
                'Flux Insights',
                style: AppDesignTokens.largeTitle(context).copyWith(
                  color: AppDesignTokens.primaryText(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Content sections in slivers
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Health Score Section
                AppCard(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: AppDesignTokens.surface(context),
                    child: Column(
                      children: [
                        Text(
                          'Financial Health Score',
                          style: AppDesignTokens.caption(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _healthScore?.score.toStringAsFixed(0) ?? '75',
                          style: AppDesignTokens.largeTitle(context).copyWith(
                            color: AppDesignTokens.amountPositiveColor(context),
                          ),
                        ),
                        Text(
                          '${_healthScore?.grade.name ?? 'C'} Grade',
                          style: AppDesignTokens.body(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Budget Velocity Section
                AppCard(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: AppDesignTokens.surface(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                      'Daily Budget Velocity',
                      style: AppDesignTokens.headline(context),
                    ),
                    const SizedBox(height: 16),
                    // Use actual DailyBudgetVelocity widget
                    DailyBudgetVelocity(
                      budgetData: BudgetData(
                        budgetAmount: 200.0,
                        spentAmount: 112.0,
                        date: DateTime.now(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Trend Chart Section
            AppCard(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: AppDesignTokens.surface(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending Trends',
                      style: AppDesignTokens.headline(context),
                    ),
                    const SizedBox(height: 16),
                    // Trend Radar Chart
                    TrendRadarChart(trendData: _trendData),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Structural Health Section
            AppCard(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: AppDesignTokens.surface(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Structural Health',
                      style: AppDesignTokens.headline(context),
                    ),
                    const SizedBox(height: 16),
                        // Structural Health Chart
                        StructuralHealthChart(allocationData: _allocationData),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
    );

    // End build performance monitoring
    PerformanceMonitor.endOperation('FluxInsightsScreen.build');

    return result;
  }
  }
