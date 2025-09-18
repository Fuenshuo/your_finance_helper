import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/expense_plan.dart';
import 'package:your_finance_flutter/core/models/income_plan.dart';
import 'package:your_finance_flutter/core/providers/expense_plan_provider.dart';
import 'package:your_finance_flutter/core/providers/income_plan_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/create_expense_plan_screen.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/create_income_plan_screen.dart';

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
                        _buildPlanItem(
                          context,
                          title: '月薪收入计划',
                          subtitle: '每月25号发放，税后收入¥25,000',
                          type: '收入',
                          status: '活跃',
                          color: const Color(0xFF4CAF50),
                        ),
                        SizedBox(height: context.spacing12),
                        _buildPlanItem(
                          context,
                          title: '房贷还款计划',
                          subtitle: '每月15号还款，本息¥8,500',
                          type: '支出',
                          status: '活跃',
                          color: const Color(0xFFF44336),
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
      Container(
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
      Container(
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
                color: plan.status.color.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(context.responsiveSpacing12),
              ),
              child: Text(
                plan.status.displayName,
                style: context.textTheme.bodySmall?.copyWith(
                  color: plan.status.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
}
