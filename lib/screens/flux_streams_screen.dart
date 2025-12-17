import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/app_primary_button.dart';
import 'package:your_finance_flutter/core/widgets/app_selection_controls.dart';
import 'package:your_finance_flutter/features/insights/screens/flux_insights_screen.dart';

/// Stream页面的主题色定义
class StreamThemeColors {
  static const Color primary = Color(0xFF007AFF); // 活力蓝
  static const Color accent = Color(0xFFFF9500); // 橙色
  static const Color success = Color(0xFF34C759); // 绿色
  static const Color error = Color(0xFFFF3B30); // 红色
  static const Color warning = Color(0xFFFF9500); // 橙色
  static const Color background = Color(0xFFF2F2F7); // 浅灰背景
  static const Color surface = Color(0xFF1C1C1E); // 深灰表面
  static const Color textPrimary = Color(0xFF1C1C1E); // 主要文字
  static const Color textSecondary = Color(0xFF8A8A8E); // 次要文字
}

/// Flux Streams Screen
///
/// - 合并 Stream / Insights
/// - 顶部 View Toggle (Day/Week/Month) 永远可见
/// - Insights Drawer 动画展示
class FluxStreamsScreen extends StatefulWidget {
  const FluxStreamsScreen({super.key});

  @override
  State<FluxStreamsScreen> createState() => _FluxStreamsScreenState();
}

class _FluxStreamsScreenState extends State<FluxStreamsScreen> {
  FluxCompositeView _currentView = FluxCompositeView.stream;
  FluxTimeframe _timeframe = FluxTimeframe.day;
  final List<_MockTransaction> _transactions = [
    _MockTransaction(
      description: 'Hand-brewed coffee',
      amount: -36.0,
      category: 'Food & Drink',
      occurredAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _MockTransaction(
      description: 'Freelance payout',
      amount: 1200,
      category: 'Income',
      occurredAt: DateTime.now().subtract(const Duration(hours: 6)),
      isIncome: true,
    ),
    _MockTransaction(
      description: 'Metro top-up',
      amount: -80,
      category: 'Transport',
      occurredAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
  ];

  bool _drawerVisible = false;
  bool _drawerExpanded = false;
  String _drawerMessage = '';
  Timer? _drawerTimer;
  bool _isAnalyzing = false;
  int _analysisRuns = 0;

  @override
  void dispose() {
    _drawerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? Colors.black : StreamThemeColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                children: [
                  _buildViewToggle(context),
                  const SizedBox(width: 12),
                  _buildInsightsDrawer(context),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Test drawer',
                    icon: Icon(
                      PhosphorIcons.sparkle(),
                      color: isDark ? Colors.white70 : Colors.black54,
                      size: 20.0,
                    ),
                    onPressed: _showInsightsDrawer,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.palette_outlined,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    onPressed: () {
                      // TODO: 实现颜色主题切换
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _currentView == FluxCompositeView.stream
                    ? _buildStreamBody(context)
                    : _buildInsightsBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            AppDesignTokens.primaryShadow(context),
          ],
        ),
        child: AppSegmentedControl<FluxTimeframe>(
          groupValue: _timeframe,
          onValueChanged: (value) {
            if (value == null) return;
            if (_drawerVisible || _drawerExpanded) {
              _drawerTimer?.cancel();
            }
            setState(() {
              _timeframe = value;
              _currentView = FluxCompositeView.stream;
              _drawerVisible = false;
              _drawerExpanded = false;
            });
          },
          children: const {
            FluxTimeframe.day: Text('Day'),
            FluxTimeframe.week: Text('Week'),
            FluxTimeframe.month: Text('Month'),
          },
        ),
      );

  Widget _buildInsightsDrawer(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.5;
    final targetWidth = !_drawerVisible
        ? 0.0
        : _drawerExpanded
            ? min(maxWidth, 220.0)
            : 48.0;

    if (!_drawerVisible && targetWidth <= 0) {
      return const SizedBox.shrink();
    }

    final showText = _drawerExpanded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: targetWidth,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          AppDesignTokens.primaryShadow(context),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _drawerVisible
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleInsightsIconTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.lightbulb(),
                        color: StreamThemeColors.primary,
                        size: 20,
                      ),
                      if (showText) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _drawerMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppDesignTokens.caption(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppDesignTokens.primaryText(context),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildStreamBody(BuildContext context) => ListView.separated(
        key: const ValueKey('stream-view'),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Timeline · ${_timeframe.label}',
                  style: AppDesignTokens.headline(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a mock transaction to trigger Flux Insights in the background.',
                  style: AppDesignTokens.caption(context),
                ),
                const SizedBox(height: 16),
                AppPrimaryButton(
                  label: 'Add transaction',
                  icon: PhosphorIcons.plusCircle(),
                  onPressed: _simulateAddTransaction,
                ),
              ],
            );
          }

          final tx = _transactions[index - 1];
          return _TransactionCard(transaction: tx);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemCount: _transactions.length + 1,
      );

  Widget _buildInsightsBody() => const FluxInsightsScreen(
        key: ValueKey('insights-view'),
      );

  Future<void> _simulateAddTransaction() async {
    if (_isAnalyzing) return;

    final random = Random();
    final isIncome = random.nextBool();
    final delta = (random.nextDouble() * (isIncome ? 2000 : 300))
        .clamp(20, 2000)
        .toDouble();

    setState(() {
      _transactions.insert(
        0,
        _MockTransaction(
          description: isIncome ? 'Transfer from savings' : 'Cafe latte break',
          amount: isIncome ? delta : -delta,
          category: isIncome ? 'Income' : 'Lifestyle',
          occurredAt: DateTime.now(),
          isIncome: isIncome,
        ),
      );
      _isAnalyzing = true;
    });

    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
    });
    _showInsightsDrawer();
  }

  void _showInsightsDrawer() {
    _analysisRuns += 1;
    final improvements = 2 + (_analysisRuns % 3);

    _drawerTimer?.cancel();
    setState(() {
      _drawerVisible = true;
      _drawerExpanded = true;
      _drawerMessage = '$improvements improvements found';
    });

    _drawerTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _drawerExpanded = false;
      });
    });
  }

  void _handleInsightsIconTap() {
    if (!_drawerVisible) return;
    setState(() {
      _currentView = FluxCompositeView.insights;
      _drawerExpanded = true;
    });

    _drawerTimer?.cancel();
    _drawerTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _drawerExpanded = false;
      });
    });
  }
}

class _MockTransaction {
  const _MockTransaction({
    required this.description,
    required this.amount,
    required this.category,
    required this.occurredAt,
    this.isIncome = false,
  });
  final String description;
  final double amount;
  final String category;
  final DateTime occurredAt;
  final bool isIncome;
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final _MockTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome || transaction.amount >= 0;
    final amountColor =
        isIncome ? StreamThemeColors.success : StreamThemeColors.error;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? PhosphorIcons.arrowUpRight()
                  : PhosphorIcons.arrowDownLeft(),
              color: amountColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppDesignTokens.headline(context),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.category} • ${DateFormat('MMM d, HH:mm').format(transaction.occurredAt)}',
                  style: AppDesignTokens.caption(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _formatAmount(transaction.amount),
            style: AppDesignTokens.primaryValue(context).copyWith(
              color: amountColor,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatted =
        NumberFormat.currency(locale: 'en', symbol: '¥', decimalDigits: 0)
            .format(amount.abs());
    return amount >= 0 ? '+$formatted' : '-$formatted';
  }
}

enum FluxCompositeView { stream, insights }

enum FluxTimeframe { day, week, month }

extension on FluxTimeframe {
  String get label {
    switch (this) {
      case FluxTimeframe.day:
        return 'Day';
      case FluxTimeframe.week:
        return 'Week';
      case FluxTimeframe.month:
        return 'Month';
    }
  }
}
