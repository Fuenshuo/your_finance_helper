import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/asset_provider.dart';
import '../services/storage_service.dart';
import '../models/asset_item.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/budget.dart';
import 'add_asset_flow_screen.dart';
import 'edit_asset_sheet.dart';

class AssetManagementScreen extends StatelessWidget {
  const AssetManagementScreen({super.key});

  // Debug功能处理
  Future<void> _handleDebugAction(BuildContext context, String action) async {
    final storageService = await StorageService.getInstance();
    
    switch (action) {
      case 'export':
        await _exportData(context, storageService);
        break;
      case 'import':
        await _importData(context, storageService);
        break;
      case 'clear':
        await _clearAllData(context, storageService);
        break;
      case 'sample':
        await _generateSampleData(context);
        break;
    }
  }

  // 导出数据
  Future<void> _exportData(BuildContext context, StorageService storageService) async {
    try {
      final assets = await storageService.getAssets();
      final transactions = await storageService.loadTransactions();
      final accounts = await storageService.loadAccounts();
      final envelopeBudgets = await storageService.loadEnvelopeBudgets();
      final zeroBasedBudgets = await storageService.loadZeroBasedBudgets();
      
      final exportData = {
        'assets': assets.map((a) => a.toJson()).toList(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'accounts': accounts.map((a) => a.toJson()).toList(),
        'envelopeBudgets': envelopeBudgets.map((b) => b.toJson()).toList(),
        'zeroBasedBudgets': zeroBasedBudgets.map((b) => b.toJson()).toList(),
        'exportTime': DateTime.now().toIso8601String(),
      };
      
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      await Clipboard.setData(ClipboardData(text: jsonString));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('数据已导出到剪贴板'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 导入数据
  Future<void> _importData(BuildContext context, StorageService storageService) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('剪贴板中没有数据'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      final importData = jsonDecode(clipboardData!.text!);
      
      // 导入资产
      if (importData['assets'] != null) {
        final assets = (importData['assets'] as List)
            .map((json) => AssetItem.fromJson(json))
            .toList();
        await storageService.saveAssets(assets);
      }
      
      // 导入交易
      if (importData['transactions'] != null) {
        final transactions = (importData['transactions'] as List)
            .map((json) => Transaction.fromJson(json))
            .toList();
        await storageService.saveTransactions(transactions);
      }
      
      // 导入账户
      if (importData['accounts'] != null) {
        final accounts = (importData['accounts'] as List)
            .map((json) => Account.fromJson(json))
            .toList();
        await storageService.saveAccounts(accounts);
      }
      
      // 导入预算
      if (importData['envelopeBudgets'] != null) {
        final budgets = (importData['envelopeBudgets'] as List)
            .map((json) => EnvelopeBudget.fromJson(json))
            .toList();
        await storageService.saveEnvelopeBudgets(budgets);
      }
      
      if (importData['zeroBasedBudgets'] != null) {
        final budgets = (importData['zeroBasedBudgets'] as List)
            .map((json) => ZeroBasedBudget.fromJson(json))
            .toList();
        await storageService.saveZeroBasedBudgets(budgets);
      }
      
      // 刷新所有Provider
      if (context.mounted) {
        context.read<AssetProvider>().loadAssets();
        // 其他Provider会在下次访问时自动重新加载数据
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('数据导入成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 清空所有数据
  Future<void> _clearAllData(BuildContext context, StorageService storageService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('这将删除所有数据，此操作不可撤销。确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认清空'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await storageService.clearAll();
      
      if (context.mounted) {
        context.read<AssetProvider>().loadAssets();
        // 其他Provider会在下次访问时自动重新加载数据
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('所有数据已清空'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // 生成测试数据
  Future<void> _generateSampleData(BuildContext context) async {
    try {
      final storageService = await StorageService.getInstance();
      
      // 生成测试资产
      final sampleAssets = [
        AssetItem(
          id: const Uuid().v4(),
          name: '支付宝',
          category: AssetCategory.liquidAssets,
          amount: 5000.0,
          subCategory: '支付宝',
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
        AssetItem(
          id: const Uuid().v4(),
          name: '招商银行储蓄卡',
          category: AssetCategory.liquidAssets,
          amount: 15000.0,
          subCategory: '银行活期',
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
        AssetItem(
          id: const Uuid().v4(),
          name: '自住房产',
          category: AssetCategory.fixedAssets,
          amount: 800000.0,
          subCategory: '房产 (自住)',
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
        AssetItem(
          id: const Uuid().v4(),
          name: '股票投资',
          category: AssetCategory.investments,
          amount: 25000.0,
          subCategory: '股票',
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
      ];
      
      // 生成测试账户
      final sampleAccounts = [
        Account(
          name: '现金',
          type: AccountType.cash,
          balance: 2000.0,
          currency: 'CNY',
        ),
        Account(
          name: '招商银行储蓄卡',
          type: AccountType.bank,
          balance: 15000.0,
          currency: 'CNY',
          bankName: '招商银行',
        ),
        Account(
          name: '支付宝',
          type: AccountType.bank,
          balance: 5000.0,
          currency: 'CNY',
        ),
      ];
      
      // 生成测试预算
      final sampleEnvelopeBudgets = [
        EnvelopeBudget(
          name: '餐饮',
          category: TransactionCategory.food,
          allocatedAmount: 2000.0,
          period: BudgetPeriod.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
        ),
        EnvelopeBudget(
          name: '交通',
          category: TransactionCategory.transport,
          allocatedAmount: 800.0,
          period: BudgetPeriod.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
        ),
        EnvelopeBudget(
          name: '娱乐',
          category: TransactionCategory.entertainment,
          allocatedAmount: 500.0,
          period: BudgetPeriod.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
        ),
      ];
      
      // 保存测试数据
      await storageService.saveAssets(sampleAssets);
      await storageService.saveAccounts(sampleAccounts);
      await storageService.saveEnvelopeBudgets(sampleEnvelopeBudgets);
      
      // 刷新Provider
      if (context.mounted) {
        context.read<AssetProvider>().loadAssets();
        // 其他Provider会在下次访问时自动重新加载数据
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('测试数据生成成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('生成测试数据失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('资产管理'),
        actions: [
          // Debug按钮
          PopupMenuButton<String>(
            icon: const Icon(Icons.bug_report),
            onSelected: (value) => _handleDebugAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('导出数据'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload, size: 20),
                    SizedBox(width: 8),
                    Text('导入数据'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('清空数据', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sample',
                child: Row(
                  children: [
                    Icon(Icons.data_object, size: 20),
                    SizedBox(width: 8),
                    Text('生成测试数据'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddAssetFlowScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AssetProvider>(
        builder: (context, assetProvider, child) {
          if (assetProvider.assets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '暂无资产数据',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Debug按钮
                  ElevatedButton.icon(
                    onPressed: () => _handleDebugAction(context, 'sample'),
                    icon: const Icon(Icons.bug_report),
                    label: const Text('生成测试数据'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _handleDebugAction(context, 'import'),
                    icon: const Icon(Icons.upload),
                    label: const Text('导入数据'),
                  ),
                ],
              ),
            );
          }

          // 按分类分组显示资产
          final Map<AssetCategory, List<AssetItem>> groupedAssets = {};
          for (final asset in assetProvider.assets) {
            groupedAssets.putIfAbsent(asset.category, () => []).add(asset);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedAssets.length,
            itemBuilder: (context, index) {
              final category = groupedAssets.keys.elementAt(index);
              final assets = groupedAssets[category]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      category.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...assets.map((asset) => _buildAssetCard(context, asset, assetProvider)),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAssetCard(BuildContext context, AssetItem asset, AssetProvider assetProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(asset.name),
        subtitle: Text(asset.subCategory),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              assetProvider.formatAmount(asset.amount),
              style: TextStyle(
                color: asset.category == AssetCategory.liabilities
                    ? Colors.red
                    : Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditAssetSheet(context, asset);
                } else if (value == 'delete') {
                  _showDeleteDialog(context, asset, assetProvider);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('编辑'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAssetSheet(BuildContext context, AssetItem asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditAssetSheet(asset: asset),
    );
  }

  void _showDeleteDialog(BuildContext context, AssetItem asset, AssetProvider assetProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${asset.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              assetProvider.deleteAsset(asset.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('删除成功')),
              );
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
