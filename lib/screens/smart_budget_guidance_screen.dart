import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/providers/budget_provider.dart';
import 'package:your_finance_flutter/providers/transaction_provider.dart';
import 'package:your_finance_flutter/services/smart_budget_guidance_service.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

class SmartBudgetGuidanceScreen extends StatefulWidget {
  const SmartBudgetGuidanceScreen({
    required this.asset,
    super.key,
    this.onComplete,
  });
  final AssetItem asset;
  final VoidCallback? onComplete;

  @override
  State<SmartBudgetGuidanceScreen> createState() =>
      _SmartBudgetGuidanceScreenState();
}

class _SmartBudgetGuidanceScreenState extends State<SmartBudgetGuidanceScreen> {
  final SmartBudgetGuidanceService _guidanceService =
      SmartBudgetGuidanceService();
  List<BudgetSuggestion> _suggestions = [];
  final Set<String> _selectedSuggestions = {};

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  void _loadSuggestions() {
    _suggestions = _guidanceService.getBudgetSuggestionsForAsset(widget.asset);
    _suggestions = _guidanceService.getPrioritizedSuggestions(_suggestions);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: const Text('智能预算建议'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _skipAll,
              child: const Text('跳过'),
            ),
          ],
        ),
        body: Column(
          children: [
            // 资产信息卡片
            _buildAssetInfoCard(),

            // 建议列表
            Expanded(
              child: _suggestions.isEmpty
                  ? _buildNoSuggestionsView()
                  : _buildSuggestionsList(),
            ),

            // 底部操作按钮
            _buildBottomActions(),
          ],
        ),
      );

  Widget _buildAssetInfoCard() => Container(
        margin: EdgeInsets.all(context.spacing16),
        child: AppCard(
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getAssetCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAssetCategoryIcon(),
                  color: _getAssetCategoryColor(),
                  size: 30,
                ),
              ),
              SizedBox(width: context.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.asset.name,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: context.spacing4),
                    Text(
                      '${widget.asset.category.displayName} • ${context.formatAmount(widget.asset.amount)}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.secondaryText,
                      ),
                    ),
                    SizedBox(height: context.spacing8),
                    Text(
                      '基于您的资产，我们为您推荐以下预算设置：',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildNoSuggestionsView() => Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacing32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              SizedBox(height: context.spacing24),
              Text(
                '暂无预算建议',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.spacing8),
              Text(
                '您的资产类型暂时不需要特殊的预算设置',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _buildSuggestionsList() => ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: context.spacing16),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) => AppAnimations.animatedListItem(
          index: index,
          child: _buildSuggestionCard(_suggestions[index]),
        ),
      );

  Widget _buildSuggestionCard(BudgetSuggestion suggestion) => Container(
        margin: EdgeInsets.only(bottom: context.spacing12),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _selectedSuggestions.contains(suggestion.title),
                    onChanged: (value) => _toggleSuggestion(suggestion.title),
                    activeColor: context.primaryAction,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              suggestion.title,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: context.spacing8),
                            _buildPriorityBadge(suggestion.priority),
                            SizedBox(width: context.spacing8),
                            _buildTypeBadge(suggestion.type),
                          ],
                        ),
                        SizedBox(height: context.spacing4),
                        Text(
                          suggestion.description,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.spacing12),

              // 预算详情
              Container(
                padding: EdgeInsets.all(context.spacing12),
                decoration: BoxDecoration(
                  color: context.primaryBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '建议金额',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.secondaryText,
                          ),
                        ),
                        Text(
                          context.formatAmount(suggestion.suggestedAmount),
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                suggestion.type == BudgetSuggestionType.income
                                    ? context.decreaseColor
                                    : context.increaseColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '执行周期',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.secondaryText,
                          ),
                        ),
                        Text(
                          _getRecurringRuleText(suggestion.recurringRule),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
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
      );

  Widget _buildPriorityBadge(BudgetSuggestionPriority priority) {
    Color color;
    String text;

    switch (priority) {
      case BudgetSuggestionPriority.high:
        color = Colors.red;
        text = '高';
      case BudgetSuggestionPriority.medium:
        color = Colors.orange;
        text = '中';
      case BudgetSuggestionPriority.low:
        color = Colors.green;
        text = '低';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing8,
        vertical: context.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BudgetSuggestionType type) {
    Color color;
    String text;
    IconData icon;

    switch (type) {
      case BudgetSuggestionType.income:
        color = Colors.green;
        text = '收入';
        icon = Icons.trending_up;
      case BudgetSuggestionType.envelope:
        color = Colors.blue;
        text = '支出';
        icon = Icons.trending_down;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing8,
        vertical: context.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: context.spacing4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() => Container(
        padding: EdgeInsets.all(context.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _skipAll,
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: context.spacing12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('跳过所有建议'),
                  ),
                ),
                SizedBox(width: context.spacing12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _selectedSuggestions.isEmpty
                        ? null
                        : _createSelectedBudgets,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryAction,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: context.spacing12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '创建选中预算 (${_selectedSuggestions.length})',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  void _toggleSuggestion(String title) {
    setState(() {
      if (_selectedSuggestions.contains(title)) {
        _selectedSuggestions.remove(title);
      } else {
        _selectedSuggestions.add(title);
      }
    });
  }

  void _skipAll() {
    Navigator.of(context).pop();
    widget.onComplete?.call();
  }

  Future<void> _createSelectedBudgets() async {
    if (_selectedSuggestions.isEmpty) return;

    try {
      final budgetProvider = context.read<BudgetProvider>();
      final transactionProvider = context.read<TransactionProvider>();

      for (final suggestion in _suggestions) {
        if (_selectedSuggestions.contains(suggestion.title)) {
          // 创建信封预算
          final budget = suggestion.toEnvelopeBudget();
          await budgetProvider.addEnvelopeBudget(budget);

          // 创建周期性交易
          final transaction = suggestion.toRecurringTransaction();
          await transactionProvider.addTransaction(transaction);
        }
      }

      if (mounted) {
        // 静默创建预算，不显示提示框
        Navigator.of(context).pop();
        widget.onComplete?.call();
      }
    } catch (e) {
      // 静默处理错误，不显示提示框
    }
  }

  Color _getAssetCategoryColor() {
    switch (widget.asset.category) {
      case AssetCategory.liquidAssets:
        return Colors.blue;
      case AssetCategory.fixedAssets:
        return Colors.green;
      case AssetCategory.investments:
        return Colors.orange;
      case AssetCategory.receivables:
        return Colors.purple;
      case AssetCategory.liabilities:
        return Colors.red;
    }
  }

  IconData _getAssetCategoryIcon() {
    switch (widget.asset.category) {
      case AssetCategory.liquidAssets:
        return Icons.account_balance_wallet;
      case AssetCategory.fixedAssets:
        return Icons.home;
      case AssetCategory.investments:
        return Icons.trending_up;
      case AssetCategory.receivables:
        return Icons.people;
      case AssetCategory.liabilities:
        return Icons.credit_card;
    }
  }

  String _getRecurringRuleText(RecurringRule rule) {
    switch (rule) {
      case RecurringRule.daily:
        return '每日';
      case RecurringRule.weekly:
        return '每周';
      case RecurringRule.monthly:
        return '每月';
      case RecurringRule.yearly:
        return '每年';
    }
  }
}
