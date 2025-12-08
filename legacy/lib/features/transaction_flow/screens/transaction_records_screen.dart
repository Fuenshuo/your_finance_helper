import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/swipe_action_item.dart';

/// 交易记录页面
class TransactionRecordsScreen extends StatefulWidget {
  const TransactionRecordsScreen({super.key});

  @override
  State<TransactionRecordsScreen> createState() =>
      _TransactionRecordsScreenState();
}

class _TransactionRecordsScreenState extends State<TransactionRecordsScreen> {
  String _selectedFilter = 'all'; // all, income, expense
  String _selectedTimeRange = 'month'; // week, month, quarter, year
  String _searchText = '';
  bool _isBulkSelectMode = false;
  final Set<String> _selectedTransactionIds = {};
  bool _showFilters = false;

  final IOSAnimationSystem _animationSystem = IOSAnimationSystem();
  final List<String> _filters = ['all', 'income', 'expense'];
  final List<String> _timeRanges = ['week', 'month', 'quarter', 'year'];

  @override
  void initState() {
    super.initState();

    // ===== v1.1.0 初始化企业级动效系统 =====
    IOSAnimationSystem.registerCustomCurve('transaction-list-item', Curves.easeOutCubic);
    IOSAnimationSystem.registerCustomCurve('search-result-highlight', Curves.easeInOutCubic);
    IOSAnimationSystem.registerCustomCurve('bulk-select-feedback', Curves.bounceOut);
    IOSAnimationSystem.registerCustomCurve('swipe-delete-feedback', Curves.elasticOut);
    IOSAnimationSystem.registerCustomCurve('filter-expand-animation', Curves.fastOutSlowIn);
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
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '交易记录',
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
          actions: [
            if (_isBulkSelectMode) ...[
              // 批量删除按钮
              IconButton(
                onPressed: _selectedTransactionIds.isNotEmpty ? _deleteSelectedTransactions : null,
                icon: const Icon(Icons.delete_forever),
                tooltip: '删除选中的交易',
                color: Colors.red,
              ),
              // 导出按钮
              IconButton(
                onPressed: _selectedTransactionIds.isNotEmpty ? _exportSelectedTransactions : null,
                icon: const Icon(Icons.share),
                tooltip: '导出选中的交易',
              ),
            ] else ...[
              // 多选按钮
              IconButton(
                onPressed: _toggleBulkSelectMode,
                icon: const Icon(Icons.checklist),
                tooltip: '批量选择',
              ),
              // 搜索按钮
              IconButton(
                onPressed: _showSearchDialog,
                icon: const Icon(Icons.search),
                tooltip: '搜索交易',
              ),
              // 筛选按钮
              IconButton(
                onPressed: _toggleFilters,
                icon: const Icon(Icons.filter_list),
                tooltip: '筛选',
              ),
            ],
          ],
        ),
        body: Column(
          children: [
            // 搜索栏
            _buildSearchAndFilterBar(),

            // 统计摘要
            _buildSummaryBar(),

            // 交易列表
            Expanded(
              child: _buildTransactionList(),
            ),
          ],
        ),
      );

  Widget _buildSearchAndFilterBar() => Column(
        children: [
          // 搜索栏
          Container(
            padding: EdgeInsets.all(context.responsiveSpacing16),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索交易描述、金额...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.responsiveSpacing12),
                  borderSide: BorderSide(color: context.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.responsiveSpacing12),
                  borderSide: BorderSide(color: context.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.responsiveSpacing12),
                  borderSide: BorderSide(color: context.primaryColor, width: 2),
                ),
                filled: true,
                fillColor: context.surfaceColor,
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),

          // 多选模式栏
          if (_isBulkSelectMode) _buildBulkActionBar(),

          // 筛选选项（带展开动画）
          _animationSystem.iosFilterExpandCollapse(
            isExpanded: _showFilters,
            child: Container(
              padding: EdgeInsets.all(context.responsiveSpacing16),
              color: context.surfaceColor,
              child: Column(
                children: [
                  Row(
                    children: [
                      // 类型筛选
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _filters
                              .map(
                                (filter) => DropdownMenuItem(
                                  value: filter,
                                  child: Text(
                                    _getFilterDisplayName(filter),
                                    style: context.textTheme.bodyMedium,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value ?? 'all';
                            });
                          },
                        ),
                      ),

                      SizedBox(width: context.spacing16),

                      // 时间范围筛选
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedTimeRange,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _timeRanges
                              .map(
                                (range) => DropdownMenuItem(
                                  value: range,
                                  child: Text(
                                    _getTimeRangeDisplayName(range),
                                    style: context.textTheme.bodyMedium,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTimeRange = value ?? 'month';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildBulkActionBar() => Container(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        color: context.primaryColor.withOpacity(0.1),
        child: Row(
          children: [
            Text(
              '已选择 ${_selectedTransactionIds.length} 项',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _clearSelection,
              child: const Text('取消选择'),
            ),
          ],
        ),
      );

  Widget _buildSummaryBar() => Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          // 获取当前筛选条件下的交易数据
          final allTransactions = transactionProvider.transactions
              .where((t) => t.status != TransactionStatus.draft)
              .toList();

          final filteredByTime =
              _filterTransactionsByTimeRange(allTransactions);
          final filteredTransactions =
              _filterTransactionsByType(filteredByTime);

          // 计算统计数据
          double totalIncome = 0;
          double totalExpense = 0;
          var incomeCount = 0;
          var expenseCount = 0;

          for (final transaction in filteredTransactions) {
            // 跳过自动生成的交易（比如账户初始化）
            if (transaction.isAutoGenerated == true) {
              continue;
            }

            if (transaction.type == TransactionType.income ||
                (transaction.type == null && transaction.category.isIncome)) {
              totalIncome += transaction.amount;
              incomeCount++;
            } else {
              totalExpense += transaction.amount;
              expenseCount++;
            }
          }

          final balance = totalIncome - totalExpense;

          return Container(
            padding: EdgeInsets.all(context.responsiveSpacing16),
            color: context.surfaceColor,
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    label: '收入',
                    amount: '+¥${totalIncome.toStringAsFixed(0)}',
                    count: '$incomeCount笔',
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(width: context.spacing12),
                Expanded(
                  child: _buildSummaryItem(
                    label: '支出',
                    amount: '-¥${totalExpense.toStringAsFixed(0)}',
                    count: '$expenseCount笔',
                    color: const Color(0xFFF44336),
                  ),
                ),
                SizedBox(width: context.spacing12),
                Expanded(
                  child: _buildSummaryItem(
                    label: '结余',
                    amount:
                        '${balance >= 0 ? '+' : ''}¥${balance.toStringAsFixed(0)}',
                    count: balance >= 0 ? '净收入' : '净支出',
                    color: balance >= 0
                        ? const Color(0xFF2196F3)
                        : const Color(0xFFF44336),
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget _buildSummaryItem({
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
              style: context.textTheme.bodyMedium?.copyWith(
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
                fontSize: 10,
              ),
            ),
          ],
        ),
      );

  Widget _buildTransactionList() => Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          // 获取并筛选交易数据
          final allTransactions = transactionProvider.transactions
              .where((t) => t.status != TransactionStatus.draft)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          // 按时间范围筛选
          final filteredByTime =
              _filterTransactionsByTimeRange(allTransactions);

          // 按类型筛选
          final filteredByType =
              _filterTransactionsByType(filteredByTime);

          // 按搜索文本筛选
          final filteredTransactions = _filterTransactionsBySearch(filteredByType);

          if (filteredTransactions.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: context.spacing32),
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
                    SizedBox(height: context.spacing8),
                    Text(
                      _searchText.isNotEmpty
                          ? '没有找到匹配的交易记录'
                          : '开始记录您的第一笔交易吧',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(context.responsiveSpacing16),
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) =>
                _buildTransactionItem(filteredTransactions[index]),
          );
        },
      );

  /// 按时间范围筛选交易
  List<Transaction> _filterTransactionsByTimeRange(
    List<Transaction> transactions,
  ) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedTimeRange) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
      case 'month':
        startDate = DateTime(now.year, now.month);
      case 'quarter':
        final quarter = ((now.month - 1) ~/ 3) + 1;
        startDate = DateTime(now.year, (quarter - 1) * 3 + 1);
      case 'year':
        startDate = DateTime(now.year);
      default:
        return transactions;
    }

    return transactions
        .where(
          (transaction) =>
              transaction.date.isAfter(startDate) ||
              transaction.date.isAtSameMomentAs(startDate),
        )
        .toList();
  }

  /// 按类型筛选交易
  List<Transaction> _filterTransactionsByType(List<Transaction> transactions) {
    switch (_selectedFilter) {
      case 'income':
        return transactions
            .where((transaction) => transaction.type == TransactionType.income)
            .toList();
      case 'expense':
        return transactions
            .where((transaction) => transaction.type == TransactionType.expense)
            .toList();
      case 'all':
      default:
        return transactions;
    }
  }

  /// 按搜索文本筛选交易
  List<Transaction> _filterTransactionsBySearch(List<Transaction> transactions) {
    if (_searchText.isEmpty) {
      return transactions;
    }

    final searchLower = _searchText.toLowerCase();
    return transactions.where((transaction) {
      final description = transaction.description.toLowerCase();
      final amount = transaction.amount.toString();
      final accountName = _getAccountName(transaction.fromAccountId ?? '').toLowerCase();
      final categoryName = transaction.category.displayName.toLowerCase();

      return description.contains(searchLower) ||
             amount.contains(searchLower) ||
             accountName.contains(searchLower) ||
             categoryName.contains(searchLower);
    }).toList();
  }

  /// 构建交易项（支持批量选择、搜索高亮和滑动删除）
  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income ||
        (transaction.type == null && transaction.category.isIncome);
    final accountName = _getAccountName(transaction.fromAccountId ?? '');
    final categoryName = transaction.category.displayName;
    final timeStr = _formatTransactionTime(transaction.date);
    final amountStr = _formatTransactionAmount(transaction);

    // 检查是否匹配搜索
    final isHighlighted = _searchText.isNotEmpty &&
        (transaction.description.toLowerCase().contains(_searchText.toLowerCase()) ||
         transaction.amount.toString().contains(_searchText) ||
         accountName.toLowerCase().contains(_searchText.toLowerCase()) ||
         categoryName.toLowerCase().contains(_searchText.toLowerCase()));

    // 滑动删除动作
    final swipeAction = SwipeAction(
      icon: Icons.delete,
      label: '删除',
      backgroundColor: Colors.red,
      iconColor: Colors.white,
      onTap: () => _deleteTransaction(transaction),
    );

    return _animationSystem.iosSwipeableListItem(
      child: Container(
        margin: EdgeInsets.only(bottom: context.spacing8),
        padding: EdgeInsets.all(context.responsiveSpacing12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.responsiveSpacing8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 批量选择复选框
            if (_isBulkSelectMode)
              _animationSystem.iosBulkSelectBounce(
                isSelected: _selectedTransactionIds.contains(transaction.id),
                child: Checkbox(
                  value: _selectedTransactionIds.contains(transaction.id),
                  onChanged: (value) => _toggleTransactionSelection(transaction.id),
                  activeColor: context.primaryColor,
                ),
              ),

            // 交易图标
            Container(
              padding: EdgeInsets.all(context.responsiveSpacing8),
              decoration: BoxDecoration(
                color: (isIncome ? context.successColor : context.errorColor)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncome ? Icons.trending_up : Icons.trending_down,
                color: isIncome ? context.successColor : context.errorColor,
                size: 20,
              ),
            ),

            SizedBox(width: context.spacing12),

            // 交易信息（带搜索高亮）
            Expanded(
              child: _animationSystem.iosSearchHighlight(
                isHighlighted: isHighlighted,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _isBulkSelectMode
                                ? () => _toggleTransactionSelection(transaction.id)
                                : () => _showTransactionDetail(transaction),
                            child: Text(
                              transaction.description,
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing2),
                    Text(
                      '$accountName · $categoryName',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: context.spacing12),

            // 金额和时间
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountStr,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isIncome ? context.successColor : context.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: context.spacing2),
                Text(
                  timeStr,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      action: swipeAction,
      onTap: _isBulkSelectMode
          ? () => _toggleTransactionSelection(transaction.id)
          : () => _showTransactionDetail(transaction),
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
    } else if (date.year == now.year) {
      // 今年内的交易，只显示月日
      return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      // 往年交易，显示年月日
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  /// 格式化交易金额
  String _formatTransactionAmount(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income ||
        (transaction.type == null && transaction.category.isIncome);
    final prefix = isIncome ? '+' : '-';
    final amount = transaction.amount.toStringAsFixed(2);
    return '$prefix¥$amount';
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return '全部交易';
      case 'income':
        return '收入';
      case 'expense':
        return '支出';
      default:
        return filter;
    }
  }

  String _getTimeRangeDisplayName(String range) {
    switch (range) {
      case 'week':
        return '本周';
      case 'month':
        return '本月';
      case 'quarter':
        return '本季度';
      case 'year':
        return '今年';
      default:
        return range;
    }
  }

  void _showSearchDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索交易'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: '输入交易名称或金额',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            // TODO: 实现搜索逻辑
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 执行搜索
              Navigator.of(context).pop();
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '筛选条件',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing16),

            // TODO: 添加更多筛选选项
            const Text('更多筛选功能即将上线'),

            SizedBox(height: context.spacing16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(Transaction transaction) {
    final accountName = _getAccountName(transaction.fromAccountId ?? '');
    final categoryName = transaction.category.displayName;
    final timeStr = _formatTransactionTime(transaction.date);
    final amountStr = _formatTransactionAmount(transaction);

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '交易详情',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing16),
            _buildDetailRow('交易描述', transaction.description),
            _buildDetailRow('交易账户', accountName),
            _buildDetailRow('交易分类', categoryName),
            _buildDetailRow('交易金额', amountStr),
            _buildDetailRow('交易时间', timeStr),
            // TODO: 如果需要显示自动生成标记，可以在这里添加
            // if (transaction.isAutoGenerated) ...[
            //   SizedBox(height: context.spacing12),
            //   Container(
            //     padding: EdgeInsets.all(context.responsiveSpacing8),
            //     decoration: BoxDecoration(
            //       color: const Color(0xFF2196F3).withOpacity(0.1),
            //       borderRadius:
            //           BorderRadius.circular(context.responsiveSpacing8),
            //     ),
            //     child: Row(
            //       children: [
            //         const Icon(
            //           Icons.auto_mode,
            //           color: Color(0xFF2196F3),
            //           size: 16,
            //         ),
            //         SizedBox(width: context.spacing8),
            //         Text(
            //           '此交易由财务计划自动生成',
            //           style: context.textTheme.bodySmall?.copyWith(
            //             color: const Color(0xFF2196F3),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],
            SizedBox(height: context.spacing24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('关闭'),
                  ),
                ),
                SizedBox(width: context.spacing12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 编辑交易
                      Navigator.of(context).pop();
                    },
                    child: const Text('编辑'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) => Padding(
        padding: EdgeInsets.only(bottom: context.spacing12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.secondaryText,
              ),
            ),
            Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  // ===== 新的交互方法 =====

  /// 切换批量选择模式
  void _toggleBulkSelectMode() {
    setState(() {
      _isBulkSelectMode = !_isBulkSelectMode;
      if (!_isBulkSelectMode) {
        _selectedTransactionIds.clear();
      }
    });
  }

  /// 切换筛选展开状态
  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  /// 切换交易选择状态
  void _toggleTransactionSelection(String transactionId) {
    setState(() {
      if (_selectedTransactionIds.contains(transactionId)) {
        _selectedTransactionIds.remove(transactionId);
      } else {
        _selectedTransactionIds.add(transactionId);
      }
    });
  }

  /// 清除选择
  void _clearSelection() {
    setState(() {
      _selectedTransactionIds.clear();
      _isBulkSelectMode = false;
    });
  }

  /// 清除搜索
  void _clearSearch() {
    setState(() {
      _searchText = '';
    });
  }

  /// 删除单笔交易
  void _deleteTransaction(Transaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除交易"${transaction.description}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final transactionProvider = context.read<TransactionProvider>();
        await transactionProvider.deleteTransaction(transaction.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('交易已删除')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }

  /// 删除选中的交易
  void _deleteSelectedTransactions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${_selectedTransactionIds.length} 笔交易吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final transactionProvider = context.read<TransactionProvider>();
        for (final transactionId in _selectedTransactionIds) {
          await transactionProvider.deleteTransaction(transactionId);
        }

        setState(() {
          _selectedTransactionIds.clear();
          _isBulkSelectMode = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已删除 ${_selectedTransactionIds.length} 笔交易')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }

  /// 导出选中的交易
  void _exportSelectedTransactions() {
    // TODO: 实现导出功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出功能即将上线')),
    );
  }
}
