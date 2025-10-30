import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/expense_plan.dart';
import 'package:your_finance_flutter/core/models/income_plan.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/expense_plan_provider.dart';
import 'package:your_finance_flutter/core/providers/income_plan_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/create_expense_plan_screen.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/create_income_plan_screen.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/repayment_history_screen.dart';

/// 财务计划主页
class FinancialPlanningHomeScreen extends StatefulWidget {
  const FinancialPlanningHomeScreen({super.key});

  @override
  State<FinancialPlanningHomeScreen> createState() =>
      _FinancialPlanningHomeScreenState();
}

class _FinancialPlanningHomeScreenState
    extends State<FinancialPlanningHomeScreen> {
  @override
  Widget build(BuildContext context) =>
      Consumer2<IncomePlanProvider, ExpensePlanProvider>(
        builder: (context, incomePlanProvider, expensePlanProvider, child) =>
            Scaffold(
          backgroundColor: context.primaryBackground,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              '财务计划',
              style: context.textTheme.headlineMedium,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: _showCreatePlanDialog,
                icon: const Icon(Icons.add),
                tooltip: '新建计划',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(context.responsiveSpacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 模块介绍
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎯 财务计划',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing8),
                      Text(
                        '制定收入计划和支出计划，实现财务目标的智能管理',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing16),

                // 还款提醒
                Consumer2<ExpensePlanProvider, AccountProvider>(
                  builder:
                      (context, expensePlanProvider, accountProvider, child) {
                    final dueTodayPlans =
                        expensePlanProvider.getDueTodayPlans();
                    final upcomingPlans =
                        expensePlanProvider.getUpcomingDuePlans();

                    if (dueTodayPlans.isEmpty && upcomingPlans.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.alarm,
                                color: Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: context.spacing8),
                              Text(
                                '💰 还款提醒',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: context.spacing12),

                          // 到期提醒
                          if (dueTodayPlans.isNotEmpty) ...[
                            Text(
                              '今天到期的还款：',
                              style: TextStyle(
                                color: context.secondaryText,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: context.spacing8),
                            ...dueTodayPlans.map((plan) {
                              final loanAccount = accountProvider.accounts
                                  .where((account) =>
                                      account.id == plan.loanAccountId)
                                  .firstOrNull;

                              return Padding(
                                padding:
                                    EdgeInsets.only(bottom: context.spacing8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plan.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (loanAccount != null)
                                            Text(
                                              '关联账户: ${loanAccount.name}',
                                              style: TextStyle(
                                                color: context.secondaryText,
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '¥${plan.amount.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],

                          // 即将到期提醒
                          if (upcomingPlans.isNotEmpty) ...[
                            if (dueTodayPlans.isNotEmpty)
                              SizedBox(height: context.spacing12),
                            Text(
                              '即将到期的还款：',
                              style: TextStyle(
                                color: context.secondaryText,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: context.spacing8),
                            ...upcomingPlans.map((plan) {
                              final daysUntilDue = plan.startDate
                                  .difference(DateTime.now())
                                  .inDays;
                              final loanAccount = accountProvider.accounts
                                  .where((account) =>
                                      account.id == plan.loanAccountId)
                                  .firstOrNull;

                              return Padding(
                                padding:
                                    EdgeInsets.only(bottom: context.spacing8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plan.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (loanAccount != null)
                                            Text(
                                              '关联账户: ${loanAccount.name}',
                                              style: TextStyle(
                                                color: context.secondaryText,
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '¥${plan.amount.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '$daysUntilDue天后到期',
                                          style: TextStyle(
                                            color: context.secondaryText,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],

                          SizedBox(height: context.spacing12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // 导航到交易添加页面，预设为支出类型
                                    Navigator.of(context)
                                        .pushNamed('/transaction/add');
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('记录还款'),
                                ),
                              ),
                              SizedBox(width: context.spacing12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // 导航到还款历史页面
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RepaymentHistoryScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.history, size: 16),
                                  label: const Text('查看历史'),
                                ),
                              ),
                            ],
                          ),

                          // 收入计划自动执行区域
                          SizedBox(height: context.spacing16),
                          Consumer<IncomePlanProvider>(
                            builder: (context, incomePlanProvider, child) =>
                                AppCard(
                              child: Column(
                                children: [
                                  const Text('💰 收入计划自动执行'),
                                  const Text('自动根据工资计划生成收入交易'),
                                  SizedBox(height: context.spacing12),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      try {
                                        await incomePlanProvider
                                            .autoExecuteIncomePlans(
                                          Provider.of<TransactionProvider>(
                                              context,
                                              listen: false),
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text('收入计划执行完成')),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(content: Text('执行失败: $e')),
                                          );
                                        }
                                      }
                                    },
                                    icon:
                                        const Icon(Icons.play_arrow, size: 16),
                                    label: const Text('执行收入计划'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: context.spacing16),

                // 计划类型选择
                Row(
                  children: [
                    Expanded(
                      child: _buildPlanTypeCard(
                        context,
                        icon: Icons.trending_up,
                        title: '收入计划',
                        subtitle: '工资、投资等收入规划',
                        color: const Color(0xFF4CAF50),
                        onTap: () => _showIncomePlanOptions(context),
                      ),
                    ),
                    SizedBox(width: context.spacing12),
                    Expanded(
                      child: _buildPlanTypeCard(
                        context,
                        icon: Icons.trending_down,
                        title: '支出计划',
                        subtitle: '预算、还贷等支出规划',
                        color: const Color(0xFFF44336),
                        onTap: () => _showExpensePlanOptions(context),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.spacing24),

                // 现有计划列表
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '📋 我的计划',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${incomePlanProvider.activeIncomePlans.length + expensePlanProvider.activeExpensePlans.length}个活跃计划',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing16),

                      // 显示收入计划
                      if (incomePlanProvider.activeIncomePlans.isNotEmpty) ...[
                        Text(
                          '💰 收入计划',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                        SizedBox(height: context.spacing8),
                        ...incomePlanProvider.activeIncomePlans.map(
                          (plan) => Column(
                            children: [
                              _buildIncomePlanItem(context, plan),
                              SizedBox(height: context.spacing12),
                            ],
                          ),
                        ),
                      ],

                      // 显示支出计划
                      if (expensePlanProvider
                          .activeExpensePlans.isNotEmpty) ...[
                        if (incomePlanProvider.activeIncomePlans.isNotEmpty)
                          SizedBox(height: context.spacing16),
                        Text(
                          '💸 支出计划',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFF44336),
                          ),
                        ),
                        SizedBox(height: context.spacing8),
                        ...expensePlanProvider.activeExpensePlans.map(
                          (plan) => Column(
                            children: [
                              _buildExpensePlanItem(context, plan),
                              SizedBox(height: context.spacing12),
                            ],
                          ),
                        ),
                      ],

                      // 如果没有任何计划，显示示例
                      if (incomePlanProvider.activeIncomePlans.isEmpty &&
                          expensePlanProvider.activeExpensePlans.isEmpty) ...[
                        Text(
                          '💡 示例计划',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.secondaryText,
                          ),
                        ),
                        SizedBox(height: context.spacing8),
                        // 显示真实的收入计划
                        Consumer<IncomePlanProvider>(
                          builder: (context, incomePlanProvider, child) {
                            final activeIncomePlans =
                                incomePlanProvider.incomePlans
                                    .where((plan) => plan.isActive)
                                    .take(2) // 只显示前2个
                                    .toList();

                            if (activeIncomePlans.isEmpty) {
                              return _buildEmptyPlanItem(
                                context,
                                type: '收入',
                                message: '暂无收入计划',
                                actionText: '创建收入计划',
                                onAction: () =>
                                    _navigateToCreateIncomePlan(context),
                              );
                            }

                            return Column(
                              children: activeIncomePlans.map((plan) {
                                final frequencyText =
                                    plan.frequency.displayName;
                                return Column(
                                  children: [
                                    _buildPlanItem(
                                      context,
                                      title: plan.name,
                                      subtitle:
                                          '$frequencyText发放，预计¥${plan.amount.toStringAsFixed(0)}',
                                      type: '收入',
                                      status: plan.isActive ? '活跃' : '暂停',
                                      color: const Color(0xFF4CAF50),
                                    ),
                                    if (activeIncomePlans.length > 1 &&
                                        activeIncomePlans.indexOf(plan) <
                                            activeIncomePlans.length - 1)
                                      SizedBox(height: context.spacing12),
                                  ],
                                );
                              }).toList(),
                            );
                          },
                        ),

                        SizedBox(height: context.spacing12),

                        // 显示真实的支出计划
                        Consumer<ExpensePlanProvider>(
                          builder: (context, expensePlanProvider, child) {
                            final activeExpensePlans = expensePlanProvider
                                .expensePlans
                                .where(
                                  (plan) =>
                                      plan.status == ExpensePlanStatus.active,
                                )
                                .take(2) // 只显示前2个
                                .toList();

                            if (activeExpensePlans.isEmpty) {
                              return _buildEmptyPlanItem(
                                context,
                                type: '支出',
                                message: '暂无支出计划',
                                actionText: '创建支出计划',
                                onAction: () =>
                                    _navigateToCreateExpensePlan(context),
                              );
                            }

                            return Column(
                              children: activeExpensePlans.map((plan) {
                                final frequencyText =
                                    plan.frequency.displayName;
                                return _buildPlanItem(
                                  context,
                                  title: plan.name,
                                  subtitle:
                                      '$frequencyText支出，预算¥${plan.amount.toStringAsFixed(0)}',
                                  type: '支出',
                                  status:
                                      plan.status == ExpensePlanStatus.active
                                          ? '活跃'
                                          : '暂停',
                                  color: const Color(0xFFF44336),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: context.spacing24),

                // 计划统计
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📊 计划执行统计',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              context,
                              label: '月收入计划',
                              value:
                                  '¥${incomePlanProvider.getMonthlyIncomeTotal(DateTime.now().year, DateTime.now().month).toStringAsFixed(0)}',
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                          SizedBox(width: context.spacing12),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              label: '年收入计划',
                              value:
                                  '¥${incomePlanProvider.getYearlyIncomeTotal(DateTime.now().year).toStringAsFixed(0)}',
                              color: const Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              context,
                              label: '活跃计划',
                              value:
                                  '${incomePlanProvider.activeIncomePlans.length + expensePlanProvider.activeExpensePlans.length}个',
                              color: const Color(0xFFFF9800),
                            ),
                          ),
                          SizedBox(width: context.spacing12),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              label: '月支出计划',
                              value:
                                  '¥${expensePlanProvider.getMonthlyExpenseTotal(DateTime.now().year, DateTime.now().month).toStringAsFixed(0)}',
                              color: const Color(0xFFF44336),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildPlanTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.responsiveSpacing12),
        child: AppCard(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(context.responsiveSpacing16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              SizedBox(height: context.spacing12),
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.spacing4),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.secondaryText,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );

  Widget _buildPlanItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String type,
    required String status,
    required Color color,
  }) =>
      Container(
        padding: EdgeInsets.all(context.responsiveSpacing12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(context.responsiveSpacing8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: context.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: context.spacing2),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSpacing8,
                vertical: context.spacing4,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(context.responsiveSpacing12),
              ),
              child: Text(
                status,
                style: context.textTheme.bodySmall?.copyWith(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) =>
      Container(
        padding: EdgeInsets.all(context.responsiveSpacing12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(context.responsiveSpacing8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: context.textTheme.titleMedium?.copyWith(
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Color _getStatusColor(String status) {
    switch (status) {
      case '活跃':
        return const Color(0xFF4CAF50);
      case '正常':
        return const Color(0xFFFF9800);
      case '暂停':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF2196F3);
    }
  }

  void _showCreatePlanDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '新建财务计划',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing16),

            // 计划类型选项
            Row(
              children: [
                Expanded(
                  child: _buildDialogOption(
                    context,
                    icon: Icons.trending_up,
                    title: '收入计划',
                    subtitle: '工资、投资等收入',
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showIncomePlanOptions(context);
                    },
                  ),
                ),
                SizedBox(width: context.spacing12),
                Expanded(
                  child: _buildDialogOption(
                    context,
                    icon: Icons.trending_down,
                    title: '支出计划',
                    subtitle: '预算、还贷等支出',
                    color: const Color(0xFFF44336),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showExpensePlanOptions(context);
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: context.spacing16),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.responsiveSpacing12),
        child: Container(
          padding: EdgeInsets.all(context.responsiveSpacing16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(context.responsiveSpacing12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: context.spacing8),
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.spacing4),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _buildIncomePlanItem(BuildContext context, IncomePlan plan) =>
      _IOSLongPressEffect(
        onLongPress: () => _showIncomePlanActionMenu(context, plan),
        child: Container(
          padding: EdgeInsets.all(context.responsiveSpacing12),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.05),
            borderRadius: BorderRadius.circular(context.responsiveSpacing8),
            border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: context.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.name,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (plan.isDetailedSalary)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.responsiveSpacing8,
                              vertical: context.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                context.responsiveSpacing12,
                              ),
                            ),
                            child: Text(
                              '详细工资',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF2196F3),
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: context.spacing2),
                    Text(
                      '${plan.frequency.displayName} ¥${plan.amount.toStringAsFixed(2)} · 下次执行：${plan.nextExecutionDate != null ? _formatDate(plan.nextExecutionDate!) : '未设置'}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSpacing8,
                  vertical: context.spacing4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(context.responsiveSpacing12),
                ),
                child: Text(
                  '活跃',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  void _showIncomePlanOptions(BuildContext context) {
    Navigator.of(context).push(
      AppAnimations.createRoute(
        const CreateIncomePlanScreen(),
      ),
    );
  }

  void _showExpensePlanOptions(BuildContext context) {
    Navigator.of(context).push(
      AppAnimations.createRoute(
        const CreateExpensePlanScreen(),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.month}月${date.day}日';

  Widget _buildExpensePlanItem(BuildContext context, ExpensePlan plan) =>
      _IOSLongPressEffect(
        onLongPress: () => _showExpensePlanActionMenu(context, plan),
        child: Container(
          padding: EdgeInsets.all(context.responsiveSpacing12),
          decoration: BoxDecoration(
            color: const Color(0xFFF44336).withOpacity(0.05),
            borderRadius: BorderRadius.circular(context.responsiveSpacing8),
            border: Border.all(color: const Color(0xFFF44336).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFF44336),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: context.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: context.spacing2),
                    Text(
                      '¥${plan.amount.toStringAsFixed(0)} (${plan.frequency.displayName}) • ${plan.type.displayName}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSpacing8,
                  vertical: context.spacing4,
                ),
                decoration: BoxDecoration(
                  color:
                      _getExpensePlanStatusColor(plan.status).withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(context.responsiveSpacing12),
                ),
                child: Text(
                  _getExpensePlanStatusDisplayName(plan.status),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: _getExpensePlanStatusColor(plan.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildEmptyPlanItem(
    BuildContext context, {
    required String type,
    required String message,
    required String actionText,
    required VoidCallback onAction,
  }) =>
      Container(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(context.responsiveSpacing8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              type == '收入' ? Icons.trending_up : Icons.trending_down,
              color: Colors.grey.shade400,
              size: 32,
            ),
            SizedBox(height: context.spacing8),
            Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: context.spacing12),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionText),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: type == '收入'
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                ),
                foregroundColor: type == '收入'
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
              ),
            ),
          ],
        ),
      );

  String _getFrequencyText(String frequency) {
    switch (frequency) {
      case 'daily':
        return '每日';
      case 'weekly':
        return '每周';
      case 'monthly':
        return '每月';
      case 'quarterly':
        return '每季度';
      case 'yearly':
        return '每年';
      default:
        return frequency;
    }
  }

  void _navigateToCreateIncomePlan(BuildContext context) {
    Navigator.of(context).push(
      AppAnimations.createRoute(const CreateIncomePlanScreen()),
    );
  }

  void _navigateToCreateExpensePlan(BuildContext context) {
    Navigator.of(context).push(
      AppAnimations.createRoute(const CreateExpensePlanScreen()),
    );
  }

  Color _getExpensePlanStatusColor(ExpensePlanStatus status) {
    switch (status) {
      case ExpensePlanStatus.active:
        return Colors.green;
      case ExpensePlanStatus.paused:
        return Colors.orange;
      case ExpensePlanStatus.completed:
        return Colors.blue;
      case ExpensePlanStatus.cancelled:
        return Colors.red;
    }
  }

  String _getExpensePlanStatusDisplayName(ExpensePlanStatus status) {
    switch (status) {
      case ExpensePlanStatus.active:
        return '活跃';
      case ExpensePlanStatus.paused:
        return '暂停';
      case ExpensePlanStatus.completed:
        return '完成';
      case ExpensePlanStatus.cancelled:
        return '取消';
    }
  }

  /// 显示收入计划操作菜单
  void _showIncomePlanActionMenu(BuildContext context, IncomePlan plan) {
    AppAnimations.showAppModalBottomSheet(
      context: context,
      child: Container(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '收入计划操作',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing16),
            _buildPlanOptionItem(
              context,
              icon: Icons.edit,
              title: '编辑计划',
              onTap: () => _editIncomePlan(context, plan),
            ),
            _buildPlanOptionItem(
              context,
              icon: Icons.delete,
              title: '删除计划',
              color: Colors.red,
              onTap: () => _deleteIncomePlan(context, plan),
            ),
            SizedBox(height: context.spacing8),
            _buildPlanOptionItem(
              context,
              icon: Icons.cancel,
              title: '取消',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示支出计划操作菜单
  void _showExpensePlanActionMenu(BuildContext context, ExpensePlan plan) {
    AppAnimations.showAppModalBottomSheet(
      context: context,
      child: Container(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '支出计划操作',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing16),
            _buildPlanOptionItem(
              context,
              icon: Icons.edit,
              title: '编辑计划',
              onTap: () => _editExpensePlan(context, plan),
            ),
            _buildPlanOptionItem(
              context,
              icon: Icons.delete,
              title: '删除计划',
              color: Colors.red,
              onTap: () => _deleteExpensePlan(context, plan),
            ),
            SizedBox(height: context.spacing8),
            _buildPlanOptionItem(
              context,
              icon: Icons.cancel,
              title: '取消',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建选项菜单项
  Widget _buildPlanOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.responsiveSpacing8),
        child: Container(
          padding: EdgeInsets.all(context.responsiveSpacing12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color ?? context.primaryAction,
              ),
              SizedBox(width: context.spacing12),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: color ?? context.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  /// 编辑收入计划
  void _editIncomePlan(BuildContext context, IncomePlan plan) {
    Navigator.of(context).pop(); // 关闭选项菜单
    Navigator.of(context).push(
      AppAnimations.createRoute(
        CreateIncomePlanScreen(editPlan: plan),
      ),
    );
  }

  /// 编辑支出计划
  void _editExpensePlan(BuildContext context, ExpensePlan plan) {
    Navigator.of(context).pop(); // 关闭选项菜单
    Navigator.of(context).push(
      AppAnimations.createRoute(
        CreateExpensePlanScreen(editPlan: plan),
      ),
    );
  }

  /// 删除收入计划
  void _deleteIncomePlan(BuildContext context, IncomePlan plan) {
    Navigator.of(context).pop(); // 关闭选项菜单
    _showDeleteConfirmationDialog(
      context,
      title: '删除收入计划',
      message: '确定要删除收入计划"${plan.name}"吗？此操作无法撤销。',
      onConfirm: () async {
        try {
          await context.read<IncomePlanProvider>().deleteIncomePlan(plan.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('收入计划已删除')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('删除失败: $e')),
            );
          }
        }
      },
    );
  }

  /// 删除支出计划
  void _deleteExpensePlan(BuildContext context, ExpensePlan plan) {
    Navigator.of(context).pop(); // 关闭选项菜单
    _showDeleteConfirmationDialog(
      context,
      title: '删除支出计划',
      message: '确定要删除支出计划"${plan.name}"吗？此操作无法撤销。',
      onConfirm: () async {
        try {
          await context.read<ExpensePlanProvider>().deleteExpensePlan(plan.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('支出计划已删除')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('删除失败: $e')),
            );
          }
        }
      },
    );
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
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
}

/// iOS风格长按动效组件
/// 基于iOS动效系统，使用缩放动画提供原生iOS体验
class _IOSLongPressEffect extends StatefulWidget {
  const _IOSLongPressEffect({
    required this.child,
    this.onLongPress,
    this.scaleFactor = 0.95,
  });
  final Widget child;
  final VoidCallback? onLongPress;
  final double scaleFactor;

  @override
  State<_IOSLongPressEffect> createState() => _IOSLongPressEffectState();
}

class _IOSLongPressEffectState extends State<_IOSLongPressEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _controller.forward();
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _controller.reverse();

    // 延迟执行长按回调，给动效一点时间
    Future.delayed(const Duration(milliseconds: 50), () {
      widget.onLongPress?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onLongPressStart: _handleLongPressStart,
        onLongPressEnd: _handleLongPressEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        ),
      );
}
