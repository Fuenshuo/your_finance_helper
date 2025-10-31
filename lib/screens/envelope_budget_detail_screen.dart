import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/add_transaction_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/transaction_detail_screen.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

class EnvelopeBudgetDetailScreen extends StatefulWidget {
  const EnvelopeBudgetDetailScreen({
    required this.envelope,
    super.key,
  });
  final EnvelopeBudget envelope;

  @override
  State<EnvelopeBudgetDetailScreen> createState() =>
      _EnvelopeBudgetDetailScreenState();
}

class _EnvelopeBudgetDetailScreenState extends State<EnvelopeBudgetDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          title: Text(widget.envelope.name),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _editEnvelope,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showMoreOptions,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: context.primaryAction,
            unselectedLabelColor: context.secondaryText,
            indicatorColor: context.primaryAction,
            tabs: const [
              Tab(text: '概览'),
              Tab(text: '交易记录'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildTransactionsTab(),
          ],
        ),
      );

  // 概览标签页
  Widget _buildOverviewTab() => Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) => SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 预算状态卡片
              AppAnimations.animatedListItem(
                index: 0,
                child: _buildBudgetStatusCard(),
              ),
              SizedBox(height: context.spacing16),

              // 进度详情卡片
              AppAnimations.animatedListItem(
                index: 1,
                child: _buildProgressCard(),
              ),
              SizedBox(height: context.spacing16),

              // 时间信息卡片
              AppAnimations.animatedListItem(
                index: 2,
                child: _buildTimeInfoCard(),
              ),
              SizedBox(height: context.spacing16),

              // 设置信息卡片
              AppAnimations.animatedListItem(
                index: 3,
                child: _buildSettingsCard(),
              ),
              SizedBox(height: context.spacing16),

              // 操作按钮
              AppAnimations.animatedListItem(
                index: 4,
                child: _buildActionButtons(),
              ),
            ],
          ),
        ),
      );

  // 交易记录标签页
  Widget _buildTransactionsTab() => Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          final relatedTransactions = transactionProvider.transactions
              .where((t) => t.envelopeBudgetId == widget.envelope.id)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (relatedTransactions.isEmpty) {
            return _buildEmptyTransactions();
          }

          return ListView.builder(
            padding: EdgeInsets.all(context.spacing16),
            itemCount: relatedTransactions.length,
            itemBuilder: (context, index) => AppAnimations.animatedListItem(
              index: index,
              child: _buildTransactionCard(relatedTransactions[index]),
            ),
          );
        },
      );

  // 预算状态卡片
  Widget _buildBudgetStatusCard() {
    final envelope = widget.envelope;
    final statusColor = _getStatusColor(envelope);
    final statusText = _getStatusText(envelope);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: envelope.color != null
                      ? Color(
                          int.parse(envelope.color!.replaceFirst('#', '0xff')),
                        )
                      : context.primaryAction,
                  borderRadius: BorderRadius.circular(context.borderRadius / 2),
                ),
                child: Icon(
                  _getCategoryIcon(envelope.category),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: context.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      envelope.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      envelope.category.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.secondaryText,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing12,
                  vertical: context.spacing8,
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
              ),
            ],
          ),
          SizedBox(height: context.spacing16),

          // 金额信息
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: '预算金额',
                  value: context.formatAmount(envelope.allocatedAmount),
                  valueColor: context.primaryText,
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              SizedBox(width: context.spacing16),
              Expanded(
                child: StatCard(
                  title: '已支出',
                  value: context.formatAmount(envelope.spentAmount),
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
                  value: context.formatAmount(envelope.availableAmount),
                  valueColor: envelope.availableAmount >= 0
                      ? context.decreaseColor
                      : context.increaseColor,
                  icon: Icons.savings_outlined,
                ),
              ),
              SizedBox(width: context.spacing16),
              Expanded(
                child: StatCard(
                  title: '使用率',
                  value: '${envelope.usagePercentage.toStringAsFixed(1)}%',
                  valueColor: envelope.usagePercentage > 100
                      ? context.increaseColor
                      : envelope.usagePercentage > 80
                          ? context.warningColor
                          : context.decreaseColor,
                  icon: Icons.pie_chart_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 进度卡片
  Widget _buildProgressCard() {
    final envelope = widget.envelope;
    final progressValue = envelope.usagePercentage / 100;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '支出进度',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: context.spacing16),

          // 进度条
          LinearProgressIndicator(
            value: progressValue.clamp(0.0, 1.0),
            backgroundColor: context.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              envelope.usagePercentage > 100
                  ? context.increaseColor
                  : envelope.usagePercentage > 80
                      ? context.warningColor
                      : context.primaryAction,
            ),
            minHeight: 8,
          ),
          SizedBox(height: context.spacing12),

          // 进度详情
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已使用 ${context.formatAmount(envelope.spentAmount)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.secondaryText,
                    ),
              ),
              Text(
                '剩余 ${context.formatAmount(envelope.availableAmount)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: envelope.availableAmount >= 0
                          ? context.decreaseColor
                          : context.increaseColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: context.spacing16),

          // 阈值指示器
          if (envelope.warningThreshold != null ||
              envelope.limitThreshold != null) ...[
            Divider(color: context.dividerColor),
            SizedBox(height: context.spacing12),
            Text(
              '阈值设置',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(height: context.spacing8),
            Row(
              children: [
                if (envelope.warningThreshold != null) ...[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: context.warningColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: context.spacing8),
                  Text(
                    '警告阈值: ${envelope.warningThreshold!.toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (envelope.warningThreshold != null &&
                    envelope.limitThreshold != null)
                  SizedBox(width: context.spacing16),
                if (envelope.limitThreshold != null) ...[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: context.increaseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: context.spacing8),
                  Text(
                    '限制阈值: ${envelope.limitThreshold!.toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 时间信息卡片
  Widget _buildTimeInfoCard() {
    final envelope = widget.envelope;
    final remainingDays = envelope.remainingDays;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '时间信息',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: context.spacing16),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfoItem(
                  icon: Icons.calendar_today_outlined,
                  title: '开始日期',
                  value:
                      '${envelope.startDate.year}-${envelope.startDate.month.toString().padLeft(2, '0')}-${envelope.startDate.day.toString().padLeft(2, '0')}',
                ),
              ),
              SizedBox(width: context.spacing16),
              Expanded(
                child: _buildTimeInfoItem(
                  icon: Icons.event_outlined,
                  title: '结束日期',
                  value:
                      '${envelope.endDate.year}-${envelope.endDate.month.toString().padLeft(2, '0')}-${envelope.endDate.day.toString().padLeft(2, '0')}',
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing16),
          _buildTimeInfoItem(
            icon: Icons.schedule_outlined,
            title: '剩余时间',
            value: remainingDays > 0 ? '$remainingDays天' : '已结束',
            valueColor:
                remainingDays > 0 ? context.primaryText : context.secondaryText,
          ),
        ],
      ),
    );
  }

  // 设置信息卡片
  Widget _buildSettingsCard() {
    final envelope = widget.envelope;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '设置信息',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: context.spacing16),
          _buildSettingItem(
            icon: Icons.repeat_outlined,
            title: '预算周期',
            value: envelope.period.displayName,
          ),
          Divider(color: context.dividerColor),
          _buildSettingItem(
            icon: Icons.priority_high_outlined,
            title: '必需支出',
            value: envelope.isEssential ? '是' : '否',
            valueColor: envelope.isEssential
                ? context.warningColor
                : context.secondaryText,
          ),
          Divider(color: context.dividerColor),
          if (envelope.tags.isNotEmpty) ...[
            _buildSettingItem(
              icon: Icons.label_outline,
              title: '标签',
              value: envelope.tags.join(', '),
            ),
            Divider(color: context.dividerColor),
          ],
          _buildSettingItem(
            icon: Icons.update_outlined,
            title: '最后更新',
            value:
                '${envelope.updateDate.year}-${envelope.updateDate.month.toString().padLeft(2, '0')}-${envelope.updateDate.day.toString().padLeft(2, '0')}',
          ),
        ],
      ),
    );
  }

  // 操作按钮
  Widget _buildActionButtons() => AppCard(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addTransaction,
                icon: const Icon(Icons.add),
                label: const Text('添加交易'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: context.spacing12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.borderRadius),
                  ),
                ),
              ),
            ),
            SizedBox(height: context.spacing12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _editEnvelope,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('编辑'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: context.spacing12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(context.borderRadius),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.spacing12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _transferMoney,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('转账'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: context.spacing12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(context.borderRadius),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  // 空交易记录
  Widget _buildEmptyTransactions() => Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacing32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: context.secondaryText,
              ),
              SizedBox(height: context.spacing24),
              Text(
                '暂无交易记录',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: context.spacing8),
              Text(
                '开始记录支出，让预算管理更精准',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.secondaryText,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing24),
              ElevatedButton.icon(
                onPressed: _addTransaction,
                icon: const Icon(Icons.add),
                label: const Text('添加交易'),
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

  // 交易卡片
  Widget _buildTransactionCard(Transaction transaction) => AppCard(
        margin: EdgeInsets.only(bottom: context.spacing12),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.type == TransactionType.expense
                  ? context.increaseColor.withOpacity(0.1)
                  : context.decreaseColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius / 2),
            ),
            child: Icon(
              transaction.type == TransactionType.expense
                  ? Icons.trending_down_outlined
                  : Icons.trending_up_outlined,
              color: transaction.type == TransactionType.expense
                  ? context.increaseColor
                  : context.decreaseColor,
              size: 20,
            ),
          ),
          title: Text(
            transaction.description,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.secondaryText,
                    ),
              ),
              if (transaction.notes != null && transaction.notes!.isNotEmpty)
                Text(
                  transaction.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.secondaryText,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: Text(
            '${transaction.type == TransactionType.expense ? '-' : '+'}${context.formatAmount(transaction.amount)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: transaction.type == TransactionType.expense
                      ? context.increaseColor
                      : context.decreaseColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          onTap: () => _viewTransactionDetail(transaction),
        ),
      );

  // 时间信息项
  Widget _buildTimeInfoItem({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) =>
      Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: context.secondaryText,
          ),
          SizedBox(width: context.spacing8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.secondaryText,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: valueColor ?? context.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      );

  // 设置项
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: context.spacing8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: context.secondaryText,
            ),
            SizedBox(width: context.spacing12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? context.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      );

  // 获取状态颜色
  Color _getStatusColor(EnvelopeBudget envelope) {
    if (envelope.isOverBudget) return context.increaseColor;
    if (envelope.isWarningThresholdReached) return context.warningColor;
    return context.decreaseColor;
  }

  // 获取状态文本
  String _getStatusText(EnvelopeBudget envelope) {
    if (envelope.isOverBudget) return '超支';
    if (envelope.isWarningThresholdReached) return '警告';
    return '正常';
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

  // 添加交易
  void _addTransaction() {
    Navigator.of(context).push(
      AppAnimations.createRoute(
        const AddTransactionScreen(
          initialType: TransactionType.expense,
          // 预选当前信封预算
        ),
      ),
    );
  }

  // 编辑信封
  void _editEnvelope() {
    // TODO: 实现编辑信封功能
    // 静默处理，不显示提示框
  }

  // 转账
  void _transferMoney() {
    // TODO: 实现转账功能
    // 静默处理，不显示提示框
  }

  // 查看交易详情
  void _viewTransactionDetail(Transaction transaction) {
    Navigator.of(context).push(
      AppAnimations.createRoute(
        TransactionDetailScreen(transaction: transaction),
      ),
    );
  }

  // 显示更多选项
  void _showMoreOptions() {
    AppAnimations.showAppModalBottomSheet(
      context: context,
      child: Container(
        padding: EdgeInsets.all(context.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('编辑预算'),
              onTap: () {
                Navigator.pop(context);
                _editEnvelope();
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('转账'),
              onTap: () {
                Navigator.pop(context);
                _transferMoney();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('删除预算'),
              onTap: () {
                Navigator.pop(context);
                _deleteEnvelope();
              },
            ),
          ],
        ),
      ),
    );
  }

  // 删除信封
  void _deleteEnvelope() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除预算'),
        content: Text('确定要删除"${widget.envelope.name}"吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final budgetProvider =
                  Provider.of<BudgetProvider>(context, listen: false);
              await budgetProvider.deleteEnvelopeBudget(widget.envelope.id);
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(
              '删除',
              style: TextStyle(color: context.increaseColor),
            ),
          ),
        ],
      ),
    );
  }
}
