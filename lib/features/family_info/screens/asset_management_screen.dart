import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:uuid/uuid.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/hybrid_storage_service.dart';
import 'package:your_finance_flutter/core/utils/debug_mode_manager.dart';
import 'package:your_finance_flutter/features/family_info/screens/account_detail_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/add_asset_flow_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/asset_detail_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/asset_edit_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/wallet_management_screen.dart';

class AssetManagementScreen extends StatefulWidget {
  const AssetManagementScreen({super.key});

  @override
  State<AssetManagementScreen> createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> {
  final DebugModeManager _debugManager = DebugModeManager();
  late final IOSAnimationSystem _animationSystem;

  @override
  void initState() {
    super.initState();
    _debugManager.addListener(_onDebugModeChanged);

    // ===== v1.1.0 初始化企业级动效系统 =====
    _animationSystem = IOSAnimationSystem();

    // 注册资产管理专用动效曲线
    IOSAnimationSystem.registerCustomCurve(
        'asset-card-hover', Curves.easeInOutCubic);
    IOSAnimationSystem.registerCustomCurve(
        'category-expand', Curves.elasticOut);
    IOSAnimationSystem.registerCustomCurve(
        'asset-transition', Curves.fastOutSlowIn);
  }

  @override
  void dispose() {
    _debugManager.removeListener(_onDebugModeChanged);
    _animationSystem.dispose();
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
    Logger.debug('🗑️ 开始清空数据流程...');

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

    Logger.debug('🗑️ 用户确认结果: $confirmed');

    if (confirmed ?? false) {
      Logger.debug('🗑️ 开始执行清空操作...');
      await storageService.clearAll();
      Logger.debug('🗑️ 清空操作完成');

      if (context.mounted) {
        Logger.debug('🗑️ 重新加载资产数据...');
        await context.read<AssetProvider>().loadAssets();
        Logger.debug('🗑️ 资产数据重新加载完成');

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
      Logger.debug('🗑️ 用户取消了清空操作');
    }
  }

  // 生成测试数据
  Future<void> _generateSampleData(BuildContext context) async {
    try {
      Logger.debug('🔄 开始生成测试数据...');
      final storageService = await HybridStorageService.getInstance();
      Logger.debug('✅ 存储服务初始化成功');

      // 生成测试资产 - 适配新的资产分类
      final sampleAssets = [
        // 流动资产
        AssetItem(
          id: const Uuid().v4(),
          name: '现金',
          category: AssetCategory.liquidAssets,
          amount: 2000.0,
          subCategory: '现金',
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
          name: '支付宝',
          category: AssetCategory.liquidAssets,
          amount: 5000.0,
          subCategory: '支付宝',
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),

        // 不动产
        AssetItem(
          id: const Uuid().v4(),
          name: '自住房产',
          category: AssetCategory.realEstate,
          amount: 800000.0,
          subCategory: '住宅',
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),

        // 投资理财
        AssetItem(
          id: const Uuid().v4(),
          name: '股票投资',
          category: AssetCategory.investments,
          amount: 25000.0,
          subCategory: '股票',
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),

        // 消费资产
        AssetItem(
          id: const Uuid().v4(),
          name: 'MacBook Pro',
          category: AssetCategory.consumptionAssets,
          amount: 15000.0,
          subCategory: '电子产品',
          creationDate: DateTime.now().subtract(const Duration(days: 180)),
          updateDate: DateTime.now(),
          purchaseDate: DateTime.now().subtract(const Duration(days: 180)),
        ),
        AssetItem(
          id: const Uuid().v4(),
          name: 'iPhone 15',
          category: AssetCategory.consumptionAssets,
          amount: 8000.0,
          subCategory: '电子产品',
          creationDate: DateTime.now().subtract(const Duration(days: 60)),
          updateDate: DateTime.now(),
          purchaseDate: DateTime.now().subtract(const Duration(days: 60)),
        ),

        // 债务
        AssetItem(
          id: const Uuid().v4(),
          name: '信用卡欠款',
          category: AssetCategory.liabilities,
          amount: 3000.0,
          subCategory: '信用卡欠款',
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
      ];
      Logger.debug('✅ 测试资产数据生成完成，共${sampleAssets.length}个资产');

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
      Logger.debug('✅ 测试账户数据生成完成，共${sampleAccounts.length}个账户');

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
      Logger.debug('✅ 测试预算数据生成完成，共${sampleEnvelopeBudgets.length}个预算');

      // 保存测试数据
      Logger.debug('💾 开始保存测试数据...');
      await storageService.saveAssets(sampleAssets);
      Logger.debug('✅ 资产数据保存成功');

      await storageService.saveAccounts(sampleAccounts);
      Logger.debug('✅ 账户数据保存成功');

      await storageService.saveEnvelopeBudgets(sampleEnvelopeBudgets);
      Logger.debug('✅ 预算数据保存成功');

      // 刷新Provider
      if (context.mounted) {
        Logger.debug('🔄 刷新Provider...');
        context.read<AssetProvider>().loadAssets();
        Logger.debug('✅ 测试数据生成完成！');

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
      Logger.debug('❌ 生成测试数据时出错: $e');
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
                  AppAnimations.createRoute<void>(const AddAssetFlowScreen()),
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

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 账户余额总览
                _buildAccountBalanceOverview(context),
                const SizedBox(height: 24),

                // 资产分组列表
                ...groupedAssets.entries.map((entry) {
                  final category = entry.key;
                  final assets = entry.value;

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
                        (asset) =>
                            _buildAssetCard(context, asset, assetProvider),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
              ],
            );
          },
        ),
      );

  /// 构建账户余额总览
  Widget _buildAccountBalanceOverview(BuildContext context) =>
      Consumer2<AccountProvider, TransactionProvider>(
        builder: (context, accountProvider, transactionProvider, child) {
          final accounts = accountProvider.activeAccounts;

          if (accounts.isEmpty) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF2196F3).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xFF2196F3),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '💰 账户余额',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '暂无账户信息，请先添加银行卡或电子钱包',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // 导航到钱包管理页面
                          Navigator.of(context).push(
                            AppAnimations.createRoute<void>(
                                const WalletManagementScreen()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('添加账户'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 计算总余额
          double totalBalance = 0;
          for (final account in accounts) {
            final realBalance = accountProvider.getAccountBalance(
              account.id,
              transactionProvider.transactions,
            );
            if (account.type.isAsset) {
              totalBalance += realBalance;
            } else {
              totalBalance -= realBalance; // 负债减去
            }
          }

          // 按类型分组账户
          final assetAccounts = accounts.where((a) => a.type.isAsset).toList();
          final liabilityAccounts =
              accounts.where((a) => a.type.isLiability).toList();

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Color(0xFF2196F3),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '💰 账户余额',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      Text(
                        '${totalBalance >= 0 ? '+' : ''}¥${totalBalance.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: totalBalance >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 资产账户列表
                  if (assetAccounts.isNotEmpty) ...[
                    Text(
                      '流动资产',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...assetAccounts.map(
                      (account) => _buildAccountItem(
                        context,
                        account,
                        transactionProvider,
                        accountProvider,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 负债账户列表
                  if (liabilityAccounts.isNotEmpty) ...[
                    Text(
                      '负债账户',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...liabilityAccounts.map(
                      (account) => _buildAccountItem(
                        context,
                        account,
                        transactionProvider,
                        accountProvider,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // 导航到钱包管理页面
                        Navigator.of(context).push(
                          AppAnimations.createRoute<void>(
                              const WalletManagementScreen()),
                        );
                      },
                      icon: const Icon(Icons.manage_accounts),
                      label: const Text('管理账户'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2196F3)),
                        foregroundColor: const Color(0xFF2196F3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  /// 构建账户项
  Widget _buildAccountItem(
    BuildContext context,
    Account account,
    TransactionProvider transactionProvider,
    AccountProvider accountProvider,
  ) =>
      InkWell(
        onTap: () {
          Navigator.of(context).push(
            AppAnimations.createRoute<void>(AccountDetailScreen(account: account)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      _getAccountIconColor(account.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _getAccountIcon(account.type),
                  color: _getAccountIconColor(account.type),
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  account.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Builder(
                builder: (context) {
                  final realBalance = accountProvider.getAccountBalance(
                    account.id,
                    transactionProvider.transactions,
                  );
                  return Text(
                    '${realBalance >= 0 ? '+' : ''}¥${realBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: account.type.isAsset ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );

  /// 获取账户图标
  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.money;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.loan:
        return Icons.account_balance_wallet;
      case AccountType.asset:
        return Icons.business;
      case AccountType.liability:
        return Icons.warning;
    }
  }

  /// 获取账户图标颜色
  Color _getAccountIconColor(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Colors.green;
      case AccountType.bank:
        return const Color(0xFF2196F3);
      case AccountType.creditCard:
        return Colors.orange;
      case AccountType.investment:
        return Colors.purple;
      case AccountType.loan:
        return Colors.red;
      case AccountType.asset:
        return Colors.teal;
      case AccountType.liability:
        return Colors.red;
    }
  }

  Widget _buildAssetCard(
    BuildContext context,
    AssetItem asset,
    AssetProvider assetProvider,
  ) =>
      InkWell(
        onTap: () {
          Navigator.of(context).push(
            AppAnimations.createRoute<void>(AssetDetailScreen(asset: asset)),
          );
        },
        child: Card(
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
                        color: _getAssetIconColor(asset.category)
                            .withValues(alpha: 0.1),
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    Text(
                      assetProvider.formatAmount(asset.amount),
                      style: TextStyle(
                        color: asset.category.isLiability
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
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  AssetEditScreen(asset: asset),
                            ),
                          );
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
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.red.withValues(alpha: 0.7),
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
    showDialog<void>(
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
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.3),
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
          if (address != null && address.toString().isNotEmpty) {
            infoParts.add(address.toString());
          }
          if (area != null && area.toString().isNotEmpty) {
            infoParts.add('$area㎡');
          }

          return infoParts.isNotEmpty ? infoParts.join(' · ') : '';
        } catch (jsonError) {
          // 如果JSON解析失败，尝试解析旧的Map.toString()格式
          Logger.debug('🔄 尝试解析旧格式房产数据');
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
      Logger.debug('❌ 解析房产信息失败: $e');
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
    // 根据资产类型和子分类返回对应的图标 - 适配新分类
    if (_isPropertyAsset(asset)) {
      return Icons.home_outlined;
    }

    switch (asset.category) {
      case AssetCategory.liquidAssets:
        if (asset.subCategory.contains('现金')) {
          return Icons.wallet_outlined;
        } else if (asset.subCategory.contains('银行') ||
            asset.subCategory.contains('存款')) {
          return Icons.account_balance_outlined;
        } else if (asset.subCategory.contains('基金') ||
            asset.subCategory.contains('股票')) {
          return Icons.trending_up_outlined;
        } else if (asset.subCategory.contains('理财') ||
            asset.subCategory.contains('保险')) {
          return Icons.shield_outlined;
        } else if (asset.subCategory.contains('支付宝') ||
            asset.subCategory.contains('微信')) {
          return Icons.payment_outlined;
        }
        return Icons.monetization_on_outlined;

      case AssetCategory.realEstate:
        if (asset.subCategory.contains('住宅')) {
          return Icons.home_outlined;
        } else if (asset.subCategory.contains('商铺')) {
          return Icons.business_outlined;
        } else if (asset.subCategory.contains('写字楼')) {
          return Icons.business_center_outlined;
        } else if (asset.subCategory.contains('土地')) {
          return Icons.landscape_outlined;
        } else if (asset.subCategory.contains('车位')) {
          return Icons.local_parking_outlined;
        }
        return Icons.home_work_outlined;

      case AssetCategory.investments:
        if (asset.subCategory.contains('股票')) {
          return Icons.trending_up_outlined;
        } else if (asset.subCategory.contains('基金')) {
          return Icons.pie_chart_outline;
        } else if (asset.subCategory.contains('债券')) {
          return Icons.receipt_long_outlined;
        } else if (asset.subCategory.contains('外汇')) {
          return Icons.currency_exchange_outlined;
        } else if (asset.subCategory.contains('黄金')) {
          return Icons.diamond_outlined;
        } else if (asset.subCategory.contains('P2P')) {
          return Icons.account_balance_wallet_outlined;
        } else if (asset.subCategory.contains('数字货币')) {
          return Icons.currency_bitcoin_outlined;
        }
        return Icons.business_center_outlined;

      case AssetCategory.consumptionAssets:
        if (asset.subCategory.contains('电子产品')) {
          return Icons.computer_outlined;
        } else if (asset.subCategory.contains('家具')) {
          return Icons.chair_outlined;
        } else if (asset.subCategory.contains('电器')) {
          return Icons.kitchen_outlined;
        } else if (asset.subCategory.contains('服装')) {
          return Icons.checkroom_outlined;
        } else if (asset.subCategory.contains('首饰')) {
          return Icons.diamond_outlined;
        } else if (asset.subCategory.contains('书籍')) {
          return Icons.menu_book_outlined;
        } else if (asset.subCategory.contains('乐器')) {
          return Icons.music_note_outlined;
        } else if (asset.subCategory.contains('运动器材')) {
          return Icons.sports_soccer_outlined;
        }
        return Icons.inventory_2_outlined;

      case AssetCategory.receivables:
        if (asset.subCategory.contains('个人借款')) {
          return Icons.person_outlined;
        } else if (asset.subCategory.contains('企业欠款')) {
          return Icons.business_outlined;
        } else if (asset.subCategory.contains('押金')) {
          return Icons.security_outlined;
        } else if (asset.subCategory.contains('报销款')) {
          return Icons.receipt_outlined;
        }
        return Icons.account_balance_wallet_outlined;

      case AssetCategory.liabilities:
        if (asset.subCategory.contains('信用卡')) {
          return Icons.credit_card_outlined;
        } else if (asset.subCategory.contains('房贷') ||
            asset.subCategory.contains('房屋贷款')) {
          return Icons.home_work_outlined;
        } else if (asset.subCategory.contains('车贷') ||
            asset.subCategory.contains('车辆贷款')) {
          return Icons.directions_car_outlined;
        } else if (asset.subCategory.contains('消费贷')) {
          return Icons.shopping_bag_outlined;
        }
        return Icons.account_balance_outlined;
    }
  }

  Color _getAssetIconColor(AssetCategory category) {
    // 根据资产类型返回对应的颜色 - 适配新分类
    switch (category) {
      case AssetCategory.liquidAssets:
        return const Color(0xFF4ECDC4); // 青色 - 流动资产
      case AssetCategory.realEstate:
        return const Color(0xFF96CEB4); // 绿色 - 不动产
      case AssetCategory.investments:
        return const Color(0xFFF7DC6F); // 金色 - 投资理财
      case AssetCategory.consumptionAssets:
        return const Color(0xFF85C1E9); // 蓝色 - 消费资产
      case AssetCategory.receivables:
        return const Color(0xFFF8C471); // 橙色 - 应收款
      case AssetCategory.liabilities:
        return const Color(0xFFBB8FCE); // 紫色 - 债务
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
