import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/add_transaction_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/transaction_list_screen.dart';

class TransactionManagementScreen extends StatefulWidget {
  const TransactionManagementScreen({super.key});

  @override
  State<TransactionManagementScreen> createState() =>
      _TransactionManagementScreenState();
}

class _TransactionManagementScreenState
    extends State<TransactionManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late final IOSAnimationSystem _animationSystem;

  @override
  void initState() {
    super.initState();

    // ===== v1.1.0 初始化企业级动效系统 =====
    _animationSystem = IOSAnimationSystem();

    // 注册交易管理专用动效曲线
    IOSAnimationSystem.registerCustomCurve('filter-panel-slide', Curves.easeInOutCubic);
    IOSAnimationSystem.registerCustomCurve('batch-action-feedback', Curves.elasticOut);
    IOSAnimationSystem.registerCustomCurve('tab-management-transition', Curves.fastOutSlowIn);

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationSystem.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: const Text('交易管理'),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: context.primaryAction,
            unselectedLabelColor: context.secondaryText,
            indicatorColor: context.primaryAction,
            tabs: const [
              Tab(text: '总览'),
              Tab(text: '交易记录'),
              Tab(text: '草稿'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showAddTransactionOptions(context),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildTransactionsTab(),
            _buildDraftsTab(),
          ],
        ),
      );

  // 总览标签页
  Widget _buildOverviewTab() =>
      Consumer3<TransactionProvider, AccountProvider, BudgetProvider>(
        builder: (
          context,
          transactionProvider,
          accountProvider,
          budgetProvider,
          child,
        ) {
          final transactions = transactionProvider.transactions;
          final accounts = accountProvider.accounts;

          // 计算统计数据
          final today = DateTime.now();
          final thisMonth = DateTime(today.year, today.month);
          final lastMonth = DateTime(today.year, today.month - 1);

          final thisMonthTransactions = transactions
              .where(
                (t) =>
                    t.date.isAfter(thisMonth) &&
                    t.status == TransactionStatus.confirmed,
              )
              .toList();

          final lastMonthTransactions = transactions
              .where(
                (t) =>
                    t.date.isAfter(lastMonth) &&
                    t.date.isBefore(thisMonth) &&
                    t.status == TransactionStatus.confirmed,
              )
              .toList();

          final thisMonthIncome = thisMonthTransactions
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (sum, t) => sum + t.amount);

          final thisMonthExpense = thisMonthTransactions
              .where((t) => t.type == TransactionType.expense)
              .fold(0.0, (sum, t) => sum + t.amount);

          final lastMonthIncome = lastMonthTransactions
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (sum, t) => sum + t.amount);

          final lastMonthExpense = lastMonthTransactions
              .where((t) => t.type == TransactionType.expense)
              .fold(0.0, (sum, t) => sum + t.amount);

          return SingleChildScrollView(
            padding: EdgeInsets.all(context.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 本月收支概览
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '本月收支',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: context.spacing16),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: '收入',
                              value: context.formatAmount(thisMonthIncome),
                              valueColor: context.successColor,
                              icon: Icons.trending_up,
                            ),
                          ),
                          SizedBox(width: context.spacing16),
                          Expanded(
                            child: StatCard(
                              title: '支出',
                              value: context.formatAmount(thisMonthExpense),
                              valueColor: context.errorColor,
                              icon: Icons.trending_down,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing12),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: '结余',
                              value: context.formatAmount(
                                thisMonthIncome - thisMonthExpense,
                              ),
                              valueColor:
                                  thisMonthIncome - thisMonthExpense >= 0
                                      ? context.successColor
                                      : context.errorColor,
                              icon: Icons.account_balance_wallet,
                            ),
                          ),
                          SizedBox(width: context.spacing16),
                          Expanded(
                            child: StatCard(
                              title: '交易笔数',
                              value: '${thisMonthTransactions.length}',
                              valueColor: context.primaryText,
                              icon: Icons.receipt_long,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing16),

                // 与上月对比
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '与上月对比',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: context.spacing16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildComparisonCard(
                              '收入',
                              thisMonthIncome,
                              lastMonthIncome,
                              Icons.trending_up,
                              context.successColor,
                            ),
                          ),
                          SizedBox(width: context.spacing16),
                          Expanded(
                            child: _buildComparisonCard(
                              '支出',
                              thisMonthExpense,
                              lastMonthExpense,
                              Icons.trending_down,
                              context.errorColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing16),

                // 快速操作
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '快速操作',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: context.spacing16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              '添加收入',
                              Icons.add_circle_outline,
                              context.successColor,
                              () => _navigateToAddTransaction(
                                TransactionType.income,
                              ),
                            ),
                          ),
                          SizedBox(width: context.spacing12),
                          Expanded(
                            child: _buildQuickActionButton(
                              '添加支出',
                              Icons.remove_circle_outline,
                              context.errorColor,
                              () => _navigateToAddTransaction(
                                TransactionType.expense,
                              ),
                            ),
                          ),
                          SizedBox(width: context.spacing12),
                          Expanded(
                            child: _buildQuickActionButton(
                              '转账',
                              Icons.swap_horiz,
                              context.primaryAction,
                              () => _navigateToAddTransaction(
                                TransactionType.transfer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing16),

                // 最近交易
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '最近交易',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () => _tabController.animateTo(1),
                            child: const Text('查看全部'),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing12),
                      ...transactions
                          .where((t) => t.status == TransactionStatus.confirmed)
                          .take(5)
                          .map(
                            (transaction) => _buildTransactionListItem(
                              transaction,
                              accounts,
                            ),
                          ),
                      if (transactions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            '暂无交易记录',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );

  // 交易记录标签页
  Widget _buildTransactionsTab() => const TransactionListScreen();

  // 草稿标签页
  Widget _buildDraftsTab() => Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          final drafts = transactionProvider.draftTransactions;

          if (drafts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '暂无草稿',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(context.spacing16),
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              final draft = drafts[index];
              return AppCard(
                margin: EdgeInsets.only(bottom: context.spacing12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getTransactionTypeColor(
                      draft.type ?? TransactionType.income,
                    ).withOpacity(0.1),
                    child: Icon(
                      _getTransactionTypeIcon(
                        draft.type ?? TransactionType.income,
                      ),
                      color: _getTransactionTypeColor(
                        draft.type ?? TransactionType.income,
                      ),
                    ),
                  ),
                  title: Text(draft.description),
                  subtitle: Text(
                    '${draft.type?.displayName ?? "未分类"} • ${draft.date.toString().split(' ')[0]}',
                  ),
                  trailing: Text(
                    context.formatAmount(draft.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getTransactionTypeColor(
                        draft.type ?? TransactionType.income,
                      ),
                    ),
                  ),
                  onTap: () => _editDraftTransaction(draft),
                ),
              );
            },
          );
        },
      );

  // 构建对比卡片
  Widget _buildComparisonCard(
    String title,
    double current,
    double previous,
    IconData icon,
    Color color,
  ) {
    final change =
        previous != 0 ? ((current - previous) / previous * 100) : 0.0;
    final isIncrease = change > 0;

    return Container(
      padding: EdgeInsets.all(context.spacing12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: context.spacing8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing8),
          Text(
            context.formatAmount(current),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: context.spacing4),
          Row(
            children: [
              Icon(
                isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: isIncrease ? context.successColor : context.errorColor,
              ),
              SizedBox(width: context.spacing4),
              Text(
                '${change.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  color: isIncrease ? context.successColor : context.errorColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建快速操作按钮
  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(context.spacing12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(height: context.spacing8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  // 构建交易列表项
  Widget _buildTransactionListItem(
    Transaction transaction,
    List<Account> accounts,
  ) {
    final account = accounts.firstWhere(
      (a) => a.id == transaction.fromAccountId,
      orElse: () => accounts.isNotEmpty
          ? accounts.first
          : Account(
              name: '未知账户',
              type: AccountType.cash,
            ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _getTransactionTypeColor(
              transaction.type ?? TransactionType.income,
            ).withOpacity(0.1),
            child: Icon(
              _getTransactionTypeIcon(
                transaction.type ?? TransactionType.income,
              ),
              size: 16,
              color: _getTransactionTypeColor(
                transaction.type ?? TransactionType.income,
              ),
            ),
          ),
          SizedBox(width: context.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${account.name} • ${transaction.date.toString().split(' ')[0]}',
                  style: TextStyle(
                    color: context.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            context.formatAmount(transaction.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getTransactionTypeColor(
                transaction.type ?? TransactionType.income,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 获取交易类型颜色
  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return context.successColor;
      case TransactionType.expense:
        return context.errorColor;
      case TransactionType.transfer:
        return context.primaryAction;
    }
  }

  // 获取交易类型图标
  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.trending_up;
      case TransactionType.expense:
        return Icons.trending_down;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  // 显示添加交易选项
  void _showAddTransactionOptions(BuildContext context) {
    _animationSystem.showIOSModal(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(context.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '添加交易',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.spacing24),
            _buildTransactionTypeOption(
              '收入',
              Icons.add_circle_outline,
              context.successColor,
              () => _navigateToAddTransaction(TransactionType.income),
            ),
            _buildTransactionTypeOption(
              '支出',
              Icons.remove_circle_outline,
              context.errorColor,
              () => _navigateToAddTransaction(TransactionType.expense),
            ),
            _buildTransactionTypeOption(
              '转账',
              Icons.swap_horiz,
              context.primaryAction,
              () => _navigateToAddTransaction(TransactionType.transfer),
            ),
          ],
        ),
      ),
    );
  }

  // 构建交易类型选项
  Widget _buildTransactionTypeOption(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) =>
      ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      );

  // 导航到添加交易页面
  void _navigateToAddTransaction(TransactionType type) {
    Navigator.of(context).push(
      AppAnimations.createRoute(
        AddTransactionScreen(initialType: type),
      ),
    );
  }

  // 编辑草稿交易
  void _editDraftTransaction(Transaction draft) {
    Navigator.of(context).push(
      AppAnimations.createRoute(
        AddTransactionScreen(editingTransaction: draft),
      ),
    );
  }
}
