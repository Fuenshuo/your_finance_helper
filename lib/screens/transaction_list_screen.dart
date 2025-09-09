import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/models/account.dart';
import 'package:your_finance_flutter/models/transaction.dart';
import 'package:your_finance_flutter/providers/account_provider.dart';
import 'package:your_finance_flutter/providers/transaction_provider.dart';
import 'package:your_finance_flutter/screens/transaction_detail_screen.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _searchController = TextEditingController();
  TransactionType? _filterType;
  TransactionCategory? _filterCategory;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterAccountId;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Consumer2<TransactionProvider, AccountProvider>(
        builder: (context, transactionProvider, accountProvider, child) {
          final allTransactions = transactionProvider.transactions
              .where((t) => t.status == TransactionStatus.confirmed)
              .toList();

          final filteredTransactions = _filterTransactions(allTransactions);
          final groupedTransactions =
              _groupTransactionsByDate(filteredTransactions);

          return Column(
            children: [
              // 搜索和筛选栏
              _buildSearchAndFilterBar(),

              // 交易列表
              Expanded(
                child: filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.all(context.spacing16),
                        itemCount: groupedTransactions.length,
                        itemBuilder: (context, index) {
                          final entry =
                              groupedTransactions.entries.elementAt(index);
                          final date = entry.key;
                          final transactions = entry.value;

                          return _buildDateGroup(
                            date,
                            transactions,
                            accountProvider.accounts,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      );

  // 搜索和筛选栏
  Widget _buildSearchAndFilterBar() => Container(
        padding: EdgeInsets.all(context.spacing16),
        color: Colors.white,
        child: Column(
          children: [
            // 搜索框
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索交易...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.spacing16,
                  vertical: context.spacing12,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),

            SizedBox(height: context.spacing12),

            // 筛选按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _showFilters = !_showFilters),
                    icon: const Icon(Icons.filter_list),
                    label: const Text('筛选'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.spacing12),
                if (_hasActiveFilters())
                  OutlinedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear),
                    label: const Text('清除'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.withOpacity(0.3)),
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),

            // 筛选选项
            if (_showFilters) ...[
              SizedBox(height: context.spacing16),
              _buildFilterOptions(),
            ],
          ],
        ),
      );

  // 筛选选项
  Widget _buildFilterOptions() => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '筛选条件',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.spacing16),

            // 交易类型筛选
            _buildFilterChips(
              '交易类型',
              TransactionType.values,
              _filterType,
              (type) => setState(
                () => _filterType = _filterType == type ? null : type,
              ),
              (type) => type.displayName,
            ),

            SizedBox(height: context.spacing12),

            // 分类筛选
            _buildFilterChips(
              '分类',
              TransactionCategory.values,
              _filterCategory,
              (category) => setState(
                () => _filterCategory =
                    _filterCategory == category ? null : category,
              ),
              (category) => category.displayName,
            ),

            SizedBox(height: context.spacing16),

            // 日期范围
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(true),
                    child: Container(
                      padding: EdgeInsets.all(context.spacing12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          SizedBox(width: context.spacing8),
                          Text(
                            _filterStartDate != null
                                ? DateFormat('MM-dd').format(_filterStartDate!)
                                : '开始日期',
                            style: TextStyle(
                              color: _filterStartDate != null
                                  ? context.primaryText
                                  : context.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.spacing8),
                const Text('至'),
                SizedBox(width: context.spacing8),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(false),
                    child: Container(
                      padding: EdgeInsets.all(context.spacing12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          SizedBox(width: context.spacing8),
                          Text(
                            _filterEndDate != null
                                ? DateFormat('MM-dd').format(_filterEndDate!)
                                : '结束日期',
                            style: TextStyle(
                              color: _filterEndDate != null
                                  ? context.primaryText
                                  : context.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  // 筛选标签
  Widget _buildFilterChips<T>(
    String title,
    List<T> options,
    T? selectedValue,
    Function(T) onTap,
    String Function(T) displayText,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.spacing8),
          Wrap(
            spacing: context.spacing8,
            children: options.map((option) {
              final isSelected = selectedValue == option;
              return FilterChip(
                label: Text(displayText(option)),
                selected: isSelected,
                onSelected: (_) => onTap(option),
                selectedColor: context.primaryAction.withOpacity(0.2),
                checkmarkColor: context.primaryAction,
              );
            }).toList(),
          ),
        ],
      );

  // 构建日期分组
  Widget _buildDateGroup(
    String date,
    List<Transaction> transactions,
    List<Account> accounts,
  ) {
    final totalAmount = transactions.fold(0.0, (sum, t) => sum + t.amount);

    return AppCard(
      margin: EdgeInsets.only(bottom: context.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                context.formatAmount(totalAmount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.primaryAction,
                    ),
              ),
            ],
          ),
          SizedBox(height: context.spacing12),

          // 交易列表
          ...transactions.map(
            (transaction) => _buildTransactionItem(transaction, accounts),
          ),
        ],
      ),
    );
  }

  // 构建交易项
  Widget _buildTransactionItem(
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

    return InkWell(
      onTap: () => _viewTransactionDetail(transaction),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.spacing8),
        child: Row(
          children: [
            // 图标
            CircleAvatar(
              radius: 20,
              backgroundColor:
                  _getTransactionTypeColor(transaction.type).withOpacity(0.1),
              child: Icon(
                _getCategoryIcon(transaction.category),
                size: 20,
                color: _getTransactionTypeColor(transaction.type),
              ),
            ),
            SizedBox(width: context.spacing12),

            // 交易信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: context.spacing4),
                  Row(
                    children: [
                      Text(
                        account.name,
                        style: TextStyle(
                          color: context.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      if (transaction.category !=
                          TransactionCategory.otherExpense) ...[
                        Text(
                          ' • ${transaction.category.displayName}',
                          style: TextStyle(
                            color: context.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // 金额
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.formatAmount(transaction.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _getTransactionTypeColor(transaction.type),
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(transaction.date),
                  style: TextStyle(
                    color: context.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 空状态
  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: context.spacing16),
            Text(
              _hasActiveFilters() ? '没有找到匹配的交易' : '暂无交易记录',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: context.spacing8),
            Text(
              _hasActiveFilters() ? '尝试调整筛选条件' : '点击右上角添加第一笔交易',
              style: TextStyle(
                color: context.secondaryText,
              ),
            ),
          ],
        ),
      );

  // 筛选交易
  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    var filtered = transactions;

    // 搜索筛选
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (t) =>
                t.description.toLowerCase().contains(searchText) ||
                t.notes?.toLowerCase().contains(searchText) == true,
          )
          .toList();
    }

    // 类型筛选
    if (_filterType != null) {
      filtered = filtered.where((t) => t.type == _filterType).toList();
    }

    // 分类筛选
    if (_filterCategory != null) {
      filtered = filtered.where((t) => t.category == _filterCategory).toList();
    }

    // 日期筛选
    if (_filterStartDate != null) {
      filtered = filtered
          .where(
            (t) =>
                t.date.isAfter(_filterStartDate!) ||
                t.date.isAtSameMomentAs(_filterStartDate!),
          )
          .toList();
    }
    if (_filterEndDate != null) {
      filtered = filtered
          .where(
            (t) =>
                t.date.isBefore(_filterEndDate!.add(const Duration(days: 1))),
          )
          .toList();
    }

    // 账户筛选
    if (_filterAccountId != null) {
      filtered = filtered
          .where(
            (t) =>
                t.fromAccountId == _filterAccountId ||
                t.toAccountId == _filterAccountId,
          )
          .toList();
    }

    return filtered;
  }

  // 按日期分组交易
  Map<String, List<Transaction>> _groupTransactionsByDate(
    List<Transaction> transactions,
  ) {
    final grouped = <String, List<Transaction>>{};

    for (final transaction in transactions) {
      final dateKey = DateFormat('yyyy年MM月dd日').format(transaction.date);
      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }

    // 按日期排序
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Map.fromEntries(sortedEntries);
  }

  // 检查是否有活跃的筛选条件
  bool _hasActiveFilters() =>
      _filterType != null ||
      _filterCategory != null ||
      _filterStartDate != null ||
      _filterEndDate != null ||
      _filterAccountId != null;

  // 清除筛选条件
  void _clearFilters() {
    setState(() {
      _filterType = null;
      _filterCategory = null;
      _filterStartDate = null;
      _filterEndDate = null;
      _filterAccountId = null;
    });
  }

  // 选择日期
  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_filterStartDate ??
              DateTime.now().subtract(const Duration(days: 30)))
          : (_filterEndDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _filterStartDate = date;
          // 如果开始日期晚于结束日期，清除结束日期
          if (_filterEndDate != null && date.isAfter(_filterEndDate!)) {
            _filterEndDate = null;
          }
        } else {
          _filterEndDate = date;
          // 如果结束日期早于开始日期，清除开始日期
          if (_filterStartDate != null && date.isBefore(_filterStartDate!)) {
            _filterStartDate = null;
          }
        }
      });
    }
  }

  // 编辑交易
  void _viewTransactionDetail(Transaction transaction) {
    Navigator.of(context).push(
      AppAnimations.createRoute(
        TransactionDetailScreen(transaction: transaction),
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
}
