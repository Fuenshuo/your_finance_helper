import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:your_finance_flutter/models/account.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/models/budget.dart';
import 'package:your_finance_flutter/models/transaction.dart';
import 'package:your_finance_flutter/providers/asset_provider.dart';
import 'package:your_finance_flutter/screens/add_asset_flow_screen.dart';
import 'package:your_finance_flutter/screens/edit_asset_sheet.dart';
import 'package:your_finance_flutter/screens/property_detail_screen.dart';
import 'package:your_finance_flutter/services/hybrid_storage_service.dart';
import 'package:your_finance_flutter/utils/debug_mode_manager.dart';

class AssetManagementScreen extends StatefulWidget {
  const AssetManagementScreen({super.key});

  @override
  State<AssetManagementScreen> createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> {
  final DebugModeManager _debugManager = DebugModeManager();

  @override
  void initState() {
    super.initState();
    _debugManager.addListener(_onDebugModeChanged);
  }

  @override
  void dispose() {
    _debugManager.removeListener(_onDebugModeChanged);
    super.dispose();
  }

  void _onDebugModeChanged() {
    setState(() {});
  }

  // Debug功能处理
  Future<void> _handleDebugAction(BuildContext context, String action) async {
    final storageService = await HybridStorageService.getInstance();

    switch (action) {
      case 'export':
        await _exportData(context, storageService);
      case 'import':
        await _importData(context, storageService);
      case 'clear':
        await _clearAllData(context, storageService);
      case 'sample':
        await _generateSampleData(context);
    }
  }

  // 导出数据
  Future<void> _exportData(
    BuildContext context,
    HybridStorageService storageService,
  ) async {
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

      // 静默导出数据，不显示提示框
    } catch (e) {
      // 静默处理错误，不显示提示框
    }
  }

  // 导入数据
  Future<void> _importData(
    BuildContext context,
    HybridStorageService storageService,
  ) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text == null) {
        // 静默处理，不显示提示框
        return;
      }

      final importData = jsonDecode(clipboardData!.text!);

      // 导入资产
      if (importData['assets'] != null) {
        final assets = (importData['assets'] as List)
            .map((json) => AssetItem.fromJson(json as Map<String, dynamic>))
            .toList();
        await storageService.saveAssets(assets);
      }

      // 导入交易
      if (importData['transactions'] != null) {
        final transactions = (importData['transactions'] as List)
            .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
            .toList();
        await storageService.saveTransactions(transactions);
      }

      // 导入账户
      if (importData['accounts'] != null) {
        final accounts = (importData['accounts'] as List)
            .map((json) => Account.fromJson(json as Map<String, dynamic>))
            .toList();
        await storageService.saveAccounts(accounts);
      }

      // 导入预算
      if (importData['envelopeBudgets'] != null) {
        final budgets = (importData['envelopeBudgets'] as List)
            .map(
              (json) => EnvelopeBudget.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        await storageService.saveEnvelopeBudgets(budgets);
      }

      if (importData['zeroBasedBudgets'] != null) {
        final budgets = (importData['zeroBasedBudgets'] as List)
            .map(
              (json) => ZeroBasedBudget.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        await storageService.saveZeroBasedBudgets(budgets);
      }

      // 刷新所有Provider
      if (context.mounted) {
        context.read<AssetProvider>().loadAssets();
        // 其他Provider会在下次访问时自动重新加载数据
        // 静默导入数据，不显示提示框
      }
    } catch (e) {
      // 静默处理错误，不显示提示框
    }
  }

  // 清空所有数据
  Future<void> _clearAllData(
    BuildContext context,
    HybridStorageService storageService,
  ) async {
    print('🗑️ 开始清空数据流程...');

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

    print('🗑️ 用户确认结果: $confirmed');

    if (confirmed == true) {
      print('🗑️ 开始执行清空操作...');
      await storageService.clearAll();
      print('🗑️ 清空操作完成');

      if (context.mounted) {
        print('🗑️ 重新加载资产数据...');
        await context.read<AssetProvider>().loadAssets();
        print('🗑️ 资产数据重新加载完成');

        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('数据已清空'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('🗑️ 用户取消了清空操作');
    }
  }

  // 生成测试数据
  Future<void> _generateSampleData(BuildContext context) async {
    try {
      print('🔄 开始生成测试数据...');
      final storageService = await HybridStorageService.getInstance();
      print('✅ 存储服务初始化成功');

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
      print('✅ 测试资产数据生成完成，共${sampleAssets.length}个资产');

      // 生成测试账户
      final sampleAccounts = [
        Account(
          name: '现金',
          type: AccountType.cash,
          balance: 2000.0,
        ),
        Account(
          name: '招商银行储蓄卡',
          type: AccountType.bank,
          balance: 15000.0,
          bankName: '招商银行',
        ),
        Account(
          name: '支付宝',
          type: AccountType.bank,
          balance: 5000.0,
        ),
      ];
      print('✅ 测试账户数据生成完成，共${sampleAccounts.length}个账户');

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
      print('✅ 测试预算数据生成完成，共${sampleEnvelopeBudgets.length}个预算');

      // 保存测试数据
      print('💾 开始保存测试数据...');
      await storageService.saveAssets(sampleAssets);
      print('✅ 资产数据保存成功');

      await storageService.saveAccounts(sampleAccounts);
      print('✅ 账户数据保存成功');

      await storageService.saveEnvelopeBudgets(sampleEnvelopeBudgets);
      print('✅ 预算数据保存成功');

      // 刷新Provider
      if (context.mounted) {
        print('🔄 刷新Provider...');
        context.read<AssetProvider>().loadAssets();
        print('✅ 测试数据生成完成！');

        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('测试数据生成成功！'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ 生成测试数据时出错: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('生成测试数据失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('资产管理'),
          actions: [
            // Debug按钮 - 仅在debug模式开启时显示
            if (_debugManager.isDebugModeEnabled)
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
            final groupedAssets = <AssetCategory, List<AssetItem>>{};
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    ...assets.map(
                      (asset) => _buildAssetCard(context, asset, assetProvider),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          },
        ),
      );

  Widget _buildAssetCard(
    BuildContext context,
    AssetItem asset,
    AssetProvider assetProvider,
  ) =>
      Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行：图标 + 标题 + 金额 + 操作按钮
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          _getAssetIconColor(asset.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getAssetIcon(asset),
                      color: _getAssetIconColor(asset.category),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      asset.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Text(
                    assetProvider.formatAmount(asset.amount),
                    style: TextStyle(
                      color: asset.category == AssetCategory.liabilities
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
              // 第三行：录入时间（突出显示）
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.red.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatCreationDate(asset.creationDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              // 第四行：备注信息（如果有的话）
              if (_buildAssetCardSubtitle(context, asset) != null) ...[
                const SizedBox(height: 6),
                _buildAssetCardSubtitle(context, asset)!,
              ],
            ],
          ),
        ),
      );

  void _showEditAssetSheet(BuildContext context, AssetItem asset) {
    // 对于简单的资产，使用原有的编辑表单
    if (asset.category != AssetCategory.fixedAssets) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => EditAssetSheet(asset: asset),
      );
      return;
    }

    // 对于固定资产，提供详细录入选项
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildFixedAssetEditOptions(context, asset),
    );
  }

  Widget _buildFixedAssetEditOptions(BuildContext context, AssetItem asset) =>
      Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择编辑方式',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '您可以选择快速编辑或详细编辑来修改您的固定资产',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // 快速编辑选项
            _buildEditOption(
              context,
              icon: Icons.edit,
              title: '快速编辑',
              subtitle: '修改基本信息（名称、金额等）',
              onTap: () {
                Navigator.of(context).pop();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => EditAssetSheet(asset: asset),
                );
              },
            ),
            const SizedBox(height: 12),

            // 详细编辑选项
            if (_isPropertyAsset(asset))
              _buildEditOption(
                context,
                icon: Icons.home,
                title: '房产详细编辑',
                subtitle: '完整的房产信息编辑，包括地址、面积等',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => PropertyDetailScreen(
                        asset: asset,
                        onPropertySaved: (savedAsset) {
                          final assetProvider = Provider.of<AssetProvider>(
                            context,
                            listen: false,
                          );
                          assetProvider.updateAsset(savedAsset);
                          Navigator.of(context).pop(); // 返回到资产管理页面
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('房产信息更新成功'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // 取消按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
            ),
          ],
        ),
      );

  Widget _buildEditOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      );

  bool _isPropertyAsset(AssetItem asset) {
    // 判断是否为房产类资产
    final propertySubCategories = ['房产 (自住)', '房产 (投资)', '车位'];
    return propertySubCategories.contains(asset.subCategory) ||
        asset.name.contains('房产') ||
        asset.name.contains('房子') ||
        asset.name.contains('住宅') ||
        asset.name.contains('车位');
  }

  void _showDeleteDialog(
    BuildContext context,
    AssetItem asset,
    AssetProvider assetProvider,
  ) {
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
              // 静默删除，不显示提示框
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget? _buildAssetCardSubtitle(BuildContext context, AssetItem asset) {
    // 对于房产资产，显示详细信息
    if (_isPropertyAsset(asset) &&
        asset.notes != null &&
        asset.notes!.isNotEmpty) {
      final propertyInfo = _parsePropertyInfo(asset.notes!);
      if (propertyInfo.isNotEmpty) {
        return Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.home_outlined,
                size: 14,
                color: Colors.blue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  propertyInfo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }
    }

    // 显示子分类
    return Text(asset.subCategory);
  }

  String _parsePropertyInfo(String notes) {
    try {
      if (notes.startsWith('{"propertyDetails":')) {
        // 首先尝试解析为标准JSON格式
        try {
          final notesData = jsonDecode(notes) as Map<String, dynamic>;
          final propertyDetails =
              notesData['propertyDetails'] as Map<String, dynamic>;

          final address = propertyDetails['address'];
          final area = propertyDetails['area'];

          final infoParts = <String>[];
          if (address != null && address.isNotEmpty) {
            infoParts.add(address as String);
          }
          if (area != null && area.isNotEmpty) {
            infoParts.add('$area㎡');
          }

          return infoParts.isNotEmpty ? infoParts.join(' · ') : '';
        } catch (jsonError) {
          // 如果JSON解析失败，尝试解析旧的Map.toString()格式
          print('🔄 尝试解析旧格式房产数据');
          final notesStr = notes.substring(19); // 移除 '{"propertyDetails":'
          final endIndex = notesStr.lastIndexOf('}');
          if (endIndex > 0) {
            final detailsStr = notesStr.substring(0, endIndex);
            final detailsMap = _parseOldPropertyDetails(detailsStr);

            final address = detailsMap['address'];
            final area = detailsMap['area'];

            final infoParts = <String>[];
            if (address != null && address.isNotEmpty) {
              infoParts.add(address);
            }
            if (area != null && area.isNotEmpty) {
              infoParts.add('$area㎡');
            }

            return infoParts.isNotEmpty ? infoParts.join(' · ') : '';
          }
        }
      }
    } catch (e) {
      print('❌ 解析房产信息失败: $e');
    }

    return '';
  }

  Map<String, String> _parseOldPropertyDetails(String detailsStr) {
    final result = <String, String>{};

    // 解析旧的Map.toString()格式: {address: xxx, area: xxx, ...}
    final pairs = detailsStr.split(', ');
    for (final pair in pairs) {
      final colonIndex = pair.indexOf(': ');
      if (colonIndex > 0) {
        final key = pair
            .substring(0, colonIndex)
            .replaceAll('{', '')
            .replaceAll('}', '');
        final value = pair.substring(colonIndex + 2).replaceAll("'", '');
        result[key] = value;
      }
    }

    return result;
  }

  IconData _getAssetIcon(AssetItem asset) {
    // 根据资产类型和子分类返回对应的图标
    if (_isPropertyAsset(asset)) {
      return Icons.home_outlined;
    }

    switch (asset.category) {
      case AssetCategory.liquidAssets:
        if (asset.subCategory.contains('银行') ||
            asset.subCategory.contains('存款')) {
          return Icons.account_balance_outlined;
        } else if (asset.subCategory.contains('现金') ||
            asset.subCategory.contains('钱包')) {
          return Icons.wallet_outlined;
        } else if (asset.subCategory.contains('基金') ||
            asset.subCategory.contains('股票')) {
          return Icons.trending_up_outlined;
        } else if (asset.subCategory.contains('理财') ||
            asset.subCategory.contains('保险')) {
          return Icons.shield_outlined;
        }
        return Icons.monetization_on_outlined;

      case AssetCategory.fixedAssets:
        if (asset.subCategory.contains('车')) {
          return Icons.directions_car_outlined;
        } else if (asset.subCategory.contains('黄金') ||
            asset.subCategory.contains('珠宝')) {
          return Icons.diamond_outlined;
        } else if (asset.subCategory.contains('收藏') ||
            asset.subCategory.contains('艺术')) {
          return Icons.palette_outlined;
        }
        return Icons.inventory_2_outlined;

      case AssetCategory.investments:
        if (asset.subCategory.contains('基金') ||
            asset.subCategory.contains('股票')) {
          return Icons.trending_up_outlined;
        } else if (asset.subCategory.contains('债券')) {
          return Icons.receipt_long_outlined;
        } else if (asset.subCategory.contains('外汇')) {
          return Icons.currency_exchange_outlined;
        } else if (asset.subCategory.contains('期货') ||
            asset.subCategory.contains('期权')) {
          return Icons.show_chart_outlined;
        }
        return Icons.business_center_outlined;

      case AssetCategory.liabilities:
        if (asset.subCategory.contains('房贷') ||
            asset.subCategory.contains('房')) {
          return Icons.home_work_outlined;
        } else if (asset.subCategory.contains('车贷') ||
            asset.subCategory.contains('车')) {
          return Icons.directions_car_outlined;
        } else if (asset.subCategory.contains('信用卡')) {
          return Icons.credit_card_outlined;
        } else if (asset.subCategory.contains('消费贷') ||
            asset.subCategory.contains('个人贷')) {
          return Icons.account_balance_wallet_outlined;
        }
        return Icons.account_balance_outlined;

      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _getAssetIconColor(AssetCategory category) {
    // 根据资产类型返回对应的颜色
    switch (category) {
      case AssetCategory.liquidAssets:
        return const Color(0xFF4ECDC4); // 青色
      case AssetCategory.fixedAssets:
        return const Color(0xFF96CEB4); // 绿色
      case AssetCategory.investments:
        return const Color(0xFFF7DC6F); // 金色
      case AssetCategory.liabilities:
        return const Color(0xFFBB8FCE); // 紫色
      default:
        return const Color(0xFF4ECDC4); // 默认青色
    }
  }

  String _formatCreationDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    String datePart;
    if (dateOnly == today) {
      // 今天
      datePart = '今天';
    } else if (dateOnly == yesterday) {
      // 昨天
      datePart = '昨天';
    } else if (date.year == now.year) {
      // 今年
      datePart =
          '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else {
      // 其他年份
      datePart =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    // 添加具体时间
    final timePart =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '$datePart $timePart';
  }
}
