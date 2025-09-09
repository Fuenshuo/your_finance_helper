import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/providers/asset_provider.dart';
import 'package:your_finance_flutter/screens/add_asset_flow_screen.dart';
import 'package:your_finance_flutter/screens/asset_history_screen.dart';
import 'package:your_finance_flutter/screens/asset_management_screen.dart';
import 'package:your_finance_flutter/screens/budget_management_screen.dart';
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
}
