import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/family_info/screens/account_edit_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/add_transaction_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/transaction_detail_screen.dart';

/// 账户详情页面
class AccountDetailScreen extends StatefulWidget {
  const AccountDetailScreen({
    required this.account,
    super.key,
  });

  final Account account;

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'zh_CN',
    symbol: '¥',
    decimalDigits: 2,
  );

  // 翻转器特效动画相关
  late AnimationController _flipperAnimationController;
  late Animation<double> _changeAmountSlideAnimation; // +/- 金额底部向上弹出
  late Animation<double> _changeAmountOpacityAnimation; // +/- 金额淡出
  late Animation<double> _balanceFlipAnimation; // 余额数字翻转
  late Animation<double> _balanceOpacityAnimation; // 余额数字透明度
  late Animation<double> _transactionInsertAnimation; // 交易记录插入
  late Animation<double> _transactionHighlightAnimation; // 交易记录高亮

  // 动画状态
  bool _isFlipperAnimationRunning = false;
  bool _isBalanceInitialized = false; // 余额是否已初始化
  double _previousBalance = 0.0;
  double _currentBalance = 0.0;
  double _balanceChange = 0.0;
  TransactionType? _lastTransactionType;
  String? _newTransactionId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 初始化翻转器特效动画控制器
    _flipperAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3500), // 总动画时长3.5秒，让动画更舒缓
      vsync: this,
    );

    // +/- 金额从小到大弹性出现动画 (0-0.4秒) - 提前出现时间
    _changeAmountSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipperAnimationController,
        curve: const Interval(
          0.0,
          0.11,
          curve: Curves.elasticOut,
        ), // 0-0.4秒，小到大弹性出现
      ),
    );

    // +/- 金额保持显示动画 (0.4-3.5秒) - 整个动画过程中保持可见
    _changeAmountOpacityAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipperAnimationController,
        curve: const Interval(0.11, 1.0), // 0.4秒-结束保持完全可见
      ),
    );

    // 余额数字翻转动画 (0.8-3.0秒) - 真正的翻转时长
    _balanceFlipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipperAnimationController,
        curve: const Interval(
          0.23,
          0.86,
          curve: Curves.easeInOut,
        ), // 0.8-3.0秒真正的翻转
      ),
    );

    // 余额数字透明度动画 (0.8-3.0秒)
    _balanceOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipperAnimationController,
        curve: const Interval(0.23, 0.86, curve: Curves.easeInOut), // 0.8-3.0秒
      ),
    );

    // 交易记录插入动画 (0.8-2.5秒，同时与余额翻转)
    _transactionInsertAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipperAnimationController,
        curve: const Interval(0.23, 0.71, curve: Curves.easeOut), // 0.8-2.5秒
      ),
    );

    // 交易记录高亮动画 (3.0-3.5秒) - 最后高亮
    _transactionHighlightAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipperAnimationController,
        curve: const Interval(0.86, 1.0, curve: Curves.easeInOut), // 3.0-3.5秒
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在依赖变化时初始化余额追踪，确保数据已经准备好
    _initializeBalanceTracking();

    // 后备方案：如果500ms后还没有初始化，强制初始化一次
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isBalanceInitialized) {
        print('⏰ 后备初始化触发');
        _initializeBalanceTracking();
      }
    });
  }

  @override
  void didUpdateWidget(AccountDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果账户ID发生变化，重新初始化余额
    if (oldWidget.account.id != widget.account.id) {
      setState(() {
        _isBalanceInitialized = false;
        _previousBalance = 0.0;
        _currentBalance = 0.0;
      });
      _initializeBalanceTracking();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _flipperAnimationController.dispose();

    // 移除交易监听器
    if (mounted) {
      context
          .read<TransactionProvider>()
          .removeListener(_onTransactionsChanged);
    }

    super.dispose();
  }

  void _initializeBalanceTracking() {
    // 防止重复初始化
    if (_isBalanceInitialized) return;

    final transactionProvider = context.read<TransactionProvider>();
    final accountProvider = context.read<AccountProvider>();

    // 获取初始余额
    final initialBalance = accountProvider.getAccountBalance(
      widget.account.id,
      transactionProvider.transactions,
    );

    print('🎯 初始化账户余额: $initialBalance');

    setState(() {
      _isBalanceInitialized = true;
      _previousBalance = initialBalance;
      _currentBalance = initialBalance;
    });

    // 监听交易变化
    transactionProvider.addListener(_onTransactionsChanged);
  }

  void _onTransactionsChanged() {
    print('🔄 _onTransactionsChanged 被调用');
    final transactionProvider = context.read<TransactionProvider>();
    final accountProvider = context.read<AccountProvider>();

    final newBalance = accountProvider.getAccountBalance(
      widget.account.id,
      transactionProvider.transactions,
    );

    print('💰 当前余额: $_currentBalance, 新余额: $newBalance');

    // 检查余额是否发生变化且动画未在运行
    if ((newBalance - _currentBalance).abs() > 0.01 &&
        !_isFlipperAnimationRunning) {
      print('📈 检测到余额变化: ${newBalance - _currentBalance}');

      // 查找最新的交易（可能是刚添加的）
      final accountTransactions = transactionProvider.transactions
          .where(
            (t) =>
                t.fromAccountId == widget.account.id ||
                t.toAccountId == widget.account.id,
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (accountTransactions.isNotEmpty) {
        final latestTransaction = accountTransactions.first;
        // 如果这个交易是刚添加的（最近30秒内），标记为新交易
        final now = DateTime.now();
        final timeDiff = now.difference(latestTransaction.date).inSeconds;

        print('⏰ 最新交易时间差: $timeDiff秒, 交易ID: ${latestTransaction.id}');

        // 计算期望的金额变化
        final expectedAmountChange =
            latestTransaction.fromAccountId == widget.account.id
                ? -latestTransaction.amount
                : (latestTransaction.toAccountId == widget.account.id
                    ? latestTransaction.amount
                    : 0);

        final actualAmountChange = newBalance - _currentBalance;

        if (timeDiff <= 30 &&
            (actualAmountChange - expectedAmountChange).abs() < 0.01) {
          print(
            '🎭 触发翻转器特效! 时间差: $timeDiff秒, 金额匹配: $actualAmountChange ≈ $expectedAmountChange',
          );

          // 启动翻转器特效
          _startFlipperAnimation(
            previousBalance: _currentBalance,
            newBalance: newBalance,
            balanceChange: actualAmountChange,
            transactionType: latestTransaction.type ?? TransactionType.expense,
            newTransactionId: latestTransaction.id,
          );
          return;
        } else {
          print(
            '⏰ 时间差太久 ($timeDiff秒) 或金额不匹配 ($actualAmountChange ≠ $expectedAmountChange)，跳过动画',
          );
        }
      }

      // 普通余额变化（不显示动画）
      print('📊 普通余额变化更新');
      setState(() {
        _previousBalance = _currentBalance;
        _currentBalance = newBalance;
      });
    } else {
      print('💰 余额没有变化或动画正在运行');
    }
  }

  /// 启动翻转器特效动画
  void _startFlipperAnimation({
    required double previousBalance,
    required double newBalance,
    required double balanceChange,
    required TransactionType transactionType,
    required String newTransactionId,
  }) {
    print('🎭 启动翻转器特效动画');

    // 设置动画状态
    setState(() {
      _isFlipperAnimationRunning = true;
      _previousBalance = previousBalance;
      _currentBalance = newBalance;
      _balanceChange = balanceChange;
      _lastTransactionType = transactionType;
      _newTransactionId = newTransactionId;
    });

    // 启动动画
    _flipperAnimationController.reset();
    _flipperAnimationController.forward().then((_) {
      if (mounted) {
        // 动画完成后清理状态
        setState(() {
          _isFlipperAnimationRunning = false;
          _newTransactionId = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.account.name,
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: _showAddTransactionMenu,
              tooltip: '添加交易',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editAccount,
              tooltip: '编辑账户',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteAccountDialog,
              tooltip: '删除账户',
            ),
          ],
        ),
        body: Column(
          children: [
            // 账户余额卡片
            _buildBalanceCard(),

            // 标签页
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '概览'),
                Tab(text: '交易记录'),
                Tab(text: '统计分析'),
              ],
              labelColor: context.primaryColor,
              unselectedLabelColor: context.secondaryText,
              indicatorColor: context.primaryColor,
            ),

            // 标签页内容
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildTransactionsTab(),
                  _buildStatisticsTab(),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildBalanceCard() => Container(
        margin: EdgeInsets.all(context.responsiveSpacing16),
        padding: EdgeInsets.all(context.responsiveSpacing16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.account.type.isAsset
                ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                : [const Color(0xFFF44336), const Color(0xFFEF5350)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(context.responsiveSpacing12),
          boxShadow: [
            BoxShadow(
              color: (widget.account.type.isAsset
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336))
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.responsiveSpacing8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getAccountIcon(widget.account.type),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: context.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.account.name,
                        style: context.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.account.type.displayName,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing16),
            Stack(
              alignment: Alignment.center,
              children: [
                // 余额文本 - 真正的翻转器特效
                AnimatedBuilder(
                  animation: _flipperAnimationController,
                  builder: (context, child) {
                    if (!_isFlipperAnimationRunning) {
                      // 检查余额是否已初始化
                      if (!_isBalanceInitialized) {
                        // 显示加载状态
                        return const SizedBox(
                          height: 40,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        );
                      }

                      // 正常显示当前余额
                      return Text(
                        _currencyFormat.format(_currentBalance),
                        style: context.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      );
                    }

                    // 真正的数字滚动翻转效果 - 像老虎机一样
                    final balanceProgress = _balanceFlipAnimation.value;
                    final balanceOpacity = _balanceOpacityAnimation.value;

                    return Opacity(
                      opacity: balanceOpacity,
                      child: _buildSimpleNumberTransition(
                        fromValue: _previousBalance,
                        toValue: _currentBalance,
                        progress: balanceProgress,
                      ),
                    );
                  },
                ),

                // +/- 金额动画 - 优雅飘入效果，不会遮挡余额
                if (_isFlipperAnimationRunning)
                  AnimatedBuilder(
                    animation: _flipperAnimationController,
                    builder: (context, child) {
                      final scaleProgress = _changeAmountSlideAnimation.value;
                      final opacityProgress =
                          _changeAmountOpacityAnimation.value;

                      if (scaleProgress <= 0.0) {
                        return const SizedBox();
                      }

                      final changeColor =
                          _lastTransactionType == TransactionType.income
                              ? Colors.green
                              : Colors.red;

                      // 优雅的飘入动画 - 从上方飘入，停留在合适位置
                      final slideOffset = (1.0 - scaleProgress) * -40; // 从上方飘入

                      return Positioned(
                        top: slideOffset - 45, // 位置在余额上方，不会遮挡
                        child: Transform.scale(
                          scale: scaleProgress.clamp(0.6, 1.0), // 最小缩放到0.6，避免太小
                          child: Opacity(
                            opacity: opacityProgress,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: changeColor
                                    .withOpacity(opacityProgress * 0.95),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: changeColor
                                        .withOpacity(opacityProgress * 0.4),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '${_balanceChange >= 0 ? '+' : ''}${_currencyFormat.format(_balanceChange)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18, // 固定较大字体
                                  fontWeight: FontWeight.w600, // 稍微减轻字体粗细
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            SizedBox(height: context.spacing8),
            Text(
              '当前余额',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );

  Widget _buildOverviewTab() => SingleChildScrollView(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 账户信息
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 账户信息',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.spacing16),
                  _buildInfoRow('账户类型', widget.account.type.displayName),
                  _buildInfoRow('账户状态', widget.account.status.displayName),
                  if (widget.account.description?.isNotEmpty ?? false)
                    _buildInfoRow('描述', widget.account.description!),
                  _buildInfoRow(
                    '创建时间',
                    DateFormat('yyyy-MM-dd HH:mm')
                        .format(widget.account.creationDate),
                  ),
                  _buildInfoRow(
                    '最后更新',
                    DateFormat('yyyy-MM-dd HH:mm')
                        .format(widget.account.updateDate),
                  ),
                ],
              ),
            ),

            SizedBox(height: context.spacing16),

            // 本月统计
            Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                final now = DateTime.now();
                final startOfMonth = DateTime(now.year, now.month);
                final monthTransactions = transactionProvider.transactions
                    .where(
                      (t) =>
                          (t.fromAccountId == widget.account.id ||
                              t.toAccountId == widget.account.id) &&
                          t.date.isAfter(startOfMonth),
                    )
                    .toList();

                double income = 0;
                double expense = 0;

                for (final transaction in monthTransactions) {
                  if (transaction.fromAccountId == widget.account.id) {
                    expense += transaction.amount;
                  }
                  if (transaction.toAccountId == widget.account.id) {
                    income += transaction.amount;
                  }
                }

                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📊 本月统计',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              '收入',
                              _currencyFormat.format(income),
                              Colors.green,
                            ),
                          ),
                          SizedBox(width: context.spacing12),
                          Expanded(
                            child: _buildStatItem(
                              '支出',
                              _currencyFormat.format(expense),
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing12),
                      _buildStatItem(
                        '交易笔数',
                        '${monthTransactions.length}笔',
                        context.secondaryText,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );

  Widget _buildTransactionsTab() => Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          final accountTransactions = transactionProvider.transactions
              .where(
                (t) =>
                    t.fromAccountId == widget.account.id ||
                    t.toAccountId == widget.account.id,
              )
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (accountTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: context.spacing16),
                  Text(
                    '暂无交易记录',
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(context.responsiveSpacing16),
            itemCount: accountTransactions.length,
            itemBuilder: (context, index) =>
                _buildTransactionItem(accountTransactions[index]),
          );
        },
      );

  Widget _buildStatisticsTab() => SingleChildScrollView(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        child: Consumer<TransactionProvider>(
          builder: (context, transactionProvider, child) {
            final accountTransactions = transactionProvider.transactions
                .where(
                  (t) =>
                      t.fromAccountId == widget.account.id ||
                      t.toAccountId == widget.account.id,
                )
                .toList();

            // 计算月度统计
            final monthlyStats = <String, Map<String, double>>{};
            for (final transaction in accountTransactions) {
              final monthKey =
                  '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';

              monthlyStats.putIfAbsent(
                monthKey,
                () => {'income': 0, 'expense': 0},
              );

              if (transaction.fromAccountId == widget.account.id) {
                monthlyStats[monthKey]!['expense'] =
                    monthlyStats[monthKey]!['expense']! + transaction.amount;
              }
              if (transaction.toAccountId == widget.account.id) {
                monthlyStats[monthKey]!['income'] =
                    monthlyStats[monthKey]!['income']! + transaction.amount;
              }
            }

            final sortedMonths = monthlyStats.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📈 月度统计',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing16),
                      ...sortedMonths.take(6).map((month) {
                        final stats = monthlyStats[month]!;
                        return Padding(
                          padding: EdgeInsets.only(bottom: context.spacing12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  month,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '+${_currencyFormat.format(stats['income'])}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(width: context.spacing8),
                              Text(
                                '-${_currencyFormat.format(stats['expense'])}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: EdgeInsets.only(bottom: context.spacing12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.secondaryText,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );

  Widget _buildStatItem(String label, String value, Color color) => Column(
        children: [
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.spacing4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.secondaryText,
            ),
          ),
        ],
      );

  Widget _buildTransactionItem(Transaction transaction) {
    final isNewTransaction = transaction.id == _newTransactionId;

    return AnimatedBuilder(
      animation: _flipperAnimationController,
      builder: (context, child) {
        if (!_isFlipperAnimationRunning || !isNewTransaction) {
          // 正常显示交易项
          return Container(
            margin: EdgeInsets.only(bottom: context.spacing8),
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(context.responsiveSpacing8),
                  decoration: BoxDecoration(
                    color: transaction.type == TransactionType.income
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    transaction.type == TransactionType.income
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: transaction.type == TransactionType.income
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                title: Text(
                  transaction.description,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  DateFormat('MM-dd HH:mm').format(transaction.date),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.secondaryText,
                  ),
                ),
                trailing: Text(
                  '${transaction.type == TransactionType.income ? '+' : '-'}${_currencyFormat.format(transaction.amount)}',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: transaction.type == TransactionType.income
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _showTransactionDetail(transaction),
              ),
            ),
          );
        }

        // 翻转器特效 - 交易记录插入动画和高亮
        final insertProgress = _transactionInsertAnimation.value;
        final highlightProgress = _transactionHighlightAnimation.value;

        // 计算插入位置和透明度
        final slideOffset = (1.0 - insertProgress) * 100; // 从右侧滑入
        final opacity = insertProgress;

        // 计算高亮效果
        final highlightColor = highlightProgress > 0.0
            ? Colors.yellow.shade400.withOpacity(highlightProgress * 0.3)
            : Colors.transparent;

        return Container(
          margin: EdgeInsets.only(bottom: context.spacing8),
          child: Transform.translate(
            offset: Offset(slideOffset, 0), // 从右侧滑入
            child: Opacity(
              opacity: opacity,
              child: Card(
                margin: EdgeInsets.zero,
                color: highlightColor,
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(context.responsiveSpacing8),
                    decoration: BoxDecoration(
                      color: transaction.type == TransactionType.income
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      transaction.type == TransactionType.income
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: transaction.type == TransactionType.income
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  title: Text(
                    transaction.description,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('MM-dd HH:mm').format(transaction.date),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.secondaryText,
                    ),
                  ),
                  trailing: Text(
                    '${transaction.type == TransactionType.income ? '+' : '-'}${_currencyFormat.format(transaction.amount)}',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: transaction.type == TransactionType.income
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => _showTransactionDetail(transaction),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 简洁的数字过渡动画 - 老虎机风格的简单版本
  Widget _buildSimpleNumberTransition({
    required double fromValue,
    required double toValue,
    required double progress,
  }) {
    final fromText = _currencyFormat.format(fromValue);
    final toText = _currencyFormat.format(toValue);

    return Stack(
      alignment: Alignment.center,
      children: [
        // 原金额 - 淡出
        Opacity(
          opacity: (1.0 - progress * 0.8).clamp(0.0, 1.0),
          child: Text(
            fromText,
            style: context.textTheme.displaySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ),

        // 新金额 - 从下方滑入
        Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, (1.0 - progress) * 30), // 从下方滑入
            child: Text(
              toText,
              style: context.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ),
        ),

        // 老虎机滚动效果 - 在数字变化过程中显示
        if (progress > 0.3 && progress < 0.9)
          Opacity(
            opacity: progress < 0.6
                ? (progress - 0.3) * 3.33
                : (0.9 - progress) * 3.33,
            child: _buildRollingNumbers(fromValue, toValue, progress),
          ),
      ],
    );
  }

  // 生成真正的老虎机数字滚动效果
  Widget _buildRollingNumbers(
    double fromValue,
    double toValue,
    double progress,
  ) {
    final fromText = _currencyFormat.format(fromValue);
    final toText = _currencyFormat.format(toValue);

    // 找到两个数字字符串中较长的那个
    final maxLength = math.max(fromText.length, toText.length);

    // 对齐字符串长度（在前面补空格）
    final paddedFromText = fromText.padLeft(maxLength);
    final paddedToText = toText.padLeft(maxLength);

    final digits = <Widget>[];

    for (var i = 0; i < maxLength; i++) {
      final fromChar = paddedFromText[i];
      final toChar = paddedToText[i];

      // 如果是数字，进行滚动动画；如果是符号，直接显示
      if (RegExp(r'\d').hasMatch(fromChar) && RegExp(r'\d').hasMatch(toChar)) {
        digits.add(_buildRollingDigit(fromChar, toChar, progress));
      } else {
        digits.add(
          Text(
            toChar,
            style: context.textTheme.displaySmall?.copyWith(
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: digits,
    );
  }

  // 单个数字的滚动效果
  Widget _buildRollingDigit(String fromDigit, String toDigit, double progress) {
    final fromNum = int.parse(fromDigit);
    final toNum = int.parse(toDigit);

    // 计算滚动进度 - 让滚动更快更明显
    final scrollProgress = progress * 25; // 增加滚动距离

    // 计算当前应该显示的数字序列的偏移
    final baseNum = fromNum;
    final targetNum = toNum;

    // 计算从起始数字滚动到目标数字需要的步数
    final stepsToTarget = (targetNum - baseNum + 10) % 10;
    final currentStep = (scrollProgress % (stepsToTarget + 15)).round(); // 多滚几圈

    // 当前显示的数字
    final currentNum = (baseNum + currentStep) % 10;

    return Container(
      width: 32,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 滚动数字序列 - 显示更多数字
            ...List.generate(17, (index) {
              final i = index - 8; // 从 -8 到 8
              final digitNum = (currentNum + i + 20) % 10; // 循环0-9
              final yOffset = i * 40.0; // 每个数字40像素高

              // 创建数字消失和出现的渐变效果
              final distance = i.abs();
              final opacity = distance == 0
                  ? 1.0
                  : distance == 1
                      ? 0.8
                      : distance == 2
                          ? 0.4
                          : 0.1;

              return Positioned(
                top: yOffset + 6, // 居中偏移
                child: Opacity(
                  opacity: opacity,
                  child: Text(
                    digitNum.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: distance == 0 ? 32 : 28 - distance * 2,
                      fontWeight: FontWeight.bold,
                      shadows: distance == 0
                          ? [
                              Shadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              );
            }),

            // 中间高亮线条
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.8),
                      Colors.white.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 静态字符显示
  Widget _buildStaticCharacter(String char) => Text(
        char,
        style: context.textTheme.displaySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      );

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.money;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.loan:
        return Icons.account_balance_wallet;
      case AccountType.asset:
        return Icons.business;
      case AccountType.liability:
        return Icons.warning;
    }
  }

  void _showAddTransactionMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.arrow_downward, color: Colors.green),
              title: const Text('添加收入'),
              subtitle: const Text('从这个账户接收资金'),
              onTap: () {
                Navigator.of(context).pop();
                _addTransaction(TransactionType.income);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward, color: Colors.red),
              title: const Text('添加支出'),
              subtitle: const Text('从这个账户支出资金'),
              onTap: () {
                Navigator.of(context).pop();
                _addTransaction(TransactionType.expense);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.blue),
              title: const Text('转账'),
              subtitle: const Text('从这个账户转出到其他账户'),
              onTap: () {
                Navigator.of(context).pop();
                _addTransaction(TransactionType.transfer);
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        ),
      ),
    );
  }

  void _addTransaction(TransactionType type) {
    // 根据交易类型设置初始账户
    String? initialAccountId;
    switch (type) {
      case TransactionType.income:
        initialAccountId = widget.account.id; // 收入到这个账户
      case TransactionType.expense:
        initialAccountId = widget.account.id; // 支出从这个账户
      case TransactionType.transfer:
        // 转账时这个账户作为来源账户
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          initialType: type,
          initialAccountId: initialAccountId,
        ),
      ),
    );
  }

  void _editAccount() {
    // 导航到账户编辑页面
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccountEditScreen(account: widget.account),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除账户'),
        content: Text(
          '确定要删除账户"${widget.account.name}"吗？\n\n'
          '这将同时删除所有与该账户相关的交易记录，且此操作不可撤销。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteAccount();
              Navigator.of(context).pop(); // 关闭对话框
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final accountProvider = context.read<AccountProvider>();
      final transactionProvider = context.read<TransactionProvider>();

      // 获取所有与该账户相关的交易
      final relatedTransactions = transactionProvider.transactions
          .where(
            (transaction) =>
                transaction.fromAccountId == widget.account.id ||
                transaction.toAccountId == widget.account.id,
          )
          .toList();

      // 删除相关交易
      for (final transaction in relatedTransactions) {
        await transactionProvider.deleteTransaction(transaction.id);
      }

      // 删除账户
      await accountProvider.deleteAccount(widget.account.id);

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('账户已删除')),
      );

      // 返回上一页
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  void _showTransactionDetail(Transaction transaction) {
    Navigator.of(context).push(
      AppAnimations.createRoute(
        TransactionDetailScreen(transaction: transaction),
      ),
    );
  }
}
