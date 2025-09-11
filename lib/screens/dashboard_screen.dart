import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/providers/asset_provider.dart';
import 'package:your_finance_flutter/screens/add_asset_flow_screen.dart';
import 'package:your_finance_flutter/screens/asset_calendar_view.dart';
import 'package:your_finance_flutter/screens/asset_history_screen.dart';
import 'package:your_finance_flutter/screens/asset_management_screen.dart';
import 'package:your_finance_flutter/screens/budget_management_screen.dart';
import 'package:your_finance_flutter/screens/mortgage_calculator_screen.dart';
import 'package:your_finance_flutter/screens/smart_budget_guidance_screen.dart';
import 'package:your_finance_flutter/screens/transaction_management_screen.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/asset_distribution_card.dart';
import 'package:your_finance_flutter/widgets/asset_list_overview_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: const Text('家庭资产'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
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
                  // 功能导航 - 横向滑动
                  _buildHorizontalFunctionNav(context),
                  
                  // 主要内容区域
                  Padding(
                    padding: EdgeInsets.all(context.spacing16),
                    child: Column(
                      children: [
                        // 资产总览卡片
                        AppAnimations.animatedListItem(
                          index: 0,
                          child: const AssetListOverviewCard(),
                        ),
                        SizedBox(height: context.spacing16),

                        // 资产分布卡片
                        AppAnimations.animatedListItem(
                          index: 1,
                          child: const AssetDistributionCard(),
                        ),
                        SizedBox(height: context.spacing16),

                        // 更新资产按钮
                        SizedBox(
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // 构建横向功能导航
  Widget _buildHorizontalFunctionNav(BuildContext context) => Container(
        height: 100,
        margin: EdgeInsets.symmetric(vertical: context.spacing8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: context.spacing16),
          itemCount: _getFunctionItems().length,
          itemBuilder: (context, index) {
            final item = _getFunctionItems()[index];
            return Container(
              width: 80,
              margin: EdgeInsets.only(right: context.spacing12),
              child: _buildFunctionNavItem(context, item),
            );
          },
        ),
      );

  // 获取功能项目列表
  List<FunctionNavItem> _getFunctionItems() => [
        FunctionNavItem(
          icon: Icons.account_balance_wallet_outlined,
          title: '预算',
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
          title: '交易',
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
          icon: Icons.home_work_outlined,
          title: '房贷',
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
          title: '智能',
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
          title: '日历',
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
          title: '历史',
          color: const Color(0xFF98D8C8),
          onTap: (context) {
            Navigator.of(context).push(
              AppAnimations.createRoute(
                const AssetHistoryScreen(),
              ),
            );
          },
        ),
        FunctionNavItem(
          icon: Icons.settings_outlined,
          title: '管理',
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
          title: '添加',
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
      ];

  // 构建功能导航项
  Widget _buildFunctionNavItem(BuildContext context, FunctionNavItem item) => 
      InkWell(
        onTap: () => item.onTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(height: context.spacing4),
              Text(
                item.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
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
  final IconData icon;
  final String title;
  final Color color;
  final void Function(BuildContext) onTap;

  FunctionNavItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}
