import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/models/budget.dart';
import 'package:your_finance_flutter/models/transaction.dart';
import 'package:your_finance_flutter/providers/account_provider.dart';
import 'package:your_finance_flutter/providers/budget_provider.dart';
import 'package:your_finance_flutter/screens/create_budget_screen.dart';
import 'package:your_finance_flutter/screens/envelope_budget_detail_screen.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

class BudgetManagementScreen extends StatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  State<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                            (totalSpent / totalAllocated) * 100)
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
                          ? Color(int.parse(
                              envelope.color!.replaceFirst('#', '0xff')))
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
                  Color(int.parse(_getBudgetStatusColor(envelope)
                      .replaceFirst('#', '0xff'))),
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
