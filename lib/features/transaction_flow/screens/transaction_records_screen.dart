import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';

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

  final List<String> _filters = ['all', 'income', 'expense'];
  final List<String> _timeRanges = ['week', 'month', 'quarter', 'year'];

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
            IconButton(
              onPressed: _showSearchDialog,
              icon: const Icon(Icons.search),
              tooltip: '搜索交易',
            ),
            IconButton(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.filter_list),
              tooltip: '筛选',
            ),
          ],
        ),
        body: Column(
          children: [
            // 筛选栏
            _buildFilterBar(),

            // 统计摘要
            _buildSummaryBar(),

            // 交易列表
            Expanded(
              child: _buildTransactionList(),
            ),
          ],
        ),
      );

  Widget _buildFilterBar() => Container(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        color: Colors.white,
        child: Row(
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
      );

  Widget _buildSummaryBar() => Container(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        color: context.surfaceColor,
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                label: '收入',
                amount: '+¥25,000',
                count: '12笔',
                color: const Color(0xFF4CAF50),
              ),
            ),
            SizedBox(width: context.spacing12),
            Expanded(
              child: _buildSummaryItem(
                label: '支出',
                amount: '-¥18,500',
                count: '28笔',
                color: const Color(0xFFF44336),
              ),
            ),
            SizedBox(width: context.spacing12),
            Expanded(
              child: _buildSummaryItem(
                label: '结余',
                amount: '+¥6,500',
                count: '净收入',
                color: const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
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

  Widget _buildTransactionList() => ListView.builder(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        itemCount: 20, // 示例数据
        itemBuilder: (context, index) => _buildTransactionItem(index),
      );

  Widget _buildTransactionItem(int index) {
    // 模拟不同类型的交易
    final isIncome = index % 3 == 0;
    final isAuto = index % 4 == 0;

    final transaction = _getMockTransaction(index, isIncome, isAuto);

    return Container(
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
      child: InkWell(
        onTap: () => _showTransactionDetail(transaction),
        borderRadius: BorderRadius.circular(context.responsiveSpacing8),
        child: Row(
          children: [
            // 交易图标
            Container(
              padding: EdgeInsets.all(context.responsiveSpacing8),
              decoration: BoxDecoration(
                color: (transaction['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                transaction['icon'] as IconData,
                color: transaction['color'] as Color,
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
                          transaction['title'] as String,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isAuto)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.responsiveSpacing6,
                            vertical: context.spacing2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              context.responsiveSpacing8,
                            ),
                          ),
                          child: Text(
                            '自动',
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
                    transaction['subtitle'] as String,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: context.spacing12),

            // 金额和时间
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction['amount'] as String,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: transaction['color'] as Color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: context.spacing2),
                Text(
                  transaction['time'] as String,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getMockTransaction(
    int index,
    bool isIncome,
    bool isAuto,
  ) {
    final transactions = [
      {
        'title': '工资收入',
        'subtitle': '中国银行 · 工资',
        'amount': '+¥25,000.00',
        'time': '今天 09:30',
        'color': const Color(0xFF4CAF50),
        'icon': Icons.trending_up,
        'isAuto': true,
      },
      {
        'title': '房贷还款',
        'subtitle': '中国银行 → 房贷账户',
        'amount': '-¥8,500.00',
        'time': '昨天 15:00',
        'color': const Color(0xFFF44336),
        'icon': Icons.home,
        'isAuto': true,
      },
      {
        'title': '超市购物',
        'subtitle': '微信支付',
        'amount': '-¥156.80',
        'time': '昨天 12:30',
        'color': const Color(0xFFF44336),
        'icon': Icons.shopping_cart,
        'isAuto': false,
      },
      {
        'title': '股票分红',
        'subtitle': '招商证券',
        'amount': '+¥2,340.00',
        'time': '前天 10:15',
        'color': const Color(0xFF4CAF50),
        'icon': Icons.show_chart,
        'isAuto': false,
      },
      {
        'title': '水电费',
        'subtitle': '支付宝',
        'amount': '-¥280.50',
        'time': '前天 08:00',
        'color': const Color(0xFFF44336),
        'icon': Icons.bolt,
        'isAuto': false,
      },
    ];

    return transactions[index % transactions.length];
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
    showDialog(
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
    showModalBottomSheet(
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

  void _showTransactionDetail(Map<String, dynamic> transaction) {
    showModalBottomSheet(
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
            _buildDetailRow('交易类型', transaction['title'] as String),
            _buildDetailRow('交易账户', transaction['subtitle'] as String),
            _buildDetailRow('交易金额', transaction['amount'] as String),
            _buildDetailRow('交易时间', transaction['time'] as String),
            if (transaction['isAuto'] == true) ...[
              SizedBox(height: context.spacing12),
              Container(
                padding: EdgeInsets.all(context.responsiveSpacing8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(context.responsiveSpacing8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_mode,
                      color: Color(0xFF2196F3),
                      size: 16,
                    ),
                    SizedBox(width: context.spacing8),
                    Text(
                      '此交易由财务计划自动生成',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
}
