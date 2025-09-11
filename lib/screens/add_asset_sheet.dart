import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/screens/fixed_asset_detail_screen.dart';
import 'package:your_finance_flutter/screens/property_detail_screen.dart';
import 'package:your_finance_flutter/screens/smart_budget_guidance_screen.dart';

class AddAssetSheet extends StatefulWidget {
  const AddAssetSheet({
    required this.category,
    required this.onAssetAdded,
    super.key,
  });
  final AssetCategory category;
  final void Function(AssetItem) onAssetAdded;

  @override
  State<AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<AddAssetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedSubCategory = '';
  bool _isCustomInput = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                '添加${widget.category.displayName}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // 子分类选择
              Text(
                '选择类型',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...widget.category.subCategories.map((subCategory) {
                    final isSelected =
                        _selectedSubCategory == subCategory && !_isCustomInput;
                    return FilterChip(
                      label: Text(subCategory),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSubCategory = subCategory;
                            _isCustomInput = false;
                            _nameController.clear();
                          } else {
                            _selectedSubCategory = '';
                          }
                        });
                      },
                    );
                  }),
                  FilterChip(
                    label: const Text('自定义'),
                    selected: _isCustomInput,
                    onSelected: (selected) {
                      setState(() {
                        _isCustomInput = selected;
                        if (selected) {
                          _selectedSubCategory = '';
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 自定义名称输入
              if (_isCustomInput) ...[
                Text(
                  '自定义名称',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: '请输入名称',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_isCustomInput && (value == null || value.isEmpty)) {
                      return '请输入名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // 金额输入
              Text(
                '金额',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: const InputDecoration(
                  hintText: '请输入金额',
                  border: OutlineInputBorder(),
                  prefixText: '¥ ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入金额';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return '请输入有效的金额';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 备注输入
              Text(
                '备注（可选）',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '添加备注信息，帮助区分不同的资产...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // 按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAsset,
                      child: Text(
                        widget.category == AssetCategory.fixedAssets
                            ? '下一步'
                            : '保存',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  void _saveAsset() {
    if (!_formKey.currentState!.validate()) return;

    // 验证是否选择了子分类
    if (!_isCustomInput && _selectedSubCategory.isEmpty) {
      // 静默验证，不显示提示框
      return;
    }

    final name = _isCustomInput ? _nameController.text : _selectedSubCategory;
    final subCategory = _isCustomInput ? '自定义' : _selectedSubCategory;
    final amount = double.parse(_amountController.text);

    print(
      '🔧 AddAssetSheet: 创建资产 - 名称: $name, 金额: $amount, 分类: ${widget.category.displayName}, 子分类: $subCategory',
    );

    final asset = AssetItem(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      category: widget.category,
      subCategory: subCategory,
      creationDate: DateTime.now(),
      updateDate: DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    print('🔧 AddAssetSheet: 资产创建完成 - ID: ${asset.id}');

    // 如果是固定资产，提供详细录入选项
    if (widget.category == AssetCategory.fixedAssets) {
      print('🏠 AddAssetSheet: 检测到固定资产，准备显示详细录入选项');
      Navigator.of(context).pop(); // 关闭当前页面
      _showDetailedInputOptions(asset);
    } else {
      print('💰 AddAssetSheet: 普通资产，直接添加');
      widget.onAssetAdded(asset);
      Navigator.of(context).pop();
      _showBudgetGuidance(asset);
    }
  }

  void _showDetailedInputOptions(AssetItem asset) {
    print('📋 _showDetailedInputOptions: 开始执行');
    print(
      '📋 _showDetailedInputOptions: 资产名称: ${asset.name}, 子分类: ${asset.subCategory}',
    );
    print('📋 _showDetailedInputOptions: 是否为房产资产: ${_isPropertyAsset(asset)}');

    // 移除延迟，直接显示弹窗
    print('✅ 直接显示弹窗');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
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
              '选择录入方式',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '您可以选择快速录入或详细录入来管理您的固定资产',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // 快速录入选项
            _buildInputOption(
              context,
              icon: Icons.flash_on,
              title: '快速录入',
              subtitle: '使用通用固定资产录入，适合大多数资产',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => FixedAssetDetailScreen(
                      asset: asset,
                      onAssetSaved: (savedAsset) {
                        widget.onAssetAdded(savedAsset);
                        _showBudgetGuidance(savedAsset);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // 房产详细录入选项
            if (_isPropertyAsset(asset))
              _buildInputOption(
                context,
                icon: Icons.home,
                title: '房产详细录入',
                subtitle: '专门的房产录入，包含地址、面积、房贷计算等',
                onTap: () {
                  print(
                    '🏠 AddAssetSheet: 选择房产详细录入，导航到PropertyDetailScreen',
                  );
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => PropertyDetailScreen(
                        asset: asset,
                        onPropertySaved: (savedAsset) {
                          print(
                            '✅ AddAssetSheet: 房产保存回调被调用 - 资产: ${savedAsset.name}, ID: ${savedAsset.id}',
                          );
                          widget.onAssetAdded(savedAsset);
                          print('✅ AddAssetSheet: 已调用父级onAssetAdded回调');
                          _showBudgetGuidance(savedAsset);
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
      ),
    );
  }

  bool _isPropertyAsset(AssetItem asset) {
    // 判断是否为房产类资产
    final propertySubCategories = ['房产 (自住)', '房产 (投资)', '车位'];
    return propertySubCategories.contains(asset.subCategory) ||
        asset.name.contains('房产') ||
        asset.name.contains('房子') ||
        asset.name.contains('住宅') ||
        asset.name.contains('车位');
  }

  Widget _buildInputOption(
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
                  color: Colors.blue.withOpacity(0.1),
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

  void _showBudgetGuidance(AssetItem asset) {
    // 延迟显示，确保当前页面已经关闭
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => SmartBudgetGuidanceScreen(
              asset: asset,
              onComplete: () {
                // 预算建议完成后的回调
              },
            ),
          ),
        );
      }
    });
  }
}
