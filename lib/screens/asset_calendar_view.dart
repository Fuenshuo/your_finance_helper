import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/providers/asset_provider.dart';
import 'package:your_finance_flutter/providers/transaction_provider.dart';
import 'package:your_finance_flutter/services/timeline_service.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

class AssetCalendarView extends StatefulWidget {
  const AssetCalendarView({super.key});

  @override
  State<AssetCalendarView> createState() => _AssetCalendarViewState();
}

class _AssetCalendarViewState extends State<AssetCalendarView> {
  final TimelineService _timelineService = TimelineService();
  DateTime _selectedMonth = DateTime.now();
  AssetTrend? _currentTrend;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAssetTrend();
  }

  Future<void> _loadAssetTrend() async {
    setState(() => _isLoading = true);

    try {
      final assetProvider = context.read<AssetProvider>();
      final transactionProvider = context.read<TransactionProvider>();

      final currentAssets = assetProvider.calculateTotalAssets();
      final recurringTransactions =
          transactionProvider.transactions.where((t) => t.isRecurring).toList();

      final startDate = DateTime(_selectedMonth.year, _selectedMonth.month);
      final endDate =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

      final events = _timelineService.getTimelineEvents(
        startDate: startDate,
        endDate: endDate,
        recurringTransactions: recurringTransactions,
      );

      final trend = _timelineService.getAssetTrend(
        startDate: startDate,
        endDate: endDate,
        currentAssets: currentAssets,
        events: events,
      );

      setState(() {
        _currentTrend = trend;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        // 静默处理错误，不显示提示框
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: const Text('资产日历'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime.now();
                });
                _loadAssetTrend();
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _currentTrend == null
                ? _buildEmptyState()
                : Column(
                    children: [
                      _buildMonthSelector(),
                      _buildTrendSummary(),
                      Expanded(child: _buildCalendarGrid()),
                    ],
                  ),
      );

  Widget _buildEmptyState() => Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacing32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 80,
                color: context.secondaryText,
              ),
              SizedBox(height: context.spacing24),
              Text(
                '暂无预测数据',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.spacing8),
              Text(
                '请先设置一些周期性交易来查看资产预测',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _buildMonthSelector() => Container(
        margin: EdgeInsets.all(context.spacing16),
        child: AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedMonth =
                        DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                  });
                  _loadAssetTrend();
                },
              ),
              Text(
                '${_selectedMonth.year}年${_selectedMonth.month}月',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedMonth =
                        DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                  });
                  _loadAssetTrend();
                },
              ),
            ],
          ),
        ),
      );

  Widget _buildTrendSummary() => Container(
        margin: EdgeInsets.symmetric(horizontal: context.spacing16),
        child: AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      '月初资产',
                      context.formatAmount(_currentTrend!.startAssets),
                      Icons.account_balance_wallet,
                      context.primaryText,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      '月末预测',
                      context.formatAmount(_currentTrend!.endAssets),
                      Icons.trending_up,
                      _getTrendColor(_currentTrend!.direction),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      '总收入',
                      context.formatAmount(_currentTrend!.totalIncome),
                      Icons.trending_up,
                      context.decreaseColor,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      '总支出',
                      context.formatAmount(_currentTrend!.totalExpense),
                      Icons.trending_down,
                      context.increaseColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      '净变化',
                      context.formatAmount(_currentTrend!.netChange),
                      Icons.balance,
                      _currentTrend!.netChange >= 0
                          ? context.decreaseColor
                          : context.increaseColor,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      '波动率',
                      '${(_currentTrend!.volatility / _currentTrend!.startAssets * 100).toStringAsFixed(1)}%',
                      Icons.show_chart,
                      _getRiskColor(_currentTrend!.riskLevel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) =>
      Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: context.spacing8),
          Text(
            title,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.secondaryText,
            ),
          ),
          SizedBox(height: context.spacing4),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      );

  Widget _buildCalendarGrid() => Container(
        margin: EdgeInsets.all(context.spacing16),
        child: AppCard(
          child: Column(
            children: [
              // 星期标题
              _buildWeekdayHeaders(),
              // 日期网格
              Expanded(
                child: _buildDateGrid(),
              ),
            ],
          ),
        ),
      );

  Widget _buildWeekdayHeaders() => Container(
        padding: EdgeInsets.symmetric(vertical: context.spacing8),
        child: Row(
          children: ['日', '一', '二', '三', '四', '五', '六']
              .map(
                (day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.secondaryText,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );

  Widget _buildDateGrid() => GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.2,
        ),
        itemCount: _getDaysInMonth() + _getFirstDayOfWeek(),
        itemBuilder: (context, index) {
          if (index < _getFirstDayOfWeek()) {
            return const SizedBox.shrink();
          }

          final day = index - _getFirstDayOfWeek() + 1;
          final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
          final prediction = _getPredictionForDate(date);

          return _buildDateCell(day, prediction);
        },
      );

  Widget _buildDateCell(int day, AssetPrediction? prediction) => Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: prediction != null
              ? _getCellColor(prediction)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.dividerColor,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: prediction != null ? Colors.white : context.primaryText,
              ),
            ),
            if (prediction != null) ...[
              const SizedBox(height: 2),
              Text(
                context.formatAmount(prediction.predictedAssets),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      );

  AssetPrediction? _getPredictionForDate(DateTime date) {
    if (_currentTrend == null) return null;

    return _currentTrend!.predictions
        .where((p) => p.date.day == date.day)
        .firstOrNull;
  }

  Color _getCellColor(AssetPrediction prediction) {
    if (prediction.netChange > 0) {
      return context.decreaseColor.withOpacity(0.7);
    } else if (prediction.netChange < 0) {
      return context.increaseColor.withOpacity(0.7);
    } else {
      return context.primaryAction.withOpacity(0.5);
    }
  }

  Color _getTrendColor(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.up:
        return context.decreaseColor;
      case TrendDirection.down:
        return context.increaseColor;
      case TrendDirection.stable:
        return context.primaryText;
    }
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return context.decreaseColor;
      case RiskLevel.medium:
        return context.warningColor;
      case RiskLevel.high:
        return context.increaseColor;
    }
  }

  int _getDaysInMonth() =>
      DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

  int _getFirstDayOfWeek() =>
      DateTime(_selectedMonth.year, _selectedMonth.month).weekday % 7;
}
