import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:your_finance_flutter/models/asset_history.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/services/asset_history_service.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/theme/responsive_text_styles.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

class AssetHistoryScreen extends StatefulWidget {
  const AssetHistoryScreen({super.key});

  @override
  State<AssetHistoryScreen> createState() => _AssetHistoryScreenState();
}

class _AssetHistoryScreenState extends State<AssetHistoryScreen> {
  AssetHistoryService? _historyService;
  List<AssetHistory> _history = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    _historyService = await AssetHistoryService.getInstance();
    final history = await _historyService!.getAssetHistory();
    final stats = await _historyService!.getHistoryStats();

    setState(() {
      _history = history;
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('资产历史记录'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportData,
              tooltip: '导出数据',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 统计信息卡片
                  _buildStatsCard(),

                  // 历史记录列表
                  Expanded(
                    child: _history.isEmpty
                        ? _buildEmptyState()
                        : _buildHistoryList(),
                  ),
                ],
              ),
      );

  Widget _buildStatsCard() => AppCard(
        margin: EdgeInsets.all(context.responsiveSpacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '历史统计',
              style: context.mobileTitle,
            ),
            SizedBox(height: context.responsiveSpacing16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '总变更',
                    '${_stats['totalChanges'] ?? 0}',
                    Icons.history,
                    context.primaryAction,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '今日变更',
                    '${_stats['todayChanges'] ?? 0}',
                    Icons.today,
                    context.successColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.responsiveSpacing12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '新增资产',
                    '${_stats['createdAssets'] ?? 0}',
                    Icons.add_circle,
                    context.successColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '更新资产',
                    '${_stats['updatedAssets'] ?? 0}',
                    Icons.edit,
                    context.warningColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) =>
      Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: context.responsiveSpacing4),
          Text(
            value,
            style: context.mobileTitle.copyWith(
              color: color,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: context.mobileCaption,
          ),
        ],
      );

  Widget _buildHistoryList() => ListView.builder(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final history = _history[index];
          return _buildHistoryItem(history);
        },
      );

  Widget _buildHistoryItem(AssetHistory history) => AppCard(
        margin: EdgeInsets.only(bottom: context.responsiveSpacing12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getChangeTypeIcon(history.changeType),
                  color: _getChangeTypeColor(history.changeType),
                  size: 20,
                ),
                SizedBox(width: context.responsiveSpacing8),
                Expanded(
                  child: Text(
                    history.changeDescription ?? '资产变更',
                    style: context.mobileBody.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  DateFormat('MM-dd HH:mm').format(history.changeDate),
                  style: context.mobileCaption,
                ),
              ],
            ),
            if (history.asset != null) ...[
              SizedBox(height: context.responsiveSpacing8),
              Container(
                padding: EdgeInsets.all(context.responsiveSpacing8),
                decoration: BoxDecoration(
                  color: context.primaryBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(history.asset!.category),
                      color: _getCategoryColor(history.asset!.category),
                      size: 16,
                    ),
                    SizedBox(width: context.responsiveSpacing8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            history.asset!.name,
                            style: context.mobileBody.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${history.asset!.category.displayName} • ${history.asset!.subCategory}',
                            style: context.mobileCaption,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      context.formatAmount(history.asset!.amount),
                      style: context.mobileBody.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.primaryAction,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: context.responsiveSpacing16),
            Text(
              '暂无历史记录',
              style: context.mobileTitle.copyWith(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: context.responsiveSpacing8),
            Text(
              '开始管理资产后，这里会显示变更历史',
              style: context.mobileBody.copyWith(
                color: context.secondaryText,
              ),
            ),
          ],
        ),
      );

  Future<void> _exportData() async {
    try {
      await _historyService?.exportAndShare();
      // 静默导出数据，不显示提示框
    } catch (e) {
      // 静默处理错误，不显示提示框
    }
  }

  IconData _getChangeTypeIcon(AssetChangeType type) {
    switch (type) {
      case AssetChangeType.created:
        return Icons.add_circle;
      case AssetChangeType.updated:
        return Icons.edit;
      case AssetChangeType.deleted:
        return Icons.delete;
    }
  }

  Color _getChangeTypeColor(AssetChangeType type) {
    switch (type) {
      case AssetChangeType.created:
        return context.successColor;
      case AssetChangeType.updated:
        return context.warningColor;
      case AssetChangeType.deleted:
        return context.errorColor;
    }
  }

  IconData _getCategoryIcon(AssetCategory category) {
    switch (category) {
      case AssetCategory.liquidAssets:
        return Icons.account_balance_wallet;
      case AssetCategory.fixedAssets:
        return Icons.home;
      case AssetCategory.investments:
        return Icons.trending_up;
      case AssetCategory.receivables:
        return Icons.arrow_forward;
      case AssetCategory.liabilities:
        return Icons.arrow_back;
    }
  }

  Color _getCategoryColor(AssetCategory category) {
    switch (category) {
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
}
