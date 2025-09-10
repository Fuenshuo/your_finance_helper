import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/providers/asset_provider.dart';
import 'package:your_finance_flutter/screens/add_asset_flow_screen.dart';
import 'package:your_finance_flutter/screens/fixed_asset_detail_screen.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/theme/responsive_text_styles.dart';
import 'package:your_finance_flutter/utils/performance_monitor.dart';
import 'package:your_finance_flutter/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/asset_category_tab_bar.dart';
import 'package:your_finance_flutter/widgets/asset_distribution_card.dart';
import 'package:your_finance_flutter/widgets/asset_list_item.dart';
import 'package:your_finance_flutter/widgets/asset_list_overview_card.dart';
import 'package:your_finance_flutter/widgets/enhanced_floating_action_button.dart';

class AssetListScreen extends StatefulWidget {
  const AssetListScreen({super.key});

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends State<AssetListScreen> {
  AssetCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) => PerformanceMonitor.monitorBuild(
        'AssetListScreen',
        () => Scaffold(
          backgroundColor: context.primaryBackground,
          appBar: AppBar(
            title: const Text('资产清单'),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.analytics_outlined),
                onPressed: () {
                  // TODO: 导航到历史数据总览页面
                  // 静默处理，不显示提示框
        // 静默处理，不显示提示框                },
              ,,,,),
            ],
          ),
          body: Consumer<AssetProvider>(
            builder: (context, assetProvider, child) {
              final filteredAssets = _getFilteredAssets(assetProvider.assets);

              return Column(
                children: [
                  // 总览卡片 - 恢复视觉效果
                  const AssetListOverviewCard(),

                  // 资产分布卡片
                  const AssetDistributionCard(),

                  SizedBox(height: context.responsiveSpacing16),

                  // 类别切换标签栏 - 恢复视觉效果
                  Padding(
                    padding:
                        EdgeInsets.only(bottom: context.responsiveSpacing16),
                    child: AssetCategoryTabBar(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: _onCategorySelected,
                    ),
                  ),

                  // 资产列表 - 移除动画
                  Expanded(
                    child: filteredAssets.isEmpty
                        ? _buildEmptyState()
                        : _buildAssetList(filteredAssets),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: _buildFloatingActionButton(),
        ),
      );

  // 构建资产列表
  Widget _buildAssetList(List<AssetItem> assets) => ListView.builder(
        padding: EdgeInsets.only(bottom: context.responsiveSpacing32),
        itemCount: assets.length,
        itemExtent: 180, // 为趋势图预留足够空间
        cacheExtent: 500, // 增加缓存范围
        itemBuilder: (context, index) {
          // 完全移除动画，直接渲染
          return AssetListItem(
            asset: assets[index],
            onTap: () => _onAssetTap(context, assets[index]),
          );
        },
      );

  // 处理资产点击事件
  void _onAssetTap(BuildContext context, AssetItem asset) {
    if (asset.isFixedAsset) {
      // 固定资产跳转到详细设置页面
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => FixedAssetDetailScreen(asset: asset),
        ),
      );
    } else {
      // 其他资产显示简单信息
      // 静默处理，不显示提示框
    }
  }

  // 构建空状态
  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: context.secondaryText,
            ),
            SizedBox(height: context.responsiveSpacing16),
            Text(
              _selectedCategory == null
                  ? '暂无资产记录'
                  : '暂无${_selectedCategory!.displayName}',
              style: context.responsiveHeadlineMedium.copyWith(
                color: context.secondaryText,
              ),
            ),
            SizedBox(height: context.responsiveSpacing8),
            Text(
              '点击右下角按钮添加第一个资产',
              style: context.responsiveBodyMedium.copyWith(
                color: context.secondaryText,
              ),
            ),
          ],
        ),
      );

  // 构建浮动按钮
  Widget _buildFloatingActionButton() => Builder(
        builder: (context) => EnhancedFloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              AppAnimations.createRoute(
                const AddAssetFlowScreen(),
              ),
            );
          },
          tooltip: '添加资产',
          backgroundColor: context.primaryAction,
          foregroundColor: Colors.white,
        ),
      );

  // 获取过滤后的资产列表
  List<AssetItem> _getFilteredAssets(List<AssetItem> assets) {
    if (_selectedCategory == null) {
      return assets;
    }
    return assets
        .where((asset) => asset.category == _selectedCategory)
        .toList();
  }

  // 类别选择回调
  void _onCategorySelected(AssetCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
  }
}
