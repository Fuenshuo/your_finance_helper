import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/screens/fixed_asset_detail_screen.dart';
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
  String _selectedSubCategory = '';
  bool _isCustomInput = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
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

    final asset = AssetItem(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      category: widget.category,
      subCategory: subCategory,
      creationDate: DateTime.now(),
      updateDate: DateTime.now(),
    );

    // 如果是固定资产，跳转到详细设置页面
    if (widget.category == AssetCategory.fixedAssets) {
      Navigator.of(context).pop(); // 关闭当前页面
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
    } else {
      widget.onAssetAdded(asset);
      Navigator.of(context).pop();
      _showBudgetGuidance(asset);
    }
  }

  void _showBudgetGuidance(AssetItem asset) {
    // 延迟显示，确保当前页面已经关闭
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
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
