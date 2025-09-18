import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/add_transaction_screen.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({
    required this.transaction,
    super.key,
  });
  final Transaction transaction;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: const Text('交易详情'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editTransaction(context),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showMoreOptions(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTransactionCard(context),
              SizedBox(height: context.spacing16),
              _buildTransactionInfo(context),
              SizedBox(height: context.spacing16),
              _buildAccountInfo(context),
              if (transaction.envelopeBudgetId != null) ...[
                SizedBox(height: context.spacing16),
                _buildBudgetInfo(context),
              ],
              if (transaction.notes != null &&
                  transaction.notes!.isNotEmpty) ...[
                SizedBox(height: context.spacing16),
                _buildNotesCard(context),
              ],
              if (transaction.tags.isNotEmpty) ...[
                SizedBox(height: context.spacing16),
                _buildTagsCard(context),
              ],
              if (transaction.imagePath != null) ...[
                SizedBox(height: context.spacing16),
                _buildImageCard(context),
              ],
            ],
          ),
        ),
      );

  // 交易基本信息卡片
  Widget _buildTransactionCard(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.spacing12),
                  decoration: BoxDecoration(
                    color: _getTransactionColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: _getTransactionColor(context),
                    size: 24,
                  ),
                ),
                SizedBox(width: context.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: context.spacing4),
                      Text(
                        _getTransactionTypeText(),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.formatAmount(transaction.amount),
                      style: context.textTheme.titleLarge?.copyWith(
                        color: _getTransactionColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing4),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing8,
                        vertical: context.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: context.spacing16),
            Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: context.secondaryText,
                ),
                SizedBox(width: context.spacing8),
                Text(
                  context.formatDateTime(transaction.date),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.secondaryText,
                  ),
                ),
                const Spacer(),
                if (transaction.isRecurring) ...[
                  Icon(
                    Icons.repeat_outlined,
                    size: 16,
                    color: context.primaryAction,
                  ),
                  SizedBox(width: context.spacing4),
                  Text(
                    '周期性',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.primaryAction,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );

  // 交易详细信息
  Widget _buildTransactionInfo(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '交易信息',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.spacing16),
            _buildInfoRow(
              context,
              '交易类型',
              _getTransactionTypeText(),
              _getCategoryIcon(),
            ),
            _buildInfoRow(
              context,
              '分类',
              _getCategoryText(),
              _getCategoryIcon(),
            ),
            if (transaction.subCategory != null)
              _buildInfoRow(
                context,
                '子分类',
                transaction.subCategory!,
                Icons.category_outlined,
              ),
            _buildInfoRow(
              context,
              '金额',
              context.formatAmount(transaction.amount),
              Icons.attach_money_outlined,
            ),
            _buildInfoRow(
              context,
              '日期',
              context.formatDate(transaction.date),
              Icons.calendar_today_outlined,
            ),
            _buildInfoRow(
              context,
              '时间',
              context.formatTime(transaction.date),
              Icons.access_time_outlined,
            ),
            if (transaction.isRecurring)
              _buildInfoRow(
                context,
                '周期规则',
                transaction.recurringRule ?? '未设置',
                Icons.repeat_outlined,
              ),
          ],
        ),
      );

  // 账户信息
  Widget _buildAccountInfo(BuildContext context) => Consumer<AccountProvider>(
        builder: (context, accountProvider, child) {
          final fromAccount = accountProvider.accounts
              .where((a) => a.id == transaction.fromAccountId)
              .firstOrNull;
          final toAccount = transaction.toAccountId != null
              ? accountProvider.accounts
                  .where((a) => a.id == transaction.toAccountId)
                  .firstOrNull
              : null;

          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '账户信息',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.spacing16),
                if (fromAccount != null)
                  _buildAccountRow(
                    context,
                    '来源账户',
                    fromAccount.name,
                    fromAccount.type,
                    Icons.account_balance_wallet_outlined,
                  ),
                if (toAccount != null)
                  _buildAccountRow(
                    context,
                    '目标账户',
                    toAccount.name,
                    toAccount.type,
                    Icons.account_balance_outlined,
                  ),
              ],
            ),
          );
        },
      );

  // 预算信息
  Widget _buildBudgetInfo(BuildContext context) => Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          final budget = budgetProvider.envelopeBudgets
              .where((b) => b.id == transaction.envelopeBudgetId)
              .firstOrNull;

          if (budget == null) return const SizedBox.shrink();

          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '预算信息',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.spacing16),
                _buildInfoRow(
                  context,
                  '关联预算',
                  budget.name,
                  Icons.account_balance_wallet_outlined,
                ),
                _buildInfoRow(
                  context,
                  '预算金额',
                  context.formatAmount(budget.allocatedAmount),
                  Icons.attach_money_outlined,
                ),
                _buildInfoRow(
                  context,
                  '已花费',
                  context.formatAmount(budget.spentAmount),
                  Icons.shopping_cart_outlined,
                ),
                _buildInfoRow(
                  context,
                  '剩余金额',
                  context.formatAmount(
                    budget.allocatedAmount - budget.spentAmount,
                  ),
                  Icons.account_balance_wallet_outlined,
                ),
              ],
            ),
          );
        },
      );

  // 备注信息
  Widget _buildNotesCard(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '备注',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.spacing12),
            Text(
              transaction.notes!,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      );

  // 标签信息
  Widget _buildTagsCard(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '标签',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.spacing12),
            Wrap(
              spacing: context.spacing8,
              runSpacing: context.spacing8,
              children: transaction.tags
                  .map(
                    (tag) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing12,
                        vertical: context.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: context.primaryAction.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.primaryAction,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );

  // 图片信息
  Widget _buildImageCard(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '收据/发票',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.spacing12),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.borderColor,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  transaction.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: context.primaryBackground,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: context.secondaryText,
                        ),
                        SizedBox(height: context.spacing8),
                        Text(
                          '图片加载失败',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  // 信息行组件
  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) =>
      Padding(
        padding: EdgeInsets.only(bottom: context.spacing12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: context.secondaryText,
            ),
            SizedBox(width: context.spacing12),
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.secondaryText,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );

  // 账户行组件
  Widget _buildAccountRow(
    BuildContext context,
    String label,
    String accountName,
    AccountType accountType,
    IconData icon,
  ) =>
      Padding(
        padding: EdgeInsets.only(bottom: context.spacing12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: context.secondaryText,
            ),
            SizedBox(width: context.spacing12),
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.secondaryText,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Icon(
                    _getAccountTypeIcon(accountType),
                    size: 16,
                    color: context.primaryAction,
                  ),
                  SizedBox(width: context.spacing8),
                  Text(
                    accountName,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  // 获取交易颜色
  Color _getTransactionColor(BuildContext context) {
    switch (transaction.type) {
      case TransactionType.income:
        return context.increaseColor;
      case TransactionType.expense:
        return context.decreaseColor;
      case TransactionType.transfer:
        return context.primaryAction;
      default:
        return context.primaryAction; // 默认颜色
    }
  }

  // 获取状态颜色
  Color _getStatusColor(BuildContext context) {
    switch (transaction.status) {
      case TransactionStatus.confirmed:
        return context.successColor;
      case TransactionStatus.pending:
        return context.warningColor;
      case TransactionStatus.cancelled:
        return context.errorColor;
      case TransactionStatus.draft:
        return context.secondaryText;
    }
  }

  // 获取交易类型文本
  String _getTransactionTypeText() {
    switch (transaction.type) {
      case TransactionType.income:
        return '收入';
      case TransactionType.expense:
        return '支出';
      case TransactionType.transfer:
        return '转账';
      default:
        return '其他';
    }
  }

  // 获取状态文本
  String _getStatusText() {
    switch (transaction.status) {
      case TransactionStatus.confirmed:
        return '已确认';
      case TransactionStatus.pending:
        return '待确认';
      case TransactionStatus.cancelled:
        return '已取消';
      case TransactionStatus.draft:
        return '草稿';
    }
  }

  // 获取分类文本
  String _getCategoryText() {
    switch (transaction.category) {
      case TransactionCategory.food:
        return '餐饮';
      case TransactionCategory.transport:
        return '交通';
      case TransactionCategory.shopping:
        return '购物';
      case TransactionCategory.entertainment:
        return '娱乐';
      case TransactionCategory.healthcare:
        return '医疗';
      case TransactionCategory.education:
        return '教育';
      case TransactionCategory.housing:
        return '住房';
      case TransactionCategory.utilities:
        return '水电费';
      case TransactionCategory.insurance:
        return '保险';
      case TransactionCategory.investment:
        return '投资';
      case TransactionCategory.salary:
        return '工资';
      case TransactionCategory.bonus:
        return '奖金';
      case TransactionCategory.freelance:
        return '自由职业';
      case TransactionCategory.otherIncome:
        return '其他收入';
      case TransactionCategory.otherExpense:
        return '其他支出';
      case TransactionCategory.gift:
        return '礼品';
    }
  }

  // 获取分类图标
  IconData _getCategoryIcon() {
    switch (transaction.category) {
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

  // 获取账户类型图标
  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.account_balance_wallet_outlined;
      case AccountType.bank:
        return Icons.account_balance_outlined;
      case AccountType.creditCard:
        return Icons.credit_card_outlined;
      case AccountType.investment:
        return Icons.trending_up_outlined;
      case AccountType.loan:
        return Icons.account_balance_outlined;
      case AccountType.asset:
        return Icons.home_outlined;
      case AccountType.liability:
        return Icons.receipt_long_outlined;
    }
  }

  // 编辑交易
  void _editTransaction(BuildContext context) {
    Navigator.of(context).push(
      AppAnimations.createRoute(
        AddTransactionScreen(
          editingTransaction: transaction,
        ),
      ),
    );
  }

  // 显示更多选项
  void _showMoreOptions(BuildContext context) {
    AppAnimations.showAppModalBottomSheet(
      context: context,
      child: Container(
        padding: EdgeInsets.all(context.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('编辑交易'),
              onTap: () {
                Navigator.pop(context);
                _editTransaction(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('复制交易'),
              onTap: () {
                Navigator.pop(context);
                _copyTransaction(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('删除交易'),
              onTap: () {
                Navigator.pop(context);
                _deleteTransaction(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 复制交易
  void _copyTransaction(BuildContext context) {
    final copiedTransaction = transaction.copyWith(
      description: '${transaction.description} (副本)',
      date: DateTime.now(),
      status: TransactionStatus.draft,
    );

    Navigator.of(context).push(
      AppAnimations.createRoute(
        AddTransactionScreen(
          editingTransaction: copiedTransaction,
        ),
      ),
    );
  }

  // 删除交易
  void _deleteTransaction(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除交易'),
        content: const Text('确定要删除这笔交易吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<TransactionProvider>()
                  .deleteTransaction(transaction.id);
              Navigator.pop(context);
            },
            child: Text(
              '删除',
              style: TextStyle(color: context.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
