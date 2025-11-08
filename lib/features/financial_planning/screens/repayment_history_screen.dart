import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/expense_plan.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/expense_plan_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/swipe_action_item.dart';

/// 还款历史页面
class RepaymentHistoryScreen extends StatefulWidget {
  const RepaymentHistoryScreen({super.key});

  @override
  State<RepaymentHistoryScreen> createState() => _RepaymentHistoryScreenState();
}

class _RepaymentHistoryScreenState extends State<RepaymentHistoryScreen> {
  late final IOSAnimationSystem _animationSystem;

  @override
  void initState() {
    super.initState();

    // ===== v1.1.0 初始化企业级动效系统 =====
    _animationSystem = IOSAnimationSystem();

    // 注册还款历史专用动效曲线
    IOSAnimationSystem.registerCustomCurve('repayment-list-item', Curves.easeOutCubic);
    IOSAnimationSystem.registerCustomCurve('repayment-swipe-delete', Curves.elasticOut);
    IOSAnimationSystem.registerCustomCurve('repayment-progress-highlight', Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _animationSystem.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: Text(
            '还款历史',
            style: context.textTheme.headlineMedium,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Consumer3<ExpensePlanProvider, AccountProvider, TransactionProvider>(
          builder: (context, expensePlanProvider, accountProvider, transactionProvider, child) {
            final repaymentPlans = expensePlanProvider.getPendingRepaymentPlans();
            final repaymentTransactions = _getRepaymentTransactions(
              transactionProvider.transactions,
              repaymentPlans,
            );

            if (repaymentPlans.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                await expensePlanProvider.refresh();
                await accountProvider.refresh();
                await transactionProvider.refresh();
              },
              child: ListView(
                padding: EdgeInsets.all(context.responsiveSpacing16),
                children: [
                  // 统计概览
                  _buildStatisticsCard(context, repaymentPlans, repaymentTransactions),

                  SizedBox(height: context.spacing16),

                  // 各贷款还款历史
                  ...repaymentPlans.map((plan) => _buildLoanRepaymentHistory(
                    context,
                    plan,
                    accountProvider,
                    repaymentTransactions.where((t) => t.expensePlanId == plan.id).toList(),
                  )),
                ],
              ),
            );
          },
        ),
      );

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) => Center(
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
              '暂无还款记录',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.secondaryText,
              ),
            ),
            SizedBox(height: context.spacing8),
            Text(
              '创建还款支出计划后，还款记录将显示在这里',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing24),
            OutlinedButton.icon(
              onPressed: () {
                // 导航到创建支出计划页面
                Navigator.of(context).pushNamed('/financial-planning/create-expense');
              },
              icon: const Icon(Icons.add),
              label: const Text('创建还款计划'),
            ),
          ],
        ),
      );

  /// 构建统计卡片
  Widget _buildStatisticsCard(
    BuildContext context,
    List<ExpensePlan> repaymentPlans,
    List<Transaction> repaymentTransactions,
  ) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 还款统计',
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
                    label: '还款计划',
                    value: repaymentPlans.length.toString(),
                    icon: Icons.schedule,
                    color: const Color(0xFF2196F3),
                  ),
                ),
                SizedBox(width: context.spacing12),
                Expanded(
                  child: _buildStatItem(
                    context,
                    label: '已还款次',
                    value: repaymentTransactions.length.toString(),
                    icon: Icons.check_circle,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(width: context.spacing12),
                Expanded(
                  child: _buildStatItem(
                    context,
                    label: '累计金额',
                    value: '¥${_calculateTotalRepaymentAmount(repaymentTransactions).toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  /// 构建统计项
  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) => Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: context.spacing8),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: context.spacing4),
          Text(
            label,
            style: TextStyle(
              color: context.secondaryText,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );

  /// 构建贷款还款历史
  Widget _buildLoanRepaymentHistory(
    BuildContext context,
    ExpensePlan plan,
    AccountProvider accountProvider,
    List<Transaction> transactions,
  ) {
    final loanAccount = accountProvider.accounts
        .where((account) => account.id == plan.loanAccountId)
        .firstOrNull;

    final totalRepaid = transactions.fold<double>(0, (sum, t) => sum + t.amount);
    final remainingAmount = (loanAccount?.loanAmount ?? 0) - totalRepaid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== v1.1.0 添加动效包装 =====
        AppAnimations.animatedListItem(
          index: 0,
          child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (loanAccount != null)
                          Text(
                            loanAccount.name,
                            style: TextStyle(
                              color: context.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '¥${plan.amount.toStringAsFixed(0)}/${plan.frequency.displayName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      Text(
                        '已还: ¥${totalRepaid.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: context.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (loanAccount != null && loanAccount.loanAmount != null) ...[
                SizedBox(height: context.spacing12),
                LinearProgressIndicator(
                  value: totalRepaid / loanAccount.loanAmount!,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
                SizedBox(height: context.spacing4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '还款进度',
                      style: TextStyle(
                        color: context.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${(totalRepaid / loanAccount.loanAmount! * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: context.secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        ), // ===== v1.1.0 AppAnimations.animatedListItem结束 =====

        SizedBox(height: context.spacing12),

        // 还款记录列表
        if (transactions.isNotEmpty) ...[
          Text(
            '还款记录',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.spacing8),
          ...transactions.map(
            (transaction) => AppAnimations.animatedListItem(
              index: transactions.indexOf(transaction),
              child: _buildTransactionItem(context, transaction),
            ),
          ),
        ] else ...[
          AppCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(context.spacing16),
                child: Text(
                  '暂无还款记录',
                  style: TextStyle(
                    color: context.secondaryText,
                  ),
                ),
              ),
            ),
          ),
        ],

        SizedBox(height: context.spacing24),
      ],
    );
  }

  /// ===== v1.1.0 重构：构建交易项（支持滑动删除动效）=====
  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final transactionCard = AppCard(
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          SizedBox(width: context.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: context.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '¥${transaction.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );

    // ===== v1.1.0 使用新的滑动删除动效 =====
    return _animationSystem.iosSwipeableListItem(
      child: transactionCard,
      action: SwipeAction.delete(() => _deleteRepaymentTransaction(transaction)),
    );
  }

  /// 获取还款交易
  List<Transaction> _getRepaymentTransactions(
    List<Transaction> allTransactions,
    List<ExpensePlan> repaymentPlans,
  ) {
    final planIds = repaymentPlans.map((plan) => plan.id).toSet();
    return allTransactions
        .where((transaction) =>
            transaction.expensePlanId != null &&
            planIds.contains(transaction.expensePlanId))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // 按日期倒序
  }

  /// 计算总还款金额
  double _calculateTotalRepaymentAmount(List<Transaction> transactions) =>
      transactions.fold<double>(0, (sum, transaction) => sum + transaction.amount);

  // ===== v1.1.0 新增：删除还款交易 =====
  void _deleteRepaymentTransaction(Transaction transaction) {
    final transactionProvider = context.read<TransactionProvider>();

    // 显示删除成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已删除还款记录"${transaction.description}"'),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            // 这里可以实现撤销功能，但暂时先不实现
            // TODO: 实现撤销删除功能
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // 执行删除操作
    transactionProvider.deleteTransaction(transaction.id);
  }
}
