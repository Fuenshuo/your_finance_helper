import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/insights/widgets/daily_pacer_widget.dart';
import 'package:your_finance_flutter/features/insights/widgets/weekly_trend_chart.dart';
import 'package:your_finance_flutter/features/insights/widgets/monthly_structure_card.dart';
import 'package:your_finance_flutter/features/insights/models/daily_cap.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';
import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';
import 'package:your_finance_flutter/features/insights/models/micro_insight.dart';
import 'package:your_finance_flutter/core/services/insight_service.dart';

/// Insights Dashboard with Daily/Weekly/Monthly tabs
class InsightsDashboard extends StatefulWidget {
  const InsightsDashboard({super.key});

  @override
  State<InsightsDashboard> createState() => _InsightsDashboardState();
}

class _InsightsDashboardState extends State<InsightsDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data - in real implementation, this would come from providers
  late DailyCap _dailyCap;
  late WeeklyInsight _weeklyInsight;
  late MonthlyHealthScore _monthlyHealth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize mock data
    _initializeMockData();
  }

  void _initializeMockData() {
    _dailyCap = DailyCap(
      id: 'daily_cap_dashboard',
      date: DateTime.now(),
      referenceAmount: 500.0,
      currentSpending: 320.0,
      percentage: 0.64,
      status: CapStatus.warning,
      latestInsight: null,
    );

    _weeklyInsight = WeeklyInsight(
      totalSpent: 1850.0,
      averageSpent: 264.29,
      anomalies: [
        WeeklyAnomaly(
          id: 'weekly_anomaly_dashboard',
          weekStart: DateTime.now().subtract(const Duration(days: 7)),
          anomalyDate: DateTime.now().subtract(const Duration(days: 3)),
          expectedAmount: 264.29,
          actualAmount: 650.0,
          deviation: 145.83,
          reason: '购物支出显著高于平均水平，建议检查消费记录',
          severity: AnomalySeverity.high,
          categories: ['购物'],
        ),
      ],
      monday: 180.0,
      tuesday: 220.0,
      wednesday: 650.0,
      thursday: 250.0,
      friday: 320.0,
      saturday: 150.0,
      sunday: 80.0,
    );

    _monthlyHealth = MonthlyHealthScore(
      id: 'monthly_health_dashboard',
      month: DateTime.now(),
      grade: LetterGrade.B,
      score: 82.0,
      diagnosis: '财务状况良好，支出控制得当，但有改善空间',
      factors: [
        HealthFactor(
          name: '预算控制',
          impact: 0.0,
          description: '支出控制在合理范围内',
        ),
        HealthFactor(
          name: '储蓄率',
          impact: 0.3,
          description: '储蓄率良好，有助于财务健康',
        ),
        HealthFactor(
          name: '消费结构',
          impact: 0.0,
          description: '消费结构相对合理',
        ),
      ],
      recommendations: [
        '继续保持良好的储蓄习惯',
        '关注异常高支出日，优化消费模式',
        '考虑增加投资额度以提升财务健康',
      ],
      metrics: {
        'survivalRatio': 45.0,
        'lifestyleRatio': 35.0,
        'savingsRatio': 20.0,
        'totalIncome': 18000.0,
        'totalExpenses': 14400.0,
        'netSavings': 3600.0,
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PerformanceMonitor.monitorBuild(
      'InsightsDashboard',
      () => Scaffold(
        backgroundColor: AppDesignTokens.pageBackground(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            '财务洞察',
            style: AppDesignTokens.largeTitle(context).copyWith(
              color: AppDesignTokens.primaryText(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppDesignTokens.primaryAction(context),
            labelColor: AppDesignTokens.primaryAction(context),
            unselectedLabelColor: AppDesignTokens.secondaryText(context),
            tabs: const [
              Tab(
                text: '每日',
                icon: Icon(Icons.today),
              ),
              Tab(
                text: '每周',
                icon: Icon(Icons.calendar_view_week),
              ),
              Tab(
                text: '每月',
                icon: Icon(Icons.calendar_month),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Daily Tab
            _buildDailyTab(),

            // Weekly Tab
            _buildWeeklyTab(),

            // Monthly Tab
            _buildMonthlyTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日消费概况',
            style: AppDesignTokens.headline(context),
          ),
          const SizedBox(height: 16),
          DailyPacerWidget(
            dailyCap: _dailyCap,
          ),
          const SizedBox(height: 24),
          _buildDailyInsights(),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本周消费模式',
            style: AppDesignTokens.headline(context),
          ),
          const SizedBox(height: 16),
          WeeklyTrendChart(
            weeklyInsight: _weeklyInsight,
            showThinking: false,
          ),
          const SizedBox(height: 24),
          _buildWeeklyInsights(),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '月度财务健康',
            style: AppDesignTokens.headline(context),
          ),
          const SizedBox(height: 16),
          MonthlyStructureCard(
            monthlyHealth: _monthlyHealth,
            onCardTap: () {
              // Navigate to detailed monthly report
              _showMonthlyReportDialog();
            },
          ),
          const SizedBox(height: 24),
          _buildMonthlyInsights(),
        ],
      ),
    );
  }

  Widget _buildDailyInsights() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日洞察',
              style: AppDesignTokens.headline(context),
            ),
            const SizedBox(height: 12),
            if (_dailyCap.latestInsight != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(
                      _getInsightIcon(_dailyCap.latestInsight!.sentiment),
                      color: _getInsightColor(_dailyCap.latestInsight!.sentiment),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _dailyCap.latestInsight!.message,
                        style: AppDesignTokens.body(context),
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                '暂无特别洞察，继续保持良好的消费习惯',
                style: AppDesignTokens.body(context).copyWith(
                  color: AppDesignTokens.secondaryText(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyInsights() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '本周异常分析',
              style: AppDesignTokens.headline(context),
            ),
            const SizedBox(height: 12),
            if (_weeklyInsight.anomalies.isNotEmpty) ...[
              ..._weeklyInsight.anomalies.map((anomaly) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getAnomalyIcon(anomaly.severity),
                              color: _getAnomalyColor(anomaly.severity),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${anomaly.anomalyDate.weekday == 1 ? 'Mon' : anomaly.anomalyDate.weekday == 2 ? 'Tue' : anomaly.anomalyDate.weekday == 3 ? 'Wed' : anomaly.anomalyDate.weekday == 4 ? 'Thu' : anomaly.anomalyDate.weekday == 5 ? 'Fri' : anomaly.anomalyDate.weekday == 6 ? 'Sat' : 'Sun'}: ¥${anomaly.actualAmount.toStringAsFixed(0)}',
                              style: AppDesignTokens.headline(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          anomaly.reason,
                          style: AppDesignTokens.body(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '影响分类: ${anomaly.categories.join(', ')}',
                          style: AppDesignTokens.caption(context).copyWith(
                            color: AppDesignTokens.secondaryText(context),
                          ),
                        ),
                      ],
                    ),
                  )),
            ] else ...[
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppDesignTokens.successColor(context),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '本周消费模式正常，无显著异常',
                    style: AppDesignTokens.body(context),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyInsights() {
    return Column(
      children: [
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '健康评分因素',
                  style: AppDesignTokens.headline(context),
                ),
                const SizedBox(height: 12),
                ..._monthlyHealth.factors.map((factor) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            factor.name,
                            style: AppDesignTokens.body(context),
                          ),
                          Row(
                            children: [
                              Text(
                                '${(factor.impact * 100).toStringAsFixed(0)}%',
                                style: AppDesignTokens.headline(context),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _getFactorIcon(factor.impact),
                                color: _getFactorColor(factor.impact),
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '改善建议',
                  style: AppDesignTokens.headline(context),
                ),
                const SizedBox(height: 12),
                ..._monthlyHealth.recommendations
                    .map((recommendation) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: AppDesignTokens.primaryAction(context),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
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
            ),
          ),
        ),
      ],
    );
  }

  void _showMonthlyReportDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${_monthlyHealth.month.year}年${_monthlyHealth.month.month}月财务报告',
          style: AppDesignTokens.headline(context),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _monthlyHealth.diagnosis,
                style: AppDesignTokens.body(context),
              ),
              const SizedBox(height: 16),
              Text(
                '总体评分: ${_monthlyHealth.score.toStringAsFixed(0)}/100 (${_monthlyHealth.grade.name}级)',
                style: AppDesignTokens.headline(context).copyWith(
                  color: AppDesignTokens.primaryAction(context),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  IconData _getInsightIcon(Sentiment sentiment) {
    switch (sentiment) {
      case Sentiment.positive:
        return Icons.trending_up;
      case Sentiment.neutral:
        return Icons.trending_flat;
      case Sentiment.negative:
        return Icons.trending_down;
    }
  }

  Color _getInsightColor(Sentiment sentiment) {
    switch (sentiment) {
      case Sentiment.positive:
        return AppDesignTokens.successColor(context);
      case Sentiment.neutral:
        return AppDesignTokens.secondaryText(context);
      case Sentiment.negative:
        return AppDesignTokens.moneyNegative(context);
    }
  }

  IconData _getAnomalyIcon(AnomalySeverity severity) {
    switch (severity) {
      case AnomalySeverity.low:
        return Icons.warning_amber;
      case AnomalySeverity.medium:
        return Icons.warning;
      case AnomalySeverity.high:
        return Icons.error;
    }
  }

  Color _getAnomalyColor(AnomalySeverity severity) {
    switch (severity) {
      case AnomalySeverity.low:
        return AppDesignTokens.warningColor;
      case AnomalySeverity.medium:
        return Colors.orange;
      case AnomalySeverity.high:
        return AppDesignTokens.moneyNegative(context);
    }
  }

  IconData _getFactorIcon(double impact) {
    if (impact > 0.1) return Icons.trending_up;
    if (impact < -0.1) return Icons.trending_down;
    return Icons.trending_flat;
  }

  Color _getFactorColor(double impact) {
    if (impact > 0.1) return AppDesignTokens.successColor(context);
    if (impact < -0.1) return AppDesignTokens.moneyNegative(context);
    return AppDesignTokens.secondaryText(context);
  }
}
