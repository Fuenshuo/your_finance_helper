import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/providers/asset_provider.dart';
import 'package:your_finance_flutter/screens/add_asset_sheet.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';

class AddAssetFlowScreen extends StatefulWidget {
  const AddAssetFlowScreen({
    super.key,
    this.existingAssets,
    this.isUpdateMode = false,
  });
  final List<AssetItem>? existingAssets;
  final bool isUpdateMode;

  @override
  State<AddAssetFlowScreen> createState() => _AddAssetFlowScreenState();
}

class _AddAssetFlowScreenState extends State<AddAssetFlowScreen> {
  int _currentStep = 0;
  final List<AssetItem> _tempAssets = [];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // 如果是更新模式，加载现有资产数据
    if (widget.isUpdateMode && widget.existingAssets != null) {
      _tempAssets.addAll(widget.existingAssets!);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const categories = AssetCategory.values;
    final currentCategory = categories[_currentStep];

    return Scaffold(
      backgroundColor: context.primaryBackground,
      appBar: AppBar(
        title: Text(
          '${widget.isUpdateMode ? '更新' : '添加'}${currentCategory.displayName} (${_currentStep + 1}/${categories.length})',
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // 进度指示器
          Container(
            padding: EdgeInsets.all(context.spacing16),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / categories.length,
              backgroundColor: context.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(context.primaryAction),
            ),
          ),

          // 步骤内容
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              itemCount: categories.length,
              itemBuilder: (context, index) =>
                  _buildCategoryPage(categories[index]),
            ),
          ),

          // 底部按钮
          Container(
            padding: EdgeInsets.all(context.spacing16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('上一步'),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: context.spacing16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep < categories.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : () => _finishFlow(context),
                    child: Text(
                      _currentStep < categories.length - 1 ? '下一步' : '完成',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPage(AssetCategory category) {
    final categoryAssets =
        _tempAssets.where((asset) => asset.category == category).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标题和说明
          Text(
            category.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            category.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),

          // 已添加的资产列表
          if (categoryAssets.isNotEmpty) ...[
            Text(
              '已添加的${category.displayName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: categoryAssets.length,
                itemBuilder: (context, index) {
                  final asset = categoryAssets[index];
                  return Card(
                    child: ListTile(
                      title: Text(asset.name),
                      subtitle: Text(asset.subCategory),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '¥${asset.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: category == AssetCategory.liabilities
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _tempAssets.remove(asset);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '还没有添加${category.displayName}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),

          // 添加按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddAssetSheet(category),
              icon: const Icon(Icons.add),
              label: Text('添加${category.displayName}'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAssetSheet(AssetCategory category) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddAssetSheet(
        category: category,
        onAssetAdded: (asset) {
          setState(() {
            _tempAssets.add(asset);
          });
        },
      ),
    );
  }

  void _finishFlow(BuildContext context) {
    final assetProvider = Provider.of<AssetProvider>(context, listen: false);

    if (widget.isUpdateMode) {
      // 更新模式：直接用当前资产覆盖所有现有资产
      assetProvider.replaceAllAssets(_tempAssets);
    } else {
      // 新增模式：添加新资产
      for (final asset in _tempAssets) {
        assetProvider.addAsset(asset);
      }
    }

    Navigator.of(context).pop();
  }
}
