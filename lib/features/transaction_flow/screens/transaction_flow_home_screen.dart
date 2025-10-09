import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/notification_manager.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/add_transaction_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/transaction_detail_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/transaction_records_screen.dart';

/// 交易流水主页
class TransactionFlowHomeScreen extends StatefulWidget {
  const TransactionFlowHomeScreen({super.key});

  @override
  State<TransactionFlowHomeScreen> createState() =>
      _TransactionFlowHomeScreenState();
}

class _TransactionFlowHomeScreenState extends State<TransactionFlowHomeScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '交易流水',
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _showAddTransactionDialog,
              icon: const Icon(Icons.add),
              tooltip: '添加交易',
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
                      '💳 交易流水',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing8),
                    Text(
                      '查看所有交易记录，与财务计划智能关联，掌握资金流动情况',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing16),

              // 本月统计
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📊 本月统计',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${DateTime.now().year}年${DateTime.now().month}月',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing16),
                    // 本月统计数据
                    Consumer<TransactionProvider>(
                      builder: (context, transactionProvider, child) {
                        // 获取本月交易数据
                        final now = DateTime.now();
                        final startOfMonth = DateTime(now.year, now.month);
                        final monthTransactions = transactionProvider
                            .transactions
                            .where(
                              (t) =>
                                  t.status != TransactionStatus.draft &&
                                  (t.date.isAfter(startOfMonth) ||
                                      t.date.isAtSameMomentAs(startOfMonth)),
                            )
                            .toList();

                        // 计算本月统计
                        double totalIncome = 0;
                        double totalExpense = 0;
                        var incomeCount = 0;
                        var expenseCount = 0;

                        for (final transaction in monthTransactions) {
                          // 跳过自动生成的交易（比如账户初始化）
                          if (transaction.isAutoGenerated == true) {
                            continue;
                          }

                          if (transaction.type == TransactionType.income ||
                              (transaction.type == null &&
                                  transaction.category.isIncome)) {
                            totalIncome += transaction.amount;
                            incomeCount++;
                          } else {
                            totalExpense += transaction.amount;
                            expenseCount++;
                          }
                        }

                        final balance = totalIncome - totalExpense;
                        final balanceColor = balance >= 0
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336);
                        final balanceText = balance >= 0
                            ? '+¥${balance.toStringAsFixed(0)}'
                            : '-¥${(-balance).toStringAsFixed(0)}';

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMonthStat(
                                    context,
                                    label: '收入',
                                    amount:
                                        '+¥${totalIncome.toStringAsFixed(0)}',
                                    count: '$incomeCount笔',
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ),
                                SizedBox(width: context.spacing12),
                                Expanded(
                                  child: _buildMonthStat(
                                    context,
                                    label: '支出',
                                    amount:
                                        '-¥${totalExpense.toStringAsFixed(0)}',
                                    count: '$expenseCount笔',
                                    color: const Color(0xFFF44336),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.spacing12),
                            Container(
                              padding:
                                  EdgeInsets.all(context.responsiveSpacing12),
                              decoration: BoxDecoration(
                                color: balanceColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  context.responsiveSpacing8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    balance >= 0
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: balanceColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: context.spacing8),
                                  Expanded(
                                    child: Text(
                                      '本月结余：$balanceText',
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: balanceColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing16),

              // 快速操作
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.receipt_long_outlined,
                      title: '交易记录',
                      subtitle: '查看所有交易',
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        Navigator.of(context).push(
                          AppAnimations.createRoute(
                            const TransactionRecordsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: context.spacing12),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.search,
                      title: '交易搜索',
                      subtitle: '查找特定交易',
                      color: const Color(0xFFFF9800),
                      onTap: () {
                        // TODO: 导航到交易搜索页面
                        NotificationManager().showDevelopmentHint(
                          context,
                          '交易搜索',
                          additionalInfo: '智能搜索和筛选功能即将上线',
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.spacing24),

              // 最近交易
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🕒 最近交易',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                // 导航到完整交易记录页面
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) =>
                                        const TransactionRecordsScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                '查看全部',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing16),

                    // 最近交易记录
                    Consumer<TransactionProvider>(
                      builder: (context, transactionProvider, child) {
                        final recentTransactions = transactionProvider
                            .transactions
                            .where((t) => t.status != TransactionStatus.draft)
                            .toList()
                          ..sort((a, b) => b.date.compareTo(a.date));

                        final displayTransactions =
                            recentTransactions.take(4).toList();

                        if (displayTransactions.isEmpty) {
                          // 显示友好的示例提示
                          return Column(
                            children: [
                              _buildSampleTransactionItem(
                                context,
                                title: '开始记录您的第一笔交易',
                                subtitle: '点击右上角添加按钮开始记账',
                                amount: '+¥0.00',
                                time: '现在',
                                type: 'income',
                                isPlaceholder: true,
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: displayTransactions.map((transaction) {
                            final accountName = _getAccountName(
                              transaction.fromAccountId ?? '',
                            );
                            final categoryName =
                                transaction.category.displayName;
                            final timeStr =
                                _formatTransactionTime(transaction.date);
                            final amountStr =
                                _formatTransactionAmount(transaction);

                            return Column(
                              children: [
                                _buildRealTransactionItem(
                                  context,
                                  transaction: transaction,
                                  title: transaction.description,
                                  subtitle: '$accountName · $categoryName',
                                  amount: amountStr,
                                  time: timeStr,
                                  type: transaction.type?.name ?? 'unknown',
                                  isAuto: false, // TODO: 根据交易来源判断是否自动生成
                                ),
                                if (displayTransactions.last != transaction)
                                  SizedBox(height: context.spacing12),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing24),

              // 智能建议
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 智能建议',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing16),
                    Container(
                      padding: EdgeInsets.all(context.responsiveSpacing12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(context.responsiveSpacing8),
                        border: Border.all(
                          color: const Color(0xFF2196F3).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFF2196F3),
                            size: 24,
                          ),
                          SizedBox(width: context.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '重复交易提醒',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: context.spacing4),
                                Text(
                                  '检测到您连续2个月在同一家超市消费，建议创建定期支出计划',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // TODO: 创建支出计划
                            },
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildMonthStat(
    BuildContext context, {
    required String label,
    required String amount,
    required String count,
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
              amount,
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
            ),
            SizedBox(height: context.spacing2),
            Text(
              count,
              style: context.textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );

  Widget _buildQuickActionCard(
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
                padding: EdgeInsets.all(context.responsiveSpacing12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              SizedBox(height: context.spacing8),
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing2),
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

  void _showAddTransactionDialog() {
    // 导航到添加交易页面
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const AddTransactionScreen(),
      ),
    );
  }

  /// 获取账户名称
  String _getAccountName(String accountId) {
    try {
      final accountProvider = context.read<AccountProvider>();
      final account = accountProvider.accounts.firstWhere(
        (acc) => acc.id == accountId,
        orElse: () => throw StateError('Account not found: $accountId'),
      );
      return account.name;
    } catch (e) {
      // 如果获取失败，返回账户ID的前8位
      return accountId.length > 8 ? accountId.substring(0, 8) : accountId;
    }
  }

  /// 格式化交易时间
  String _formatTransactionTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (transactionDate == today.subtract(const Duration(days: 1))) {
      return '昨天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (transactionDate == today.subtract(const Duration(days: 2))) {
      return '前天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  /// 格式化交易金额
  String _formatTransactionAmount(Transaction transaction) {
    final prefix = transaction.type == TransactionType.income ? '+' : '-';
    final amount = transaction.amount.toStringAsFixed(2);
    return '$prefix¥$amount';
  }

  /// 构建真正的交易项
  Widget _buildRealTransactionItem(
    BuildContext context, {
    required Transaction transaction,
    required String title,
    required String subtitle,
    required String amount,
    required String time,
    required String type,
    required bool isAuto,
  }) {
    final isIncome = transaction.type == TransactionType.income ||
        (transaction.type == null && transaction.category.isIncome);
    final amountColor = isIncome ? context.successColor : context.errorColor;
    final typeIcon = isIncome ? Icons.trending_up : Icons.trending_down;
    final typeIconColor = isIncome ? context.successColor : context.errorColor;

    return InkWell(
      onTap: () {
        // 导航到交易详情页面
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) =>
                TransactionDetailScreen(transaction: transaction),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(context.spacing16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.dividerColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // 交易图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeIconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                typeIcon,
                color: typeIconColor,
                size: 20,
              ),
            ),

            SizedBox(width: context.spacing12),

            // 交易信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAuto)
                        Container(
                          margin: EdgeInsets.only(left: context.spacing8),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.responsiveSpacing6,
                            vertical: context.spacing2,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '自动',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.primaryColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: context.spacing4),
                  Text(
                    subtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.spacing4),
                  Text(
                    time,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // 金额
            Text(
              amount,
              style: context.textTheme.bodyLarge?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建示例交易项
  Widget _buildSampleTransactionItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
    required String time,
    required String type,
    required bool isPlaceholder,
  }) {
    final isIncome = type == 'income';
    final amountColor = isPlaceholder
        ? Colors.grey.shade400
        : (isIncome ? context.successColor : context.errorColor);
    final typeIcon = isPlaceholder
        ? Icons.add_circle_outline
        : (isIncome ? Icons.trending_up : Icons.trending_down);
    final typeIconColor = isPlaceholder
        ? Colors.grey.shade400
        : (isIncome ? context.successColor : context.errorColor);

    return InkWell(
      onTap: isPlaceholder ? _showAddTransactionDialog : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(context.spacing16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPlaceholder
                ? Colors.grey.shade200
                : context.dividerColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // 交易图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeIconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                typeIcon,
                color: typeIconColor,
                size: 20,
              ),
            ),

            SizedBox(width: context.spacing12),

            // 交易信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isPlaceholder ? Colors.grey.shade600 : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.spacing4),
                  Text(
                    subtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isPlaceholder
                          ? Colors.grey.shade500
                          : context.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.spacing4),
                  Text(
                    time,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isPlaceholder
                          ? Colors.grey.shade400
                          : context.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // 金额
            Text(
              amount,
              style: context.textTheme.bodyLarge?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
