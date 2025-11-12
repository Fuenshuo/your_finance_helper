import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:your_finance_flutter/core/models/clearance_entry.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/clearance_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/theme/responsive_text_styles.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

class PeriodDifferenceAnalysisScreen extends ConsumerStatefulWidget {
  final PeriodClearanceSession session;

  const PeriodDifferenceAnalysisScreen({
    super.key,
    required this.session,
  });

  @override
  ConsumerState<PeriodDifferenceAnalysisScreen> createState() =>
      _PeriodDifferenceAnalysisScreenState();
}

class _PeriodDifferenceAnalysisScreenState
    extends ConsumerState<PeriodDifferenceAnalysisScreen> {
  final PeriodClearanceService _clearanceService = PeriodClearanceService();
  
  late PeriodClearanceSession _currentSession;
  bool _isLoading = false;
  bool _isAddAmountDialogOpen = false; // 防止重复打开累加金额对话框
  
  // 添加交易表单控制器
  final TextEditingController _transactionDescController = TextEditingController();
  final TextEditingController _transactionAmountController = TextEditingController();
  TransactionCategory _selectedCategory = TransactionCategory.food;
  String? _selectedWalletId;

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
    _initializeService();
  }

  @override
  void dispose() {
    _transactionDescController.dispose();
    _transactionAmountController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    await _clearanceService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('差额分解', style: context.responsiveHeadlineMedium),
        centerTitle: true,
        actions: [
          if (_currentSession.canComplete)
            TextButton(
              onPressed: _completeClearance,
              child: const Text('完成清账'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(context.responsiveSpacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 会话信息卡片
                  _buildSessionInfoCard(),
                  SizedBox(height: context.responsiveSpacing16),

                  // 差额总览卡片
                  _buildDifferenceOverviewCard(),
                  SizedBox(height: context.responsiveSpacing16),

                  // 各钱包差额详情
                  _buildWalletDifferencesCard(),
                  SizedBox(height: context.responsiveSpacing16),

                  // 已添加的交易
                  _buildManualTransactionsCard(),
                  SizedBox(height: context.responsiveSpacing16),

                  // 添加交易按钮
                  _buildAddTransactionButton(),
                ],
              ),
            ),
    );
  }

  // 会话信息卡片
  Widget _buildSessionInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentSession.name,
                style: context.responsiveHeadlineMedium,
              ),
              _buildStatusBadge(_currentSession.status),
            ],
          ),
          SizedBox(height: context.responsiveSpacing8),
          Text(
            _currentSession.periodDescription,
            style: context.responsiveBodyMedium.copyWith(
              color: Colors.grey,
            ),
          ),
          if (_currentSession.notes != null) ...[
            SizedBox(height: context.responsiveSpacing8),
            Text(
              '备注: ${_currentSession.notes}',
              style: context.responsiveBodySmall.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 差额总览卡片
  Widget _buildDifferenceOverviewCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '差额总览',
            style: context.responsiveHeadlineMedium,
          ),
          SizedBox(height: context.responsiveSpacing16),
          
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  '总差额',
                  context.formatAmount(_currentSession.totalDifference),
                  Colors.blue,
                  Icons.account_balance_wallet,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  '已解释',
                  context.formatAmount(_currentSession.totalExplainedAmount),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  '剩余',
                  context.formatAmount(_currentSession.totalRemainingAmount),
                  Colors.orange,
                  Icons.help_outline,
                ),
              ),
            ],
          ),
          
          SizedBox(height: context.responsiveSpacing16),
          
          // 进度条
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '解释进度',
                    style: context.responsiveBodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(_currentSession.explanationRate * 100).toStringAsFixed(1)}%',
                    style: context.responsiveBodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _currentSession.explanationRate == 1.0 ? Colors.green : Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.responsiveSpacing8),
              LinearProgressIndicator(
                value: _currentSession.explanationRate,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _currentSession.explanationRate == 1.0 ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 各钱包差额详情卡片
  Widget _buildWalletDifferencesCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '各钱包差额详情',
            style: context.responsiveHeadlineMedium,
          ),
          SizedBox(height: context.responsiveSpacing16),
          
          if (_currentSession.walletDifferences.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(context.responsiveSpacing24),
                child: Text(
                  '暂无钱包差额数据',
                  style: context.responsiveBodyMedium.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentSession.walletDifferences.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[300],
              ),
              itemBuilder: (context, index) {
                final walletDiff = _currentSession.walletDifferences[index];
                return _buildWalletDifferenceItem(walletDiff);
              },
            ),
        ],
      ),
    );
  }

  // 单个钱包差额项
  Widget _buildWalletDifferenceItem(WalletDifference walletDiff) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.responsiveSpacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                walletDiff.walletName,
                style: context.responsiveBodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (walletDiff.hasRemainingDifference)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveSpacing8,
                    vertical: context.responsiveSpacing4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Text(
                    '有剩余',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing8),
          
          Row(
            children: [
              Expanded(
                child: _buildBalanceInfo('期初', walletDiff.startBalance),
              ),
              Expanded(
                child: _buildBalanceInfo('期末', walletDiff.endBalance),
              ),
              Expanded(
                child: _buildBalanceInfo(
                  '差额',
                  walletDiff.totalDifference,
                  isDifference: true,
                ),
              ),
            ],
          ),
          
          if (walletDiff.explainedAmount != 0) ...[
            SizedBox(height: context.responsiveSpacing8),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceInfo('已解释', walletDiff.explainedAmount),
                ),
                Expanded(
                  child: _buildBalanceInfo(
                    '剩余',
                    walletDiff.remainingAmount,
                    isDifference: true,
                  ),
                ),
                Expanded(child: Container()), // 占位
              ],
            ),
          ],
          
          if (walletDiff.hasRemainingDifference) ...[
            SizedBox(height: context.responsiveSpacing12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddTransactionDialog(walletDiff.walletId),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('添加交易'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsiveSpacing8,
                        vertical: context.responsiveSpacing4,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.responsiveSpacing8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _processRemainingDifference(walletDiff),
                    icon: const Icon(Icons.auto_fix_high, size: 16),
                    label: const Text('归为其他'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsiveSpacing8,
                        vertical: context.responsiveSpacing4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 已添加的交易卡片
  Widget _buildManualTransactionsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已添加的交易',
                style: context.responsiveHeadlineMedium,
              ),
              Text(
                '共 ${_currentSession.manualTransactions.length} 笔',
                style: context.responsiveBodyMedium.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing16),
          
          if (_currentSession.manualTransactions.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(context.responsiveSpacing24),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: context.responsiveSpacing8),
                    Text(
                      '还没有添加任何交易',
                      style: context.responsiveBodyMedium.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing4),
                    Text(
                      '点击下方按钮添加重要交易',
                      style: context.responsiveBodySmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentSession.manualTransactions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[300],
              ),
              itemBuilder: (context, index) {
                final transaction = _currentSession.manualTransactions[index];
                return _buildTransactionItem(transaction);
              },
            ),
        ],
      ),
    );
  }

  // 单个交易项
  Widget _buildTransactionItem(ManualTransaction transaction) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getCategoryColor(transaction.category).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getCategoryIcon(transaction.category),
          color: _getCategoryColor(transaction.category),
          size: 20,
        ),
      ),
      title: Text(
        transaction.description,
        style: context.responsiveBodyLarge,
      ),
      subtitle: Text(
        '${transaction.category.displayName} • ${transaction.walletName}',
        style: context.responsiveBodySmall.copyWith(
          color: Colors.grey,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.formatAmount(
              transaction.category.isIncome ? transaction.amount : -transaction.amount,
            ),
            style: context.amountStyle(
              isPositive: transaction.category.isIncome,
            ),
          ),
          SizedBox(width: context.responsiveSpacing8),
          InkWell(
            onTap: () => _deleteTransaction(transaction),
            child: Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // 添加交易按钮
  Widget _buildAddTransactionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showAddTransactionDialog,
        icon: const Icon(Icons.add),
        label: const Text('添加重要交易'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(context.responsiveSpacing16),
        ),
      ),
    );
  }

  // 辅助UI组件
  Widget _buildStatusBadge(ClearanceSessionStatus status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case ClearanceSessionStatus.balanceInput:
        color = Colors.orange;
        icon = Icons.edit;
        break;
      case ClearanceSessionStatus.differenceAnalysis:
        color = Colors.blue;
        icon = Icons.analytics;
        break;
      case ClearanceSessionStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSpacing8,
        vertical: context.responsiveSpacing4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          SizedBox(width: context.responsiveSpacing4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: context.responsiveSpacing8),
        Text(
          label,
          style: context.responsiveBodySmall.copyWith(
            color: Colors.grey,
          ),
        ),
        SizedBox(height: context.responsiveSpacing4),
        Text(
          value,
          style: context.responsiveBodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceInfo(String label, double amount, {bool isDifference = false}) {
    Color color = Colors.black;
    if (isDifference) {
      color = amount > 0 ? Colors.red : amount < 0 ? Colors.green : Colors.grey;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.responsiveBodySmall.copyWith(
            color: Colors.grey,
          ),
        ),
        SizedBox(height: context.responsiveSpacing2),
        Text(
          context.formatAmount(amount),
          style: context.responsiveBodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // 业务逻辑方法
  Color _getCategoryColor(TransactionCategory category) {
    if (category.isIncome) return Colors.green;
    return Colors.red;
  }

  IconData _getCategoryIcon(TransactionCategory category) {
    // 根据分类返回不同的图标
    switch (category) {
      case TransactionCategory.salary:
        return Icons.work;
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transport:
        return Icons.directions_car;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.healthcare:
        return Icons.local_hospital;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.housing:
        return Icons.home;
      case TransactionCategory.utilities:
        return Icons.electrical_services;
      case TransactionCategory.investment:
        return Icons.trending_up;
      case TransactionCategory.otherIncome:
      case TransactionCategory.otherExpense:
        return Icons.more_horiz;
      default:
        return Icons.attach_money;
    }
  }

  // 事件处理方法
  void _showAddTransactionDialog([String? preselectedWalletId]) {
    // 如果没有预设钱包，自动选择第一个有剩余差额的钱包
    if (preselectedWalletId == null && _currentSession.walletDifferences.isNotEmpty) {
      final walletWithRemaining = _currentSession.walletDifferences.firstWhere(
        (w) => w.hasRemainingDifference,
        orElse: () => _currentSession.walletDifferences.first,
      );
      preselectedWalletId = walletWithRemaining.walletId;
    }
    
    _selectedWalletId = preselectedWalletId;
    _transactionDescController.clear();
    _transactionAmountController.clear();
    _selectedCategory = TransactionCategory.food;

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // 计算当前钱包的剩余金额
          double getRemainingAmount() {
            if (_selectedWalletId == null) return 0.0;
            final walletDiff = _currentSession.walletDifferences.firstWhere(
              (w) => w.walletId == _selectedWalletId,
              orElse: () => _currentSession.walletDifferences.first,
            );
            final originalRemaining = walletDiff.remainingAmount;
            
            // 如果输入了金额，计算新的剩余金额
            final inputAmountText = _transactionAmountController.text.trim();
            if (inputAmountText.isNotEmpty) {
              final inputAmount = double.tryParse(inputAmountText);
              if (inputAmount != null && inputAmount > 0) {
                // 根据分类判断是收入还是支出
                final isIncome = _selectedCategory.isIncome;
                // 如果是收入，剩余金额增加；如果是支出，剩余金额减少
                final change = isIncome ? inputAmount : -inputAmount;
                return originalRemaining - change;
              }
            }
            
            return originalRemaining;
          }
          
          return AlertDialog(
            title: const Text('添加重要交易'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 实时剩余金额显示
                  Builder(
                    builder: (context) {
                      final remainingAmount = getRemainingAmount();
                      final walletDiff = _selectedWalletId != null
                          ? _currentSession.walletDifferences.firstWhere(
                              (w) => w.walletId == _selectedWalletId,
                              orElse: () => _currentSession.walletDifferences.first,
                            )
                          : null;
                      
                      if (walletDiff == null) {
                        return const SizedBox.shrink();
                      }
                      
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: remainingAmount > 0 
                              ? Colors.orange.withOpacity(0.1)
                              : remainingAmount < 0
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: remainingAmount > 0
                                ? Colors.orange.withOpacity(0.3)
                                : remainingAmount < 0
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              remainingAmount > 0
                                  ? Icons.help_outline
                                  : remainingAmount < 0
                                      ? Icons.warning_amber_rounded
                                      : Icons.check_circle_outline,
                              color: remainingAmount > 0
                                  ? Colors.orange
                                  : remainingAmount < 0
                                      ? Colors.red
                                      : Colors.green,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${walletDiff.walletName} 剩余金额',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.formatAmount(remainingAmount),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: remainingAmount > 0
                                          ? Colors.orange
                                          : remainingAmount < 0
                                              ? Colors.red
                                              : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 交易描述
                TextField(
                  controller: _transactionDescController,
                  decoration: const InputDecoration(
                    labelText: '交易描述',
                    hintText: '例如：工资收入、房租支出',
                  ),
                ),
                const SizedBox(height: 16),
                
                // 金额输入行（带累加功能）
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _transactionAmountController,
                      decoration: const InputDecoration(
                        labelText: '金额',
                        hintText: '请输入金额',
                        prefixText: '¥ ',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    // 累加按钮
                    OutlinedButton.icon(
                      onPressed: () => _showAddAmountDialog(setDialogState),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('累加金额'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 分类选择
                DropdownButtonFormField<TransactionCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '交易分类',
                  ),
                  items: TransactionCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // 钱包选择
                DropdownButtonFormField<String>(
                  value: _selectedWalletId,
                  decoration: const InputDecoration(
                    labelText: '关联钱包',
                  ),
                  items: _currentSession.walletDifferences.map((walletDiff) {
                    return DropdownMenuItem(
                      value: walletDiff.walletId,
                      child: Text(walletDiff.walletName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedWalletId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: _addTransaction,
              child: const Text('添加'),
            ),
          ],
          );
        },
      ),
    );
  }

  // 显示累加金额对话框
  void _showAddAmountDialog(StateSetter setDialogState) {
    // 防止重复打开对话框
    if (_isAddAmountDialogOpen) {
      return;
    }
    
    _isAddAmountDialogOpen = true;
    final addAmountController = TextEditingController();
    bool isAddMode = true; // true=累加，false=减少
    
    // 获取当前金额
    final currentAmountText = _transactionAmountController.text.trim();
    final currentAmount = double.tryParse(currentAmountText) ?? 0.0;
    
    // 获取当前钱包的剩余金额信息
    double getWalletRemainingAmount() {
      if (_selectedWalletId == null) return 0.0;
      final walletDiff = _currentSession.walletDifferences.firstWhere(
        (w) => w.walletId == _selectedWalletId,
        orElse: () => _currentSession.walletDifferences.first,
      );
      return walletDiff.remainingAmount;
    }
    
    // 计算累加后的剩余金额
    double calculateNewRemainingAmount(double addAmount) {
      final originalRemaining = getWalletRemainingAmount();
      // 根据分类判断是收入还是支出
      final isIncome = _selectedCategory.isIncome;
      // 如果是收入，剩余金额减少；如果是支出，剩余金额增加
      final change = isIncome ? addAmount : -addAmount;
      return originalRemaining - change;
    }
    
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setAddDialogState) {
          final walletDiff = _selectedWalletId != null
              ? _currentSession.walletDifferences.firstWhere(
                  (w) => w.walletId == _selectedWalletId,
                  orElse: () => _currentSession.walletDifferences.first,
                )
              : null;
          
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.add_circle_outline, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('累加金额'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 剩余金额显示
                  if (walletDiff != null) ...[
                    Builder(
                      builder: (context) {
                        final addAmountText = addAmountController.text.trim();
                        double remainingAmount;
                        
                        if (addAmountText.isNotEmpty) {
                          final inputAmount = double.tryParse(addAmountText);
                          if (inputAmount != null && inputAmount > 0) {
                            final addAmount = isAddMode ? inputAmount : -inputAmount;
                            remainingAmount = calculateNewRemainingAmount(addAmount);
                          } else {
                            remainingAmount = getWalletRemainingAmount();
                          }
                        } else {
                          remainingAmount = getWalletRemainingAmount();
                        }
                        
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: remainingAmount > 0 
                                ? Colors.orange.withOpacity(0.1)
                                : remainingAmount < 0
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: remainingAmount > 0
                                  ? Colors.orange.withOpacity(0.3)
                                  : remainingAmount < 0
                                      ? Colors.red.withOpacity(0.3)
                                      : Colors.green.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                remainingAmount > 0
                                    ? Icons.help_outline
                                    : remainingAmount < 0
                                        ? Icons.warning_amber_rounded
                                        : Icons.check_circle_outline,
                                color: remainingAmount > 0
                                    ? Colors.orange
                                    : remainingAmount < 0
                                        ? Colors.red
                                        : Colors.green,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${walletDiff.walletName} 剩余金额',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.formatAmount(remainingAmount),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: remainingAmount > 0
                                            ? Colors.orange
                                            : remainingAmount < 0
                                                ? Colors.red
                                                : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (currentAmount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '当前金额: ¥${currentAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                // 累加/减少切换按钮
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('累加'),
                      icon: Icon(Icons.add, size: 18),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('减少'),
                      icon: Icon(Icons.remove, size: 18),
                    ),
                  ],
                  selected: {isAddMode},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setAddDialogState(() {
                      isAddMode = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addAmountController,
                  decoration: InputDecoration(
                    labelText: isAddMode ? '要累加的金额' : '要减少的金额',
                    hintText: '请输入金额',
                    prefixText: '¥ ',
                    helperText: isAddMode 
                        ? '输入金额将累加到当前总额' 
                        : '输入金额将从当前总额中减少',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  onChanged: (value) {
                    setAddDialogState(() {});
                  },
                ),
                Builder(
                  builder: (context) {
                    final addAmountText = addAmountController.text.trim();
                    if (addAmountText.isNotEmpty) {
                      final inputAmount = double.tryParse(addAmountText);
                      if (inputAmount != null && inputAmount > 0) {
                        // 根据模式决定是累加还是减少
                        final addAmount = isAddMode ? inputAmount : -inputAmount;
                        final newTotal = currentAmount + addAmount;
                        return Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (isAddMode ? Colors.green : Colors.orange).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isAddMode ? Icons.add_circle : Icons.remove_circle,
                                    size: 18,
                                    color: isAddMode ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${isAddMode ? "累加" : "减少"}后总额: ¥${newTotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isAddMode ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final addAmountText = addAmountController.text.trim();
                final inputAmount = double.tryParse(addAmountText);
                
                if (inputAmount == null || inputAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入有效金额')),
                  );
                  return;
                }
                
                // 根据模式决定是累加还是减少
                final addAmount = isAddMode ? inputAmount : -inputAmount;
                final newTotal = currentAmount + addAmount;
                _transactionAmountController.text = newTotal.toStringAsFixed(2);
                
                // 更新对话框状态
                setDialogState(() {});
                
                // 先关闭对话框
                Navigator.of(context).pop();
                
                // 显示累加成功提示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '已${isAddMode ? "累加" : "减少"} ¥${inputAmount.toStringAsFixed(2)}，当前总额: ¥${newTotal.toStringAsFixed(2)}',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: isAddMode ? Colors.green : Colors.orange,
                  ),
                );
              },
              icon: Icon(isAddMode ? Icons.add : Icons.remove, size: 18),
              label: Text(isAddMode ? '累加' : '减少'),
            ),
          ],
          );
        },
      ),
    ).then((_) {
      // 对话框关闭后，延迟一下再重置标志和 dispose controller
      // 确保对话框完全关闭动画完成
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _isAddAmountDialogOpen = false;
        }
        try {
          addAmountController.dispose();
        } catch (e) {
          // Controller 可能已经被 dispose，忽略错误
        }
      });
    });
  }

  Future<void> _addTransaction() async {
    final description = _transactionDescController.text.trim();
    final amountText = _transactionAmountController.text.trim();
    
    if (description.isEmpty || amountText.isEmpty || _selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整信息')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效金额')),
      );
      return;
    }

    Navigator.of(context).pop(); // 关闭对话框
    
    setState(() => _isLoading = true);
    
    try {
      final walletDiff = _currentSession.walletDifferences.firstWhere(
        (w) => w.walletId == _selectedWalletId,
      );
      
      final transaction = ManualTransaction(
        description: description,
        amount: amount,
        category: _selectedCategory,
        walletId: _selectedWalletId!,
        walletName: walletDiff.walletName,
        date: DateTime.now(),
      );

      final updatedSession = await _clearanceService.addManualTransaction(
        sessionId: _currentSession.id,
        transaction: transaction,
      );

      setState(() {
        _currentSession = updatedSession;
      });

      Logger.debug('交易已添加: ${transaction.description}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已添加交易: ${transaction.description}')),
      );
      
    } catch (e) {
      Logger.debug('添加交易失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加交易失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTransaction(ManualTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除交易'),
        content: Text('确定要删除交易"${transaction.description}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    
    try {
      final updatedSession = await _clearanceService.removeManualTransaction(
        sessionId: _currentSession.id,
        transactionId: transaction.id,
      );

      setState(() {
        _currentSession = updatedSession;
      });

      Logger.debug('交易已删除: ${transaction.description}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已删除交易: ${transaction.description}')),
      );
      
    } catch (e) {
      Logger.debug('删除交易失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除交易失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processRemainingDifference(WalletDifference walletDiff) async {
    final categoryName = walletDiff.remainingAmount > 0 ? '其他收入' : '其他支出';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('处理剩余差额'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('将钱包"${walletDiff.walletName}"的剩余差额归为"$categoryName"？'),
            const SizedBox(height: 8),
            Text(
              '剩余金额: ${context.formatAmount(walletDiff.remainingAmount)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    
    try {
      final updatedSession = await _clearanceService.processRemainingDifference(
        sessionId: _currentSession.id,
        walletId: walletDiff.walletId,
        categoryName: categoryName,
      );

      setState(() {
        _currentSession = updatedSession;
      });

      Logger.debug('剩余差额已处理: ${walletDiff.walletName}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已将剩余差额归为"$categoryName"')),
      );
      
    } catch (e) {
      Logger.debug('处理剩余差额失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('处理剩余差额失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeClearance() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('完成清账'),
        content: const Text('确定要完成当前清账会话吗？完成后将生成财务总结报告。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('完成清账'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    
    try {
      final completedSession = await _clearanceService.completeClearanceSession(_currentSession.id);
      
      Logger.debug('清账会话已完成: ${completedSession.name}');
      
      // 刷新交易数据，使钱包余额更新
      try {
        final transactionProvider = provider.Provider.of<TransactionProvider>(context, listen: false);
        await transactionProvider.refresh();
        Logger.debug('✅ 交易数据已刷新');
      } catch (e) {
        Logger.debug('⚠️ 刷新交易数据失败: $e');
        // 不影响清账完成流程，继续执行
      }
      
      // 返回上一页并传递成功结果
      Navigator.of(context).pop(true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('清账已完成，交易记录已更新')),
      );
      
    } catch (e) {
      Logger.debug('完成清账失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('完成清账失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
