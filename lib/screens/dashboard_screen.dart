import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/asset_provider.dart';
import 'add_asset_flow_screen.dart';
import 'asset_management_screen.dart';
import 'budget_management_screen.dart';
import 'transaction_management_screen.dart';
import 'responsive_test_screen.dart';
import '../widgets/asset_overview_card.dart';
import '../widgets/asset_distribution_card.dart';
import '../widgets/asset_chart_card.dart';
import '../theme/app_theme.dart';
import '../theme/responsive_text_styles.dart';
import '../widgets/app_animations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.primaryBackground,
      appBar: AppBar(
        title: const Text('家庭资产'),
        backgroundColor: Colors.white,
        elevation: 0,
                actions: [
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
                  IconButton(
                    icon: const Icon(Icons.text_fields_outlined),
                    onPressed: () {
                      Navigator.of(context).push(
                        AppAnimations.createRoute(
                          const ResponsiveTestScreen(),
                        ),
                      );
                    },
                  ),
                ],
      ),
      body: Consumer<AssetProvider>(
        builder: (context, assetProvider, child) {
          return RefreshIndicator(
            onRefresh: () => assetProvider.loadAssets(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(context.spacing16),
              child: Column(
                children: [
                  // 资产总览卡片
                  AppAnimations.animatedListItem(
                    index: 0,
                    child: const AssetOverviewCard(),
                  ),
                  SizedBox(height: context.spacing16),
                  
                  // 资产分布卡片
                  AppAnimations.animatedListItem(
                    index: 1,
                    child: const AssetDistributionCard(),
                  ),
                  SizedBox(height: context.spacing16),
                  
                  // 资产图表卡片
                  AppAnimations.animatedListItem(
                    index: 2,
                    child: const AssetChartCard(),
                  ),
                  SizedBox(height: context.spacing16),
                  
                  // 更新资产按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
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
          );
        },
      ),
    );
  }
}
