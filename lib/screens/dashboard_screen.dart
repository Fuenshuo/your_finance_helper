import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/providers/asset_provider.dart';
import 'package:your_finance_flutter/providers/budget_provider.dart';
import 'package:your_finance_flutter/screens/add_asset_flow_screen.dart';
import 'package:your_finance_flutter/screens/asset_calendar_view.dart';
import 'package:your_finance_flutter/screens/asset_history_screen.dart';
import 'package:your_finance_flutter/screens/asset_management_screen.dart';
import 'package:your_finance_flutter/screens/budget_management_screen.dart';
import 'package:your_finance_flutter/screens/mortgage_calculator_screen.dart';
import 'package:your_finance_flutter/screens/salary_income_setup_screen.dart';
import 'package:your_finance_flutter/screens/smart_budget_guidance_screen.dart';
import 'package:your_finance_flutter/screens/transaction_management_screen.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/utils/debug_mode_manager.dart';
import 'package:your_finance_flutter/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/asset_distribution_card.dart';
import 'package:your_finance_flutter/widgets/asset_list_overview_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DebugModeManager _debugManager = DebugModeManager();

  @override
  void initState() {
    super.initState();
    // 监听debug模式变化
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
        backgroundColor: context.primaryBackground,
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
            child: const Text('家庭资产'),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            // Debug模式指示器
            if (_debugManager.isDebugModeEnabled)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DEBUG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.of(context).push(
                  AppAnimations.createRoute(
                    const AssetHistoryScreen(),
                  ),
                );
              },
              tooltip: '历史记录',
            ),
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  AppAnimations.createRoute(
                    const TransactionManagementScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  AppAnimations.createRoute(
                    const BudgetManagementScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  AppAnimations.createRoute(
                    const AssetManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<AssetProvider>(
          builder: (context, assetProvider, child) => RefreshIndicator(
            onRefresh: () => assetProvider.loadAssets(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Banner位 - 在功能导航外部
                  _buildIncomeBanner(context),

                  // 功能导航 - 横向滑动
                  _buildHorizontalFunctionNav(context),

                  const SizedBox(height: 8),

                  // 主要内容区域
                  Column(
                    children: [
                      // 资产总览卡片
                      AppAnimations.animatedListItem(
                        index: 0,
                        child: const AssetListOverviewCard(),
                      ),
                      const SizedBox(height: 4),

                      // 资产分布卡片
                      AppAnimations.animatedListItem(
                        index: 1,
                        child: const AssetDistributionCard(),
                      ),
                      const SizedBox(height: 4),

                      // 更新资产按钮
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) => AddAssetFlowScreen(
                                    existingAssets: assetProvider.assets,
                                    isUpdateMode: true,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('更新资产'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // 构建收入设置banner
  Widget _buildIncomeBanner(BuildContext context) => Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          if (budgetProvider.salaryIncomes.isEmpty) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  AppAnimations.createRoute(
                    const SalaryIncomeSetupScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFFF6B6B)),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFFF6B6B),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '请先设置收入信息，以便更好地管理预算',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFFFF6B6B),
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );

  // 构建横向功能导航
  Widget _buildHorizontalFunctionNav(BuildContext context) => Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding:
              EdgeInsets.symmetric(horizontal: context.responsiveSpacing12),
          itemCount: _getFunctionItems().length,
          itemBuilder: (context, index) {
            final item = _getFunctionItems()[index];
            return Container(
              width: 60,
              margin: EdgeInsets.only(right: context.responsiveSpacing8),
              child: _buildFunctionNavItem(context, item),
            );
          },
        ),
      );

  // 获取功能项目列表
  List<FunctionNavItem> _getFunctionItems() => [
        // ⭐ 高优先级功能：设置收入（放在最前面）
        FunctionNavItem(
          icon: Icons.monetization_on_outlined,
          title: '设置收入',
          color: const Color(0xFFFF6B6B), // 醒目的红色
          onTap: (context) {
            Navigator.of(context).push(
              AppAnimations.createRoute(
                const SalaryIncomeSetupScreen(),
              ),
            );
          },
        ),

        // 基础功能
        FunctionNavItem(
          icon: Icons.account_balance_wallet_outlined,
          title: '预算管理',
          color: const Color(0xFF4ECDC4),
          onTap: (context) {
            Navigator.of(context).push(
              AppAnimations.createRoute(
                const BudgetManagementScreen(),
              ),
            );
          },
        ),
        FunctionNavItem(
          icon: Icons.receipt_long_outlined,
          title: '交易记录',
          color: const Color(0xFF45B7D1),
          onTap: (context) {
            Navigator.of(context).push(
              AppAnimations.createRoute(
                const TransactionManagementScreen(),
              ),
            );
          },
        ),
        FunctionNavItem(
          icon: Icons.settings_outlined,
          title: '资产管理',
          color: const Color(0xFFF7DC6F),
          onTap: (context) {
            Navigator.of(context).push(
              AppAnimations.createRoute(
                const AssetManagementScreen(),
              ),
            );
          },
        ),
        FunctionNavItem(
          icon: Icons.add_circle_outline,
          title: '添加资产',
          color: const Color(0xFFBB8FCE),
          onTap: (context) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => AddAssetFlowScreen(
                  existingAssets: context.read<AssetProvider>().assets,
                ),
              ),
            );
          },
        ),
        // 特色功能
        FunctionNavItem(
          icon: Icons.home_work_outlined,
          title: '房贷计算',
          color: const Color(0xFF96CEB4),
          onTap: (context) {
            Navigator.of(context).push(
              AppAnimations.createRoute(
                const MortgageCalculatorScreen(),
              ),
            );
          },
        ),
        FunctionNavItem(
          icon: Icons.auto_awesome_outlined,
          title: '智能引导',
          color: const Color(0xFFFFEAA7),
          onTap: (context) {
            Navigator.of(context).push(
              AppAnimations.createRoute(
                SmartBudgetGuidanceScreen(
                  asset: AssetItem(
                    id: 'smart_guidance',
                    name: '智能预算引导',
                    amount: 0,
                    category: AssetCategory.liquidAssets,
                    subCategory: '引导',
                    creationDate: DateTime.now(),
                    updateDate: DateTime.now(),
                    notes: '智能预算引导功能',
                  ),
                ),
              ),
            );
          },
        ),
        FunctionNavItem(
          icon: Icons.calendar_month_outlined,
          title: '日历视图',
          color: const Color(0xFFDDA0DD),
          onTap: (context) {
            Navigator.of(context).push(
              AppAnimations.createRoute(
                const AssetCalendarView(),
              ),
            );
          },
        ),
        FunctionNavItem(
          icon: Icons.history_outlined,
          title: '历史记录',
          color: const Color(0xFF98D8C8),
          onTap: (context) {
            Navigator.of(context).push(
              AppAnimations.createRoute(
                const AssetHistoryScreen(),
              ),
            );
          },
        ),
      ];

  // 构建功能导航项
  Widget _buildFunctionNavItem(BuildContext context, FunctionNavItem item) =>
      InkWell(
        onTap: () => item.onTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: context.responsiveSpacing8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon组件
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
}

// 功能导航项数据类
class FunctionNavItem {
  FunctionNavItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final Color color;
  final void Function(BuildContext) onTap;
}
