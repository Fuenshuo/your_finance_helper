import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/asset_provider.dart';
import '../models/asset_item.dart';
import 'add_asset_flow_screen.dart';
import 'edit_asset_sheet.dart';

class AssetManagementScreen extends StatelessWidget {
  const AssetManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('资产管理'),
        actions: [
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '暂无资产数据',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
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
