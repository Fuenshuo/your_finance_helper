import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';

class EditAssetSheet extends StatefulWidget {
  const EditAssetSheet({
    required this.asset,
    this.onAssetUpdated,
    super.key,
  });
  final AssetItem asset;
  final void Function(AssetItem)? onAssetUpdated;

  @override
  State<EditAssetSheet> createState() => _EditAssetSheetState();
}

class _EditAssetSheetState extends State<EditAssetSheet> {
  final _formKey = GlobalKey<FormState>();
  late final IOSAnimationSystem _animationSystem;
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _subCategoryController;

  @override
  void initState() {
    super.initState();

    // ===== v1.1.0 初始化企业级动效系统 =====
    _animationSystem = IOSAnimationSystem();

    // 注册资产编辑表单专用动效曲线
    IOSAnimationSystem.registerCustomCurve('asset-edit-focus', Curves.easeInOutCubic);
    IOSAnimationSystem.registerCustomCurve('asset-edit-validation', Curves.elasticOut);
    IOSAnimationSystem.registerCustomCurve('asset-edit-success', Curves.elasticOut);

    _nameController = TextEditingController(text: widget.asset.name);
    _amountController =
        TextEditingController(text: widget.asset.amount.toString());
    _subCategoryController =
        TextEditingController(text: widget.asset.subCategory);
  }

  @override
  void dispose() {
    _animationSystem.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _subCategoryController.dispose();
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
                '编辑资产',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // 名称输入
              Text(
                '名称',
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
                  if (value == null || value.isEmpty) {
                    return '请输入名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 子分类输入
              Text(
                '子分类',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subCategoryController,
                decoration: const InputDecoration(
                  hintText: '请输入子分类',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入子分类';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

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
                      onPressed: _saveChanges,
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final subCategory = _subCategoryController.text;
    final amount = double.parse(_amountController.text);

    final updatedAsset = widget.asset.copyWith(
      name: name,
      subCategory: subCategory,
      amount: amount,
      updateDate: DateTime.now(),
    );

    // 如果有回调，使用回调；否则使用默认的 asset provider 更新
    if (widget.onAssetUpdated != null) {
      widget.onAssetUpdated!(updatedAsset);
    } else {
      final assetProvider = Provider.of<AssetProvider>(context, listen: false);
      assetProvider.updateAsset(updatedAsset);
    }

    Navigator.of(context).pop();
    // 静默更新，不显示提示框
  }
}
