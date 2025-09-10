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

                  // 功能导航网格
                  AppAnimations.animatedListItem(
                    index: 2,
                    child: _buildFunctionGrid(context),
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
          ),
        ),
      );

  // 构建功能导航网格
  Widget _buildFunctionGrid(BuildContext context) => Container(
        padding: EdgeInsets.all(context.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '功能导航',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.spacing16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: context.spacing12,
              mainAxisSpacing: context.spacing12,
              childAspectRatio: 1.2,
              children: [
                _buildFunctionCard(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  title: '预算管理',
                  subtitle: '信封预算 & 零基预算',
                  color: const Color(0xFF4ECDC4),
                  onTap: () {
                    Navigator.of(context).push(
                      AppAnimations.createRoute(
                        const BudgetManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildFunctionCard(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: '交易记录',
                  subtitle: '收支记录 & 分类管理',
                  color: const Color(0xFF45B7D1),
                  onTap: () {
                    Navigator.of(context).push(
                      AppAnimations.createRoute(
                        const TransactionManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildFunctionCard(
                  context,
                  icon: Icons.home_work_outlined,
                  title: '房贷计算',
                  subtitle: '组合贷 & 商业贷',
                  color: const Color(0xFF96CEB4),
                  onTap: () {
                    Navigator.of(context).push(
                      AppAnimations.createRoute(
                        const MortgageCalculatorScreen(),
                      ),
                    );
                  },
                ),
                _buildFunctionCard(
                  context,
                  icon: Icons.auto_awesome_outlined,
                  title: '智能引导',
                  subtitle: '预算建议 & 资产关联',
                  color: const Color(0xFFFFEAA7),
                  onTap: () {
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
                _buildFunctionCard(
                  context,
                  icon: Icons.calendar_month_outlined,
                  title: '资产日历',
                  subtitle: '波动预测 & 时间轴',
                  color: const Color(0xFFDDA0DD),
                  onTap: () {
                    Navigator.of(context).push(
                      AppAnimations.createRoute(
                        const AssetCalendarView(),
                      ),
                    );
                  },
                ),
                _buildFunctionCard(
                  context,
                  icon: Icons.history_outlined,
                  title: '历史记录',
                  subtitle: '资产变更 & 数据追溯',
                  color: const Color(0xFF98D8C8),
                  onTap: () {
                    Navigator.of(context).push(
                      AppAnimations.createRoute(
                        const AssetHistoryScreen(),
                      ),
                    );
                  },
                ),
                _buildFunctionCard(
                  context,
                  icon: Icons.settings_outlined,
                  title: '资产管理',
                  subtitle: '数据管理 & 导入导出',
                  color: const Color(0xFFF7DC6F),
                  onTap: () {
                    Navigator.of(context).push(
                      AppAnimations.createRoute(
                        const AssetManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildFunctionCard(
                  context,
                  icon: Icons.add_circle_outline,
                  title: '添加资产',
                  subtitle: '新增资产 & 负债',
                  color: const Color(0xFFBB8FCE),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => AddAssetFlowScreen(
                          existingAssets: context.read<AssetProvider>().assets,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );

  // 构建功能卡片
  Widget _buildFunctionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.borderRadius),
        child: Container(
          padding: EdgeInsets.all(context.spacing12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(context.borderRadius),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(context.borderRadius / 2),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(height: context.spacing8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: context.spacing4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.withOpacity(0.8),
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
}
