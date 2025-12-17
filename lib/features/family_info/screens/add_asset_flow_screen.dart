import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';
import 'package:your_finance_flutter/features/family_info/screens/add_asset_sheet.dart';
import 'package:your_finance_flutter/features/family_info/screens/edit_asset_sheet.dart';
import 'package:your_finance_flutter/features/family_info/screens/property_detail_screen.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';

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
                                  color: _getAssetIconColor(category)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _getAssetIcon(asset),
                                  color: _getAssetIconColor(category),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  asset.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              Text(
                                '¥${asset.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: category == AssetCategory.liabilities
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editAsset(context, asset),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _tempAssets.remove(asset);
                                  });
                                },
                              ),
                            ],
                          ),
                          // 第三行：录入时间（突出显示）
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
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
                                  size: 12,
                                  color: Colors.red.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatCreationDate(asset.creationDate),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.red[700],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          // 第四行：备注信息（如果有的话）
                          if (_buildAssetSubtitle(asset) != null) ...[
                            const SizedBox(height: 6),
                            _buildAssetSubtitle(asset)!,
                          ],
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
    Logger.debug(
        '📋 AddAssetFlowScreen: 显示添加资产表单 - 分类: ${category.displayName}');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddAssetSheet(
        category: category,
        onAssetAdded: (asset) {
          Logger.debug(
            '📋 AddAssetFlowScreen: 收到新资产 - 名称: ${asset.name}, ID: ${asset.id}, 分类: ${asset.category.displayName}',
          );
          Logger.debug(
              '📋 AddAssetFlowScreen: 添加前临时资产数量: ${_tempAssets.length}');
          setState(() {
            _tempAssets.add(asset);
          });
          Logger.debug(
              '📋 AddAssetFlowScreen: 添加后临时资产数量: ${_tempAssets.length}');
        },
      ),
    );
  }

  void _editAsset(BuildContext context, AssetItem asset) {
    Logger.debug(
      '📋 AddAssetFlowScreen: 开始编辑资产 - 名称: ${asset.name}, 分类: ${asset.category.displayName}',
    );

    // 对于固定资产且为房产类，提供详细编辑选项
    if (asset.category == AssetCategory.realEstate && _isPropertyAsset(asset)) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => _buildFixedAssetEditOptions(context, asset),
      );
    } else {
      // 对于其他资产，使用简单编辑表单
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => EditAssetSheet(
          asset: asset,
          onAssetUpdated: (updatedAsset) {
            Logger.debug(
                '📋 AddAssetFlowScreen: 资产已更新 - 名称: ${updatedAsset.name}');
            setState(() {
              final index = _tempAssets.indexWhere((a) => a.id == asset.id);
              if (index != -1) {
                _tempAssets[index] = updatedAsset;
              }
            });
          },
        ),
      );
    }
  }

  Widget _buildFixedAssetEditOptions(BuildContext context, AssetItem asset) =>
      Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择编辑方式',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '您可以选择快速编辑或详细编辑来修改您的房产资产',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // 快速编辑选项
            _buildEditOption(
              context,
              icon: Icons.edit,
              title: '快速编辑',
              subtitle: '修改基本信息（名称、金额等）',
              onTap: () {
                Navigator.of(context).pop();
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => EditAssetSheet(
                    asset: asset,
                    onAssetUpdated: (updatedAsset) {
                      Logger.debug(
                        '📋 AddAssetFlowScreen: 房产快速编辑完成 - 名称: ${updatedAsset.name}',
                      );
                      setState(() {
                        final index =
                            _tempAssets.indexWhere((a) => a.id == asset.id);
                        if (index != -1) {
                          _tempAssets[index] = updatedAsset;
                        }
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // 房产详细编辑选项
            _buildEditOption(
              context,
              icon: Icons.home,
              title: '房产详细编辑',
              subtitle: '完整的房产信息编辑，包括地址、面积等',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => PropertyDetailScreen(
                      asset: asset,
                      onPropertySaved: (savedAsset) {
                        Logger.debug(
                          '📋 AddAssetFlowScreen: 房产详细编辑完成 - 名称: ${savedAsset.name}',
                        );
                        setState(() {
                          final index =
                              _tempAssets.indexWhere((a) => a.id == asset.id);
                          if (index != -1) {
                            _tempAssets[index] = savedAsset;
                          }
                        });
                        Navigator.of(context).pop(); // 返回到添加资产流程
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('房产信息已更新'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // 取消按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
            ),
          ],
        ),
      );

  Widget _buildEditOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue,
                  size: 24,
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
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

  Widget? _buildAssetSubtitle(AssetItem asset) {
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

    // 对于普通资产，显示原始的 notes
    if (asset.notes != null && asset.notes!.isNotEmpty) {
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
              Icons.note_outlined,
              size: 14,
              color: Colors.blue,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                asset.notes!,
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

    return null;
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
            infoParts.add(address as String);
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

  void _finishFlow(BuildContext context) {
    Logger.debug('🏁 AddAssetFlowScreen: 开始完成流程');
    Logger.debug('🏁 AddAssetFlowScreen: 临时资产数量: ${_tempAssets.length}');
    for (var i = 0; i < _tempAssets.length; i++) {
      final asset = _tempAssets[i];
      Logger.debug(
        '🏁 AddAssetFlowScreen: 临时资产${i + 1}: ${asset.name} - ${asset.amount} (${asset.category.displayName})',
      );
    }

    final assetProvider = Provider.of<AssetProvider>(context, listen: false);

    if (widget.isUpdateMode) {
      Logger.debug('🔄 AddAssetFlowScreen: 更新模式 - 替换所有资产');
      // 更新模式：直接用当前资产覆盖所有现有资产
      assetProvider.replaceAllAssets(_tempAssets);
    } else {
      Logger.debug('➕ AddAssetFlowScreen: 新增模式 - 添加新资产');
      // 新增模式：添加新资产
      for (final asset in _tempAssets) {
        Logger.debug('➕ AddAssetFlowScreen: 添加资产: ${asset.name}');
        assetProvider.addAsset(asset);
      }
    }

    Logger.debug('✅ AddAssetFlowScreen: 流程完成，准备返回');
    Navigator.of(context).pop();
  }

  IconData _getAssetIcon(AssetItem asset) {
    // 根据资产类型和子分类返回对应的图标
    if (_isPropertyAsset(asset)) {
      return Icons.home_outlined;
    }

    switch (asset.category) {
      case AssetCategory.liquidAssets:
        if (asset.subCategory.contains('银行') ||
            asset.subCategory.contains('存款')) {
          return Icons.account_balance_outlined;
        } else if (asset.subCategory.contains('现金') ||
            asset.subCategory.contains('钱包')) {
          return Icons.wallet_outlined;
        } else if (asset.subCategory.contains('基金') ||
            asset.subCategory.contains('股票')) {
          return Icons.trending_up_outlined;
        } else if (asset.subCategory.contains('理财') ||
            asset.subCategory.contains('保险')) {
          return Icons.shield_outlined;
        }
        return Icons.monetization_on_outlined;

      case AssetCategory.realEstate:
        if (asset.subCategory.contains('车')) {
          return Icons.directions_car_outlined;
        } else if (asset.subCategory.contains('黄金') ||
            asset.subCategory.contains('珠宝')) {
          return Icons.diamond_outlined;
        } else if (asset.subCategory.contains('收藏') ||
            asset.subCategory.contains('艺术')) {
          return Icons.palette_outlined;
        }
        return Icons.inventory_2_outlined;

      case AssetCategory.investments:
        if (asset.subCategory.contains('基金') ||
            asset.subCategory.contains('股票')) {
          return Icons.trending_up_outlined;
        } else if (asset.subCategory.contains('债券')) {
          return Icons.receipt_long_outlined;
        } else if (asset.subCategory.contains('外汇')) {
          return Icons.currency_exchange_outlined;
        } else if (asset.subCategory.contains('期货') ||
            asset.subCategory.contains('期权')) {
          return Icons.show_chart_outlined;
        }
        return Icons.business_center_outlined;

      case AssetCategory.liabilities:
        if (asset.subCategory.contains('房贷') ||
            asset.subCategory.contains('房')) {
          return Icons.home_work_outlined;
        } else if (asset.subCategory.contains('车贷') ||
            asset.subCategory.contains('车')) {
          return Icons.directions_car_outlined;
        } else if (asset.subCategory.contains('信用卡')) {
          return Icons.credit_card_outlined;
        } else if (asset.subCategory.contains('消费贷') ||
            asset.subCategory.contains('个人贷')) {
          return Icons.account_balance_wallet_outlined;
        }
        return Icons.account_balance_outlined;

      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _getAssetIconColor(AssetCategory category) {
    // 根据资产类型返回对应的颜色
    switch (category) {
      case AssetCategory.liquidAssets:
        return const Color(0xFF4ECDC4); // 青色
      case AssetCategory.realEstate:
        return const Color(0xFF96CEB4); // 绿色
      case AssetCategory.investments:
        return const Color(0xFFF7DC6F); // 金色
      case AssetCategory.liabilities:
        return const Color(0xFFBB8FCE); // 紫色
      default:
        return const Color(0xFF4ECDC4); // 默认青色
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
