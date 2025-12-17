import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// ============================================================================
// MOCK DESIGN SYSTEM - AppDesignTokens
// ============================================================================

enum AppTheme {
  ModernForestGreen,
  EleganceDeepBlue,
  PremiumGraphite,
  ClassicBurgundy
}

enum MoneyTheme { FluxBlue, RevenueGreen, ExpenseRed }

class AppDesignTokens {
  // ============================================================================
  // DARK MODE BACKGROUNDS (Pure Black for Apple Health aesthetic)
  // ============================================================================

  /// Pure Black background for Apple Health-style screens
  static const Color _bgDark = Color(0xFF000000);

  /// Dark Grey surface for cards and elevated elements
  static const Color _surfaceDark = Color(0xFF1C1C1E);

  // ============================================================================
  // MONEY THEME COLORS (FluxBlue - Dark Mode Variants)
  // ============================================================================

  /// Neon Blue for positive amounts (income, gains)
  static const Color _positiveDark = Color(0xFF64D2FF);

  /// Neon Red for negative amounts (expenses, losses)
  static const Color _negativeDark = Color(0xFFFF453A);

  // ============================================================================
  // TEXT COLORS (Adaptive - White in Dark Mode)
  // ============================================================================

  static const Color _textPrimaryDark = Colors.white;
  static const Color _textSecondaryDark = Colors.white70;
  static const Color _textTertiaryDark = Colors.white54;

  // ============================================================================
  // DESIGN TOKEN METHODS
  // ============================================================================

  /// Page background - Pure Black for Apple Health aesthetic
  static Color pageBackground(BuildContext context) => _bgDark;

  /// Surface color for cards - Dark Grey
  static Color surfaceColor(BuildContext context) => _surfaceDark;

  /// Positive amount color - FluxBlue (Neon Blue)
  static Color amountPositiveColor(BuildContext context) => _positiveDark;

  /// Negative amount color - Neon Red
  static Color amountNegativeColor(BuildContext context) => _negativeDark;

  // ============================================================================
  // TEXT STYLES
  // ============================================================================

  /// Large title for main headings (Apple Health style)
  static TextStyle largeTitle(BuildContext context) => const TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: _textPrimaryDark,
        letterSpacing: -0.5,
      );

  /// Title for section headings
  static TextStyle title1(BuildContext context) => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: _textPrimaryDark,
        letterSpacing: -0.5,
      );

  /// Headline for card titles
  static TextStyle headline(BuildContext context) => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _textPrimaryDark,
      );

  /// Body text for descriptions
  static TextStyle body(BuildContext context) => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _textPrimaryDark,
      );

  /// Caption for secondary information
  static TextStyle caption(BuildContext context) => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _textSecondaryDark,
      );

  /// Micro caption for small details
  static TextStyle microCaption(BuildContext context) => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _textTertiaryDark,
      );

  // ============================================================================
  // LAYOUT CONSTANTS
  // ============================================================================

  /// Standard border radius for cards
  static const double radiusMedium = 16.0;

  /// Spacing constants
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
}

// ============================================================================
// APPLE HEALTH-STYLE WEEKLY TREND CHART SCREEN
// ============================================================================

class AppleHealthChartScreen extends StatefulWidget {
  const AppleHealthChartScreen({super.key});

  @override
  State<AppleHealthChartScreen> createState() => _AppleHealthChartScreenState();
}

class _AppleHealthChartScreenState extends State<AppleHealthChartScreen> {
  // Sample weekly data (Mon-Sun)
  final List<double> weeklyData = [45.0, 62.0, 38.0, 71.0, 55.0, 89.0, 43.0];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppDesignTokens.pageBackground(context),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDesignTokens.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Text(
                  'Weekly Activity',
                  style: AppDesignTokens.largeTitle(context),
                ),
                const SizedBox(height: AppDesignTokens.spacing8),
                Text(
                  'Your spending trends this week',
                  style: AppDesignTokens.caption(context),
                ),
                const SizedBox(height: AppDesignTokens.spacing32),

                // Chart Card
                Container(
                  padding: const EdgeInsets.all(AppDesignTokens.spacing24),
                  decoration: BoxDecoration(
                    color: AppDesignTokens.surfaceColor(context),
                    borderRadius:
                        BorderRadius.circular(AppDesignTokens.radiusMedium),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chart Title
                      Text(
                        'Daily Spending',
                        style: AppDesignTokens.headline(context),
                      ),
                      const SizedBox(height: AppDesignTokens.spacing12),

                      // Chart
                      SizedBox(
                        height: 250,
                        child: BarChart(
                          _buildBarChartData(),
                          swapAnimationDuration:
                              const Duration(milliseconds: 800),
                          swapAnimationCurve: Curves.easeInOutCubic,
                        ),
                      ),

                      const SizedBox(height: AppDesignTokens.spacing16),

                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem('Mon', 0),
                          const SizedBox(width: AppDesignTokens.spacing12),
                          _buildLegendItem('Tue', 1),
                          const SizedBox(width: AppDesignTokens.spacing12),
                          _buildLegendItem('Wed', 2),
                          const SizedBox(width: AppDesignTokens.spacing12),
                          _buildLegendItem('Thu', 3),
                          const SizedBox(width: AppDesignTokens.spacing12),
                          _buildLegendItem('Fri', 4),
                          const SizedBox(width: AppDesignTokens.spacing12),
                          _buildLegendItem('Sat', 5),
                          const SizedBox(width: AppDesignTokens.spacing12),
                          _buildLegendItem('Sun', 6),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDesignTokens.spacing24),

                // Summary Card
                Container(
                  padding: const EdgeInsets.all(AppDesignTokens.spacing24),
                  decoration: BoxDecoration(
                    color: AppDesignTokens.surfaceColor(context),
                    borderRadius:
                        BorderRadius.circular(AppDesignTokens.radiusMedium),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Summary',
                        style: AppDesignTokens.headline(context),
                      ),
                      const SizedBox(height: AppDesignTokens.spacing16),
                      _buildSummaryRow('Total Spent',
                          '\$${weeklyData.reduce((a, b) => a + b).toStringAsFixed(0)}'),
                      const SizedBox(height: AppDesignTokens.spacing8),
                      _buildSummaryRow('Daily Average',
                          '\$${(weeklyData.reduce((a, b) => a + b) / weeklyData.length).toStringAsFixed(1)}'),
                      const SizedBox(height: AppDesignTokens.spacing8),
                      _buildSummaryRow('Highest Day',
                          '\$${weeklyData.reduce((a, b) => a > b ? a : b).toStringAsFixed(0)}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  BarChartData _buildBarChartData() {
    final maxValue = weeklyData.reduce((a, b) => a > b ? a : b);

    return BarChartData(
      // No borders
      borderData: FlBorderData(show: false),

      // No grid lines
      gridData: const FlGridData(show: false),

      // Remove titles
      titlesData: const FlTitlesData(show: false),

      // Bar groups
      barGroups: List.generate(weeklyData.length, (index) {
        final value = weeklyData[index];
        final normalizedHeight = maxValue > 0 ? (value / maxValue) * 10.0 : 0.0;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: normalizedHeight,
              color: AppDesignTokens.amountPositiveColor(context),
              width: 24,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
              gradient: LinearGradient(
                colors: [
                  AppDesignTokens.amountPositiveColor(context),
                  AppDesignTokens.amountPositiveColor(context)
                      .withValues(alpha: 0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ],
        );
      }),

      // Custom tooltip
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor:
              AppDesignTokens.surfaceColor(context).withValues(alpha: 0.95),
          tooltipPadding: const EdgeInsets.all(AppDesignTokens.spacing8),
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
            '\$${weeklyData[group.x].toStringAsFixed(0)}',
            AppDesignTokens.body(context).copyWith(
              color: AppDesignTokens.amountPositiveColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      // Spacing
      groupsSpace: 16,
      alignment: BarChartAlignment.center,
    );
  }

  Widget _buildLegendItem(String label, int index) => Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppDesignTokens.amountPositiveColor(context),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppDesignTokens.microCaption(context),
          ),
        ],
      );

  Widget _buildSummaryRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppDesignTokens.body(context),
          ),
          Text(
            value,
            style: AppDesignTokens.headline(context).copyWith(
              color: AppDesignTokens.amountPositiveColor(context),
            ),
          ),
        ],
      );
}

// ============================================================================
// MAIN APP
// ============================================================================

void main() {
  runApp(const AppleHealthStyleApp());
}

class AppleHealthStyleApp extends StatelessWidget {
  const AppleHealthStyleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Apple Health Style Chart',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppDesignTokens.pageBackground(context),
          cardTheme: const CardThemeData(
            elevation: 0.0,
          ),
        ),
        home: const AppleHealthChartScreen(),
      );
}
