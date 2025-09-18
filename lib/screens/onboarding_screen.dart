import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/features/family_info/screens/add_asset_flow_screen.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';
import 'package:your_finance_flutter/core/utils/debug_mode_manager.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              final debugEnabled = _debugManager.handleClick();
              if (debugEnabled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔧 Debug模式已开启'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('家庭资产记账'),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            // Debug按钮 - 仅在debug模式开启时显示
            if (_debugManager.isDebugModeEnabled)
              PopupMenuButton<String>(
                icon: const Icon(Icons.bug_report),
                onSelected: (value) => _handleDebugAction(context, value),
                itemBuilder: (context) => [
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
                ],
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // 应用图标和标题
                Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.pie_chart,
                        size: 60,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '家庭资产记账',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '全面管理您的家庭资产和负债',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 功能介绍
                Column(
                  children: [
                    _buildFeatureRow(
                      context,
                      Icons.account_balance_wallet,
                      '流动资金',
                      '支付宝、微信、银行存款等',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      context,
                      Icons.home,
                      '固定资产',
                      '房产、汽车、收藏品等',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      context,
                      Icons.trending_up,
                      '投资理财',
                      '股票、基金、理财产品等',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      context,
                      Icons.people,
                      '应收款',
                      '借出款项、押金等',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      context,
                      Icons.credit_card,
                      '负债管理',
                      '信用卡、房贷、车贷等',
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 开始按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddAssetFlowScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '开始添加资产',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );

  Widget _buildFeatureRow(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) =>
      Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      );

  // Debug功能处理
  Future<void> _handleDebugAction(BuildContext context, String action) async {
    switch (action) {
      case 'sample':
        await _generateSampleData(context);
      case 'import':
        await _importData(context);
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
          amount: 5000,
          category: AssetCategory.liquidAssets,
          subCategory: '支付宝',
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
        AssetItem(
          id: const Uuid().v4(),
          name: '招商银行',
          amount: 15000,
          category: AssetCategory.liquidAssets,
          subCategory: '银行活期',
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
        AssetItem(
          id: const Uuid().v4(),
          name: '自住房产',
          amount: 800000,
          category: AssetCategory.realEstate,
          subCategory: '房产(自住)',
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
        AssetItem(
          id: const Uuid().v4(),
          name: '股票投资',
          amount: 25000,
          category: AssetCategory.investments,
          subCategory: '股票',
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
      ];

      // 生成测试账户
      final sampleAccounts = [
        Account(
          id: const Uuid().v4(),
          name: '现金',
          type: AccountType.cash,
          balance: 2000,
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
        Account(
          id: const Uuid().v4(),
          name: '招商银行储蓄卡',
          type: AccountType.bank,
          balance: 15000,
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
        Account(
          id: const Uuid().v4(),
          name: '支付宝',
          type: AccountType.bank,
          balance: 5000,
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
      ];

      // 生成测试预算
      final sampleBudgets = [
        EnvelopeBudget(
          id: const Uuid().v4(),
          name: '餐饮',
          category: TransactionCategory.food,
          allocatedAmount: 2000,
          period: BudgetPeriod.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
        EnvelopeBudget(
          id: const Uuid().v4(),
          name: '交通',
          category: TransactionCategory.transport,
          allocatedAmount: 800,
          period: BudgetPeriod.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
        EnvelopeBudget(
          id: const Uuid().v4(),
          name: '娱乐',
          category: TransactionCategory.entertainment,
          allocatedAmount: 500,
          period: BudgetPeriod.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
        ),
      ];

      // 生成测试交易
      final sampleTransactions = [
        Transaction(
          id: const Uuid().v4(),
          amount: 50,
          description: '午餐',
          notes: '公司附近餐厅',
          type: TransactionType.expense,
          category: TransactionCategory.food,
          subCategory: '餐饮',
          fromAccountId: sampleAccounts[0].id, // 现金账户
          envelopeBudgetId: sampleBudgets[0].id, // 餐饮预算
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Transaction(
          id: const Uuid().v4(),
          amount: 2000,
          description: '工资',
          notes: '月度工资',
          type: TransactionType.income,
          category: TransactionCategory.salary,
          subCategory: '工资',
          fromAccountId: 'external_income', // 外部收入来源
          toAccountId: sampleAccounts[1].id, // 招商银行
          date: DateTime.now().subtract(const Duration(days: 5)),
          isRecurring: true,
        ),
        Transaction(
          id: const Uuid().v4(),
          amount: 15,
          description: '地铁费',
          notes: '上班通勤',
          type: TransactionType.expense,
          category: TransactionCategory.transport,
          subCategory: '交通',
          fromAccountId: sampleAccounts[0].id, // 现金账户
          envelopeBudgetId: sampleBudgets[1].id, // 交通预算
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Transaction(
          id: const Uuid().v4(),
          amount: 100,
          description: '电影票',
          notes: '周末娱乐',
          type: TransactionType.expense,
          category: TransactionCategory.entertainment,
          subCategory: '娱乐',
          fromAccountId: sampleAccounts[2].id, // 支付宝
          envelopeBudgetId: sampleBudgets[2].id, // 娱乐预算
          date: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      // 保存数据
      await storageService.saveAssets(sampleAssets);
      await storageService.saveAccounts(sampleAccounts);
      await storageService.saveEnvelopeBudgets(sampleBudgets);
      await storageService
          .saveTransactions(sampleTransactions.cast<Transaction>());

      // 处理交易对预算的影响
      final budgetProvider = context.read<BudgetProvider>();
      for (final transaction in sampleTransactions) {
        if (transaction.type == TransactionType.expense &&
            transaction.envelopeBudgetId != null) {
          await budgetProvider.processTransaction(transaction);
        }
      }

      // 刷新Provider
      if (context.mounted) {
        context.read<AssetProvider>().loadAssets();

        // 静默生成测试数据，不显示提示框
      }
    } catch (e) {
      if (context.mounted) {
        // 静默处理错误，不显示提示框
      }
    }
  }

  // 导入数据
  Future<void> _importData(BuildContext context) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text == null) {
        // 静默处理，不显示提示框
        return;
      }

      final importData = jsonDecode(clipboardData!.text!);
      final storageService = await StorageService.getInstance();

      // 导入资产
      if (importData['assets'] != null) {
        final assets = (importData['assets'] as List<dynamic>)
            .map((json) => AssetItem.fromJson(json as Map<String, dynamic>))
            .toList();
        await storageService.saveAssets(assets);
      }

      // 导入账户
      if (importData['accounts'] != null) {
        final accounts = (importData['accounts'] as List<dynamic>)
            .map((json) => Account.fromJson(json as Map<String, dynamic>))
            .toList();
        await storageService.saveAccounts(accounts);
      }

      // 导入预算
      if (importData['envelopeBudgets'] != null) {
        final budgets = (importData['envelopeBudgets'] as List<dynamic>)
            .map(
              (json) => EnvelopeBudget.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        await storageService.saveEnvelopeBudgets(budgets);
      }

      // 导入交易
      if (importData['transactions'] != null) {
        final transactions = (importData['transactions'] as List<dynamic>)
            .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
            .toList();
        await storageService.saveTransactions(transactions);
      }

      // 刷新Provider
      if (context.mounted) {
        context.read<AssetProvider>().loadAssets();

        // 静默导入数据，不显示提示框
      }
    } catch (e) {
      if (context.mounted) {
        // 静默处理错误，不显示提示框
      }
    }
  }
}
