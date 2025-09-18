import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/create_budget_screen.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/envelope_budget_detail_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/salary_income_setup_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/services/auto_transaction_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

class BudgetManagementScreen extends StatefulWidget {
  const BudgetManagementScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  /// 初始显示的标签页索引 (0: 总览, 1: 信封预算, 2: 零基预算, 3: 工资收入)
  final int initialTabIndex;

  @override
  State<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: const Text('预算管理'),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: context.primaryAction,
            unselectedLabelColor: context.secondaryText,
            indicatorColor: context.primaryAction,
            tabs: const [
              Tab(text: '总览'),
              Tab(text: '信封预算'),
              Tab(text: '零基预算'),
              Tab(text: '工资收入'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showCreateBudgetOptions(context),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildEnvelopeTab(),
            _buildZeroBasedTab(),
            _buildSalaryIncomeTab(),
          ],
        ),
      );

  // 总览标签页
  Widget _buildOverviewTab() => Consumer2<BudgetProvider, AccountProvider>(
        builder: (context, budgetProvider, accountProvider, child) {
          if (budgetProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentZeroBased = budgetProvider.getCurrentZeroBasedBudget();
          final currentEnvelopes = budgetProvider.getCurrentEnvelopeBudgets();
          final totalAllocated = budgetProvider.calculateTotalBudgetAllocated();
          final totalSpent = budgetProvider.calculateTotalBudgetSpent();
          final totalAvailable = budgetProvider.calculateTotalBudgetAvailable();

          return RefreshIndicator(
            onRefresh: () => budgetProvider.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(context.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 预算总览卡片
                  AppAnimations.animatedListItem(
                    index: 0,
                    child: _buildBudgetOverviewCard(
                      totalAllocated: totalAllocated,
                      totalSpent: totalSpent,
                      totalAvailable: totalAvailable,
                      budgetProvider: budgetProvider,
                    ),
                  ),
                  SizedBox(height: context.spacing16),

                  // 当前零基预算
                  if (currentZeroBased != null) ...[
                    AppAnimations.animatedListItem(
                      index: 1,
                      child: _buildCurrentZeroBasedCard(currentZeroBased),
                    ),
                    SizedBox(height: context.spacing16),
                  ],

                  // 信封预算列表
                  if (currentEnvelopes.isNotEmpty) ...[
                    AppAnimations.animatedListItem(
                      index: 2,
                      child: _buildEnvelopeListHeader(),
                    ),
                    SizedBox(height: context.spacing8),
                    ...currentEnvelopes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final envelope = entry.value;
                      return AppAnimations.animatedListItem(
                        index: index + 3,
                        child: _buildEnvelopeCard(envelope),
                      );
                    }),
                  ],

                  // 无预算提示
                  if (currentEnvelopes.isEmpty && currentZeroBased == null) ...[
                    AppAnimations.animatedListItem(
                      index: 1,
                      child: _buildNoBudgetCard(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );

  // 信封预算标签页
  Widget _buildEnvelopeTab() => Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          final envelopes = budgetProvider.activeEnvelopeBudgets;

          if (budgetProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (envelopes.isEmpty) {
            return _buildEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: '暂无信封预算',
              subtitle: '创建信封预算来更好地管理支出',
              actionText: '创建信封预算',
              onAction: () => _navigateToCreateBudget(BudgetType.envelope),
            );
          }

          return RefreshIndicator(
            onRefresh: () => budgetProvider.refresh(),
            child: ListView.builder(
              padding: EdgeInsets.all(context.spacing16),
              itemCount: envelopes.length,
              itemBuilder: (context, index) => AppAnimations.animatedListItem(
                index: index,
                child: _buildEnvelopeCard(envelopes[index]),
              ),
            ),
          );
        },
      );

  // 零基预算标签页
  Widget _buildZeroBasedTab() => Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          final zeroBasedBudgets = budgetProvider.activeZeroBasedBudgets;

          if (budgetProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (zeroBasedBudgets.isEmpty) {
            return _buildEmptyState(
              icon: Icons.pie_chart_outline,
              title: '暂无零基预算',
              subtitle: '创建零基预算来规划收入分配',
              actionText: '创建零基预算',
              onAction: () => _navigateToCreateBudget(BudgetType.zeroBased),
            );
          }

          return RefreshIndicator(
            onRefresh: () => budgetProvider.refresh(),
            child: ListView.builder(
              padding: EdgeInsets.all(context.spacing16),
              itemCount: zeroBasedBudgets.length,
              itemBuilder: (context, index) => AppAnimations.animatedListItem(
                index: index,
                child: _buildZeroBasedCard(zeroBasedBudgets[index]),
              ),
            ),
          );
        },
      );

  // 预算总览卡片
  Widget _buildBudgetOverviewCard({
    required double totalAllocated,
    required double totalSpent,
    required double totalAvailable,
    required BudgetProvider budgetProvider,
  }) =>
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '预算总览',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.spacing16),

            // 三个关键指标
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: '总预算',
                    value: context.formatAmount(totalAllocated),
                    valueColor: context.primaryText,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                SizedBox(width: context.spacing16),
                Expanded(
                  child: StatCard(
                    title: '已支出',
                    value: context.formatAmount(totalSpent),
                    valueColor: context.increaseColor,
                    icon: Icons.trending_up_outlined,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing16),

            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: '可用余额',
                    value: context.formatAmount(totalAvailable),
                    valueColor: context.decreaseColor,
                    icon: Icons.savings_outlined,
                  ),
                ),
                SizedBox(width: context.spacing16),
                Expanded(
                  child: StatCard(
                    title: '使用率',
                    value: totalAllocated > 0
                        ? context.formatPercentage(
                            (totalSpent / totalAllocated) * 100,
                          )
                        : '0%',
                    valueColor: totalSpent / totalAllocated > 0.8
                        ? context.increaseColor
                        : context.secondaryText,
                    icon: Icons.pie_chart_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  // 当前零基预算卡片
  Widget _buildCurrentZeroBasedCard(ZeroBasedBudget budget) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  color: context.primaryAction,
                  size: 20,
                ),
                SizedBox(width: context.spacing8),
                Text(
                  budget.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing8,
                    vertical: context.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: context.accentBackground,
                    borderRadius:
                        BorderRadius.circular(context.borderRadius / 2),
                  ),
                  child: Text(
                    budget.period.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.primaryAction,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing12),

            // 进度条
            LinearProgressIndicator(
              value: budget.allocationPercentage / 100,
              backgroundColor: context.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(context.primaryAction),
            ),
            SizedBox(height: context.spacing8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '分配进度',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.secondaryText,
                      ),
                ),
                Text(
                  '${budget.allocationPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            SizedBox(height: context.spacing12),

            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: '总收入',
                    value: context.formatAmount(budget.totalIncome),
                    valueColor: context.primaryText,
                  ),
                ),
                SizedBox(width: context.spacing16),
                Expanded(
                  child: StatCard(
                    title: '已分配',
                    value: context.formatAmount(budget.totalAllocated),
                    valueColor: context.primaryAction,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  // 信封列表标题
  Widget _buildEnvelopeListHeader() => Padding(
        padding: EdgeInsets.symmetric(horizontal: context.spacing4),
        child: Text(
          '信封预算',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      );

  // 信封卡片
  Widget _buildEnvelopeCard(EnvelopeBudget envelope) => AppCard(
        margin: EdgeInsets.only(bottom: context.spacing12),
        child: InkWell(
          onTap: () => _navigateToEnvelopeDetail(envelope),
          borderRadius: BorderRadius.circular(context.borderRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: envelope.color != null
                          ? Color(
                              int.parse(
                                envelope.color!.replaceFirst('#', '0xff'),
                              ),
                            )
                          : context.primaryAction,
                      borderRadius:
                          BorderRadius.circular(context.borderRadius / 2),
                    ),
                    child: Icon(
                      _getCategoryIcon(envelope.category),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: context.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          envelope.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          envelope.category.displayName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.secondaryText,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  _buildEnvelopeStatusChip(envelope),
                ],
              ),
              SizedBox(height: context.spacing12),

              // 进度条
              LinearProgressIndicator(
                value: envelope.usagePercentage / 100,
                backgroundColor: context.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(
                    int.parse(
                      _getBudgetStatusColor(envelope).replaceFirst('#', '0xff'),
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.spacing8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${envelope.usagePercentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '剩余 ${context.formatAmount(envelope.availableAmount)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.secondaryText,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  // 零基预算卡片
  Widget _buildZeroBasedCard(ZeroBasedBudget budget) => AppCard(
        margin: EdgeInsets.only(bottom: context.spacing12),
        child: InkWell(
          onTap: () => _navigateToZeroBasedDetail(budget),
          borderRadius: BorderRadius.circular(context.borderRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pie_chart_outline,
                    color: context.primaryAction,
                    size: 24,
                  ),
                  SizedBox(width: context.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          '${budget.period.displayName}预算',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.secondaryText,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing8,
                      vertical: context.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: budget.isFullyAllocated
                          ? context.decreaseColor.withOpacity(0.1)
                          : context.accentBackground,
                      borderRadius:
                          BorderRadius.circular(context.borderRadius / 2),
                    ),
                    child: Text(
                      budget.isFullyAllocated ? '已分配' : '进行中',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: budget.isFullyAllocated
                                ? context.decreaseColor
                                : context.primaryAction,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: '总收入',
                      value: context.formatAmount(budget.totalIncome),
                      valueColor: context.primaryText,
                    ),
                  ),
                  SizedBox(width: context.spacing16),
                  Expanded(
                    child: StatCard(
                      title: '已分配',
                      value: context.formatAmount(budget.totalAllocated),
                      valueColor: context.primaryAction,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  // 无预算卡片
  Widget _buildNoBudgetCard() => AppCard(
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: context.secondaryText,
            ),
            SizedBox(height: context.spacing16),
            Text(
              '还没有创建预算',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.spacing8),
            Text(
              '创建预算来更好地管理你的支出',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateBudgetOptions(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('创建预算'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: context.spacing12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.borderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  // 空状态
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) =>
      Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacing32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: context.secondaryText,
              ),
              SizedBox(height: context.spacing24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: context.spacing8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.secondaryText,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_circle_outline),
                label: Text(actionText),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing24,
                    vertical: context.spacing12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.borderRadius),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  // 信封状态标签
  Widget _buildEnvelopeStatusChip(EnvelopeBudget envelope) {
    String statusText;
    Color statusColor;

    if (envelope.isOverBudget) {
      statusText = '超支';
      statusColor = context.increaseColor;
    } else if (envelope.isWarningThresholdReached) {
      statusText = '警告';
      statusColor = context.warningColor;
    } else {
      statusText = '正常';
      statusColor = context.decreaseColor;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing8,
        vertical: context.spacing4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius / 2),
      ),
      child: Text(
        statusText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // 获取分类图标
  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Icons.restaurant_outlined;
      case TransactionCategory.transport:
        return Icons.directions_car_outlined;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TransactionCategory.entertainment:
        return Icons.movie_outlined;
      case TransactionCategory.healthcare:
        return Icons.local_hospital_outlined;
      case TransactionCategory.education:
        return Icons.school_outlined;
      case TransactionCategory.housing:
        return Icons.home_outlined;
      case TransactionCategory.utilities:
        return Icons.electrical_services_outlined;
      case TransactionCategory.insurance:
        return Icons.security_outlined;
      case TransactionCategory.investment:
        return Icons.trending_up_outlined;
      case TransactionCategory.salary:
        return Icons.work_outlined;
      case TransactionCategory.bonus:
        return Icons.card_giftcard_outlined;
      case TransactionCategory.freelance:
        return Icons.work_outline;
      case TransactionCategory.otherIncome:
        return Icons.attach_money_outlined;
      case TransactionCategory.otherExpense:
        return Icons.receipt_outlined;
      case TransactionCategory.gift:
        return Icons.card_giftcard_outlined;
    }
  }

  // 获取预算状态颜色
  String _getBudgetStatusColor(EnvelopeBudget envelope) {
    if (envelope.isOverBudget) return '#FF3B30';
    if (envelope.isWarningThresholdReached) return '#FF9500';
    return '#34C759';
  }

  // 显示创建预算选项
  void _showCreateBudgetOptions(BuildContext context) {
    AppAnimations.showAppModalBottomSheet(
      context: context,
      child: Container(
        padding: EdgeInsets.all(context.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '创建预算',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.spacing24),
            _buildCreateOption(
              icon: Icons.account_balance_wallet_outlined,
              title: '信封预算',
              subtitle: '为特定类别设定支出限额',
              onTap: () {
                Navigator.pop(context);
                _navigateToCreateBudget(BudgetType.envelope);
              },
            ),
            SizedBox(height: context.spacing16),
            _buildCreateOption(
              icon: Icons.pie_chart_outline,
              title: '零基预算',
              subtitle: '将收入分配到各个类别',
              onTap: () {
                Navigator.pop(context);
                _navigateToCreateBudget(BudgetType.zeroBased);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 创建选项
  Widget _buildCreateOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.borderRadius),
        child: Container(
          padding: EdgeInsets.all(context.spacing16),
          decoration: BoxDecoration(
            border: Border.all(color: context.dividerColor),
            borderRadius: BorderRadius.circular(context.borderRadius),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.primaryAction.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius / 2),
                ),
                child: Icon(
                  icon,
                  color: context.primaryAction,
                  size: 24,
                ),
              ),
              SizedBox(width: context.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.secondaryText,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: context.secondaryText,
                size: 16,
              ),
            ],
          ),
        ),
      );

  // 导航到创建预算页面
  void _navigateToCreateBudget(BudgetType type) {
    Navigator.of(context).push(
      AppAnimations.createRoute(
        CreateBudgetScreen(budgetType: type),
      ),
    );
  }

  // 工资收入标签页
  Widget _buildSalaryIncomeTab() => Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) => Scaffold(
          backgroundColor: context.primaryBackground,
          body: budgetProvider.salaryIncomes.isEmpty
              ? _buildEmptySalaryIncomeView(context)
              : _buildSalaryIncomeListView(context, budgetProvider),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToSalaryIncomeSetup(context),
            backgroundColor: context.primaryAction,
            child: const Icon(Icons.add),
          ),
        ),
      );

  // 空状态视图
  Widget _buildEmptySalaryIncomeView(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: context.secondaryText.withOpacity(0.5),
            ),
            SizedBox(height: context.spacing16),
            Text(
              '还没有设置工资收入',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: context.secondaryText,
                  ),
            ),
            SizedBox(height: context.spacing8),
            Text(
              '设置工资收入后，可以自动产生定期交易',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.secondaryText.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing24),
            ElevatedButton.icon(
              onPressed: () => _navigateToSalaryIncomeSetup(context),
              icon: const Icon(Icons.add),
              label: const Text('设置工资收入'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryAction,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );

  // 工资收入列表视图
  Widget _buildSalaryIncomeListView(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) =>
      ListView.builder(
        padding: EdgeInsets.all(context.spacing16),
        itemCount: budgetProvider.salaryIncomes.length,
        itemBuilder: (context, index) {
          final salaryIncome = budgetProvider.salaryIncomes[index];
          return AppCard(
            margin: EdgeInsets.only(bottom: context.spacing12),
            child: Padding(
              padding: EdgeInsets.all(context.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: context.primaryAction,
                      ),
                      SizedBox(width: context.spacing12),
                      Expanded(
                        child: Text(
                          salaryIncome.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleSalaryIncomeAction(
                          context,
                          salaryIncome,
                          value,
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'generate_transaction',
                            child: Text('生成本月交易'),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('编辑'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('删除'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: context.spacing12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '月基本工资',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: context.secondaryText,
                                  ),
                            ),
                            Text(
                              '¥${salaryIncome.getSalaryAtDate(DateTime.now()).toStringAsFixed(0)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '奖金项目',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: context.secondaryText,
                                  ),
                            ),
                            Text(
                              '${salaryIncome.bonuses.length}个',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (salaryIncome.bonuses.isNotEmpty) ...[
                    SizedBox(height: context.spacing12),
                    Text(
                      '奖金项目：',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.secondaryText,
                          ),
                    ),
                    SizedBox(height: context.spacing4),
                    Wrap(
                      spacing: context.spacing8,
                      runSpacing: context.spacing4,
                      children: salaryIncome.bonuses
                          .map(
                            (bonus) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.spacing8,
                                vertical: context.spacing4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${bonus.typeDisplayName}: ¥${bonus.calculateAnnualBonus(DateTime.now().year).toStringAsFixed(0)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );

  // 处理工资收入操作
  Future<void> _handleSalaryIncomeAction(
    BuildContext context,
    SalaryIncome salaryIncome,
    String action,
  ) async {
    switch (action) {
      case 'generate_transaction':
        await _generateMonthlyTransaction(context, salaryIncome);
      case 'edit':
        await _editSalaryIncome(context, salaryIncome);
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除工资收入"${salaryIncome.name}"吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Provider.of<BudgetProvider>(context, listen: false)
                      .deleteSalaryIncome(salaryIncome.id);
                  setState(() {}); // 刷新界面
                },
                child: const Text('删除'),
              ),
            ],
          ),
        );
    }
  }

  // 生成本月交易
  Future<void> _generateMonthlyTransaction(
    BuildContext context,
    SalaryIncome salaryIncome,
  ) async {
    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('正在生成交易记录...'),
            ],
          ),
        ),
      );

      // 获取当前月份
      final now = DateTime.now();
      final currentYear = now.year;
      final currentMonth = now.month;

      // 创建自动交易服务实例
      final autoTransactionService = await AutoTransactionService.getInstance();

      // 检查是否已有交易
      final hasTransaction =
          await autoTransactionService.hasTransactionForMonth(
        salaryIncome.id,
        currentYear,
        currentMonth,
      );

      if (hasTransaction) {
        Navigator.of(context).pop(); // 关闭加载对话框
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('提示'),
            content: const Text('本月交易已存在，无需重复生成'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
        return;
      }

      // 生成交易
      await autoTransactionService.generateMonthlySalaryTransaction(
        salaryIncome: salaryIncome,
        year: currentYear,
        month: currentMonth,
      );

      Navigator.of(context).pop(); // 关闭加载对话框

      // 显示成功提示
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('成功'),
          content: const Text('本月工资和奖金交易已成功生成！\n\n您可以在交易管理页面查看生成的交易记录。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // 关闭加载对话框
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('错误'),
          content: Text('生成交易失败：$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  // 编辑工资收入
  Future<void> _editSalaryIncome(
    BuildContext context,
    SalaryIncome salaryIncome,
  ) async {
    final result = await Navigator.of(context).push(
      AppAnimations.createRoute(
        SalaryIncomeSetupScreen(
          salaryIncomeToEdit: salaryIncome,
        ),
      ),
    );

    if (result == true) {
      setState(() {}); // 返回时刷新界面
    }
  }

  // 导航到工资收入设置页面
  void _navigateToSalaryIncomeSetup(BuildContext context) {
    Navigator.of(context)
        .push(
          AppAnimations.createRoute(
            const SalaryIncomeSetupScreen(),
          ),
        )
        .then((_) => setState(() {})); // 返回时刷新界面
  }

  // 导航到信封详情页面
  void _navigateToEnvelopeDetail(EnvelopeBudget envelope) {
    Navigator.of(context).push(
      AppAnimations.createRoute(
        EnvelopeBudgetDetailScreen(envelope: envelope),
      ),
    );
  }

  // 导航到零基预算详情页面
  void _navigateToZeroBasedDetail(ZeroBasedBudget budget) {
    // TODO: 实现零基预算详情页面
    // 静默处理，不显示提示框
  }
}
