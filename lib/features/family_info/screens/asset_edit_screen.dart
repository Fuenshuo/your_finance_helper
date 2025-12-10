import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/amount_input_field.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

/// 资产编辑页面
class AssetEditScreen extends StatefulWidget {
  const AssetEditScreen({
    required this.asset,
    super.key,
  });

  final AssetItem asset;

  @override
  State<AssetEditScreen> createState() => _AssetEditScreenState();
}

class _AssetEditScreenState extends State<AssetEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _subCategoryController;
  late final TextEditingController _notesController;

  late AssetCategory _selectedCategory;
  late String _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.asset.name);
    _amountController =
        TextEditingController(text: widget.asset.amount.toString());
    _descriptionController =
        TextEditingController(text: widget.asset.notes ?? '');
    _subCategoryController =
        TextEditingController(text: widget.asset.subCategory);
    _notesController = TextEditingController(text: widget.asset.notes ?? '');

    _selectedCategory = widget.asset.category;
    _selectedSubCategory = widget.asset.subCategory;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _subCategoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '编辑资产',
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _saveAsset,
              child: Text(
                '保存',
                style: TextStyle(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.responsiveSpacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 资产信息卡片
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📋 资产信息',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing16),

                      // 资产名称
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '资产名称',
                          hintText: '请输入资产名称',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入资产名称';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: context.spacing16),

                      // 资产类别
                      DropdownButtonFormField<AssetCategory>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: '资产类别',
                          border: OutlineInputBorder(),
                        ),
                        items: AssetCategory.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                              // 重置子类别
                              _selectedSubCategory =
                                  _getDefaultSubCategory(value);
                              _subCategoryController.text =
                                  _selectedSubCategory;
                            });
                          }
                        },
                      ),

                      SizedBox(height: context.spacing16),

                      // 子类别
                      TextFormField(
                        controller: _subCategoryController,
                        decoration: const InputDecoration(
                          labelText: '子类别',
                          hintText: '请输入子类别',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _selectedSubCategory = value;
                        },
                      ),

                      SizedBox(height: context.spacing16),

                      // 资产金额
                      AmountInputField(
                        controller: _amountController,
                        labelText: '资产金额',
                        hintText: '请输入资产金额',
                        prefixIcon: const Icon(Icons.attach_money),
                      ),

                      SizedBox(height: context.spacing16),

                      // 描述
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: '描述（可选）',
                          hintText: '请输入资产描述',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing24),

                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _deleteAsset,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          '删除资产',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(
                            vertical: context.responsiveSpacing12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  String _getDefaultSubCategory(AssetCategory category) {
    switch (category) {
      case AssetCategory.liquidAssets:
        return '银行存款';
      case AssetCategory.realEstate:
        return '商品房';
      case AssetCategory.investments:
        return '股票';
      case AssetCategory.consumptionAssets:
        return '电子产品';
      case AssetCategory.receivables:
        return '个人借款';
      case AssetCategory.liabilities:
        return '信用卡';
    }
  }

  Future<void> _saveAsset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text);
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的金额')),
      );
      return;
    }

    // 创建更新后的资产对象
    final updatedAsset = widget.asset.copyWith(
      name: name,
      category: _selectedCategory,
      subCategory: _selectedSubCategory,
      amount: amount,
      notes: description,
    );

    try {
      final assetProvider = context.read<AssetProvider>();
      await assetProvider.updateAsset(updatedAsset);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('资产更新成功')),
        );
        Navigator.of(context).pop(true); // 返回true表示有更新
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: $e')),
        );
      }
    }
  }

  Future<void> _deleteAsset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除资产"${widget.asset.name}"吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        final assetProvider = context.read<AssetProvider>();
        await assetProvider.deleteAsset(widget.asset.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('资产删除成功')),
          );
          Navigator.of(context).pop(true); // 返回true表示有更新
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }
}
