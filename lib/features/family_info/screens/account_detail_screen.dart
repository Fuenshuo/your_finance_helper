import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/unified_notifications.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/swipe_action_item.dart';
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

  // ===== v1.1.0 新动效系统 =====
  late final IOSAnimationSystem _animationSystem;
  late AnimationController _transactionAnimationController;
  late Animation<double> _balanceProgressAnimation;
  late Animation<double> _amountScaleAnimation;
  late Animation<double> _transactionSlideAnimation;
  late Animation<double> _highlightAnimation;

  bool _isBalanceInitialized = false;
  double _previousBalance = 0.0;
  double _currentBalance = 0.0;
  String? _newTransactionId;
  bool _isTransactionAnimationRunning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // ===== v1.1.0 初始化新动效系统 =====
    _animationSystem = IOSAnimationSystem();

    // 注册账户详情专用动画曲线
    IOSAnimationSystem.registerCustomCurve('balance-flip', Curves.elasticOut);
    IOSAnimationSystem.registerCustomCurve('amount-bounce', Curves.bounceOut);
    IOSAnimationSystem.registerCustomCurve(
      'transaction-slide',
      Curves.easeOutCubic,
    );
    IOSAnimationSystem.registerCustomCurve('highlight-pulse', Curves.easeInOut);

    // 初始化交易动画控制器 (总时长3.5秒，与原版保持一致)
    _transactionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    // 余额数字过渡动画 (0.8-3.0秒)
    _balanceProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transactionAnimationController,
        curve: const Interval(0.23, 0.86, curve: Curves.easeInOut),
      ),
    );

    // +/- 金额缩放动画 (0-0.4秒)
    _amountScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transactionAnimationController,
        curve: const Interval(0.0, 0.11, curve: Curves.elasticOut),
      ),
    );

    // 交易记录滑入动画 (0.8-2.5秒)
    _transactionSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transactionAnimationController,
        curve: const Interval(0.23, 0.71, curve: Curves.easeOut),
      ),
    );

    // 高亮动画 (3.0-3.5秒)
    _highlightAnimation = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _transactionAnimationController,
        curve: const Interval(0.86, 1.0, curve: Curves.easeInOut),
      ),
    );

    // 添加动画监听器以确保状态同步
    _transactionAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (mounted && _isTransactionAnimationRunning) {
          setState(() {
            _isTransactionAnimationRunning = false;
            _newTransactionId = null;
          });
        }
      }
    });

    print('🎨 初始化v1.1.0动效系统完成');
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
    _transactionAnimationController.dispose();
    _animationSystem.dispose();

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

    // 检查余额是否发生变化且没有正在运行的动画
    if ((newBalance - _currentBalance).abs() > 0.01 &&
        !_isTransactionAnimationRunning) {
      print('📈 检测到余额变化: ${newBalance - _currentBalance}');

      final actualAmountChange = newBalance - _currentBalance;
      final isBalanceIncrease = actualAmountChange > 0;

      // 查找相关的交易记录
      final accountTransactions = transactionProvider.transactions
          .where(
            (t) =>
                t.fromAccountId == widget.account.id ||
                t.toAccountId == widget.account.id,
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      String? targetTransactionId;

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

        if (timeDiff <= 30 &&
            (actualAmountChange - expectedAmountChange).abs() < 0.01) {
          print(
            '🎭 触发v1.1.0动效序列! 时间差: $timeDiff秒, 金额匹配: $actualAmountChange ≈ $expectedAmountChange',
          );

          // 使用v1.1.0新动效系统启动动画序列
          _startTransactionAnimationSequence(
            previousBalance: _currentBalance,
            newBalance: newBalance,
            balanceChange: actualAmountChange,
            transactionType: latestTransaction.type ?? TransactionType.expense,
            newTransactionId: latestTransaction.id,
          );
          return;
        } else {
          print(
            '⏰ 时间差太久 ($timeDiff秒) 或金额不匹配 ($actualAmountChange ≠ $expectedAmountChange)，可能是删除操作',
          );
        }
      }

      // 对于非新增交易的情况（比如删除交易），也触发动效但不标记新交易ID
      print(
        '🎭 触发余额变化动效! 变化: $actualAmountChange (可能是删除交易)',
      );

      _startBalanceChangeAnimation(
        previousBalance: _currentBalance,
        newBalance: newBalance,
        balanceChange: actualAmountChange,
        isIncrease: isBalanceIncrease,
      );
      return;
    } else {
      print('💰 余额没有变化或动画序列正在运行');
    }
  }

  /// ===== v1.1.0 新动效系统：处理余额变化动效（删除交易等） =====
  void _startBalanceChangeAnimation({
    required double previousBalance,
    required double newBalance,
    required double balanceChange,
    required bool isIncrease,
  }) {
    print('🎭 启动余额变化动效');

    // 安全检查：确保数据有效
    if (previousBalance.isNaN ||
        previousBalance.isInfinite ||
        newBalance.isNaN ||
        newBalance.isInfinite) {
      print('⚠️ 检测到无效的余额数据，跳过动画');
      setState(() {
        _previousBalance = newBalance;
        _currentBalance = newBalance;
      });
      return;
    }

    // 设置动画状态
    setState(() {
      _isTransactionAnimationRunning = true;
      _previousBalance = previousBalance;
      _currentBalance = newBalance;
    });

    // 简化版本：只有余额数字过渡和金额提示（2秒总时长）
    _transactionAnimationController.reset();
    _transactionAnimationController.forward().then((_) {
      if (mounted) {
        print('✅ 余额变化动效完成');
        setState(() {
          _isTransactionAnimationRunning = false;
        });
      }
    }).catchError((Object error) {
      print('❌ 余额变化动效出错: $error');
      if (mounted) {
        setState(() {
          _isTransactionAnimationRunning = false;
        });
      }
    });
  }

  /// ===== v1.1.0 新动效系统：启动交易动画序列 =====
  void _startTransactionAnimationSequence({
    required double previousBalance,
    required double newBalance,
    required double balanceChange,
    required TransactionType transactionType,
    required String newTransactionId,
  }) {
    print('🎭 启动v1.1.0交易动效序列');

    // 安全检查：确保数据有效
    if (previousBalance.isNaN ||
        previousBalance.isInfinite ||
        newBalance.isNaN ||
        newBalance.isInfinite) {
      print('⚠️ 检测到无效的余额数据，跳过动画');
      setState(() {
        _previousBalance = newBalance;
        _currentBalance = newBalance;
      });
      return;
    }

    // 设置动画状态
    setState(() {
      _isTransactionAnimationRunning = true;
      _previousBalance = previousBalance;
      _currentBalance = newBalance;
      _newTransactionId = newTransactionId;
    });

    // 启动动画控制器
    _transactionAnimationController.reset();
    _transactionAnimationController.forward().then((_) {
      if (mounted) {
        print('✅ v1.1.0动效序列执行完成');
        setState(() {
          _isTransactionAnimationRunning = false;
          _newTransactionId = null;
        });
      }
    }).catchError((Object error) {
      print('❌ v1.1.0动效序列执行出错: $error');
      if (mounted) {
        setState(() {
          _isTransactionAnimationRunning = false;
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
                physics:
                    const NeverScrollableScrollPhysics(), // 禁用滑动切换，防止与Dismissible冲突
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
                // ===== v1.1.0 余额文本显示 =====
                if (!_isBalanceInitialized)
                  const SizedBox(
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
                  )
                else
                  _isTransactionAnimationRunning
                      // 动画过程中显示数字过渡
                      ? AnimatedBuilder(
                          animation: _transactionAnimationController,
                          builder: (context, child) {
                            final progress = _balanceProgressAnimation.value;
                            final displayValue = _previousBalance +
                                (_currentBalance - _previousBalance) * progress;

                            return Text(
                              _currencyFormat.format(displayValue),
                              style: context.textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            );
                          },
                        )
                      // 正常状态显示当前余额
                      : Text(
                          _currencyFormat.format(_currentBalance),
                          style: context.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),

                // ===== v1.1.0 +/- 金额显示 =====
                if (_isTransactionAnimationRunning)
                  AnimatedBuilder(
                    animation: _transactionAnimationController,
                    builder: (context, child) {
                      final progress = _amountScaleAnimation.value;
                      final clampedProgress = progress.clamp(0.0, 1.0);

                      if (clampedProgress <= 0.0) return const SizedBox();

                      final balanceChange = _currentBalance - _previousBalance;
                      final changeColor =
                          balanceChange >= 0 ? Colors.green : Colors.red;
                      final slideOffset = (1.0 - clampedProgress) * -40;

                      return Positioned(
                        top: slideOffset - 45,
                        child: Transform.scale(
                          scale: clampedProgress.clamp(0.6, 1.0),
                          child: Opacity(
                            opacity: clampedProgress,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: changeColor.withOpacity(
                                  (clampedProgress * 0.95).clamp(0.0, 1.0),
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: changeColor.withOpacity(
                                      (clampedProgress * 0.4).clamp(0.0, 1.0),
                                    ),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '${balanceChange >= 0 ? '+' : ''}'
                                '${_currencyFormat.format(balanceChange)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
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
                _buildDismissibleTransactionItem(accountTransactions[index]),
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

  // ===== 左滑显示删除按钮的交易项 =====
  Widget _buildDismissibleTransactionItem(Transaction transaction) =>
      SwipeActionItem(
        action: SwipeAction.delete(() => _deleteTransaction(transaction)),
        child: _buildTransactionItem(transaction),
      );

  // 执行删除交易
  Future<void> _deleteTransaction(Transaction transaction) async {
    try {
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);

      // 删除交易
      await transactionProvider.deleteTransaction(transaction.id);

      // 触发动效显示余额变化
      _onTransactionsChanged();

      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('交易已删除'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: $e'),
            backgroundColor: context.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isNewTransaction = transaction.id == _newTransactionId;

    return _isTransactionAnimationRunning && isNewTransaction
        // ===== v1.1.0 新交易动效 =====
        ? AnimatedBuilder(
            animation: _transactionAnimationController,
            builder: (context, child) {
              // 计算动画进度 - 交易记录插入动画 (0.8-2.5秒)
              final insertProgress =
                  _transactionSlideAnimation.value.clamp(0.0, 1.0);
              final highlightProgress =
                  _highlightAnimation.value.clamp(0.0, 1.0);

              // 计算插入位置和透明度
              final slideOffset = (1.0 - insertProgress) * 100; // 从右侧滑入
              final opacity = insertProgress;

              // 计算高亮效果
              final highlightColor = highlightProgress > 0.0
                  ? Colors.yellow.shade400
                      .withOpacity((highlightProgress * 0.3).clamp(0.0, 1.0))
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
          )
        // ===== 正常显示交易项 =====
        : Container(
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

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await unifiedNotifications.showConfirmation(
      context,
      title: '删除账户',
      message: '确定要删除账户"${widget.account.name}"吗？\n\n'
          '这将同时删除所有与该账户相关的交易记录，且此操作不可撤销。',
      confirmLabel: '删除',
      confirmColor: Colors.red,
    );

    if (confirmed ?? false) {
      await _deleteAccount();
    }
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
      unifiedNotifications.showSuccess(context, '账户已删除');

      // 返回上一页
      Navigator.of(context).pop();
    } catch (e) {
      unifiedNotifications.showError(context, '删除失败: $e');
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
