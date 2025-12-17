import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';
import 'package:your_finance_flutter/core/services/ai/asset_valuation_service.dart';
import 'package:your_finance_flutter/core/services/ai/image_processing_service.dart';

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
    IOSAnimationSystem.registerCustomCurve(
        'asset-edit-focus', Curves.easeInOutCubic);
    IOSAnimationSystem.registerCustomCurve(
        'asset-edit-validation', Curves.elasticOut);
    IOSAnimationSystem.registerCustomCurve(
        'asset-edit-success', Curves.elasticOut);

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '名称',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    tooltip: '拍照估值',
                    onPressed: _valuateAsset,
                  ),
                ],
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

  /// 资产照片估值
  Future<void> _valuateAsset() async {
    try {
      // 1. 选择图片
      final imageService = ImageProcessingService.getInstance();
      final imageFile = await imageService.pickImageFromGallery();
      if (imageFile == null) return;

      // 2. 保存图片
      final imagePath = await imageService.saveImageToAppDirectory(imageFile);

      // 3. 显示加载对话框
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 4. 识别并估值
      final service = await AssetValuationService.getInstance();
      final result = await service.valuateAsset(imagePath: imagePath);

      // 5. 关闭加载对话框
      if (mounted) {
        Navigator.of(context).pop();
      }

      // 6. 填充表单字段（只填充名称，金额需要用户手动输入）
      setState(() {
        _nameController.text = result.assetName;
        // 不自动填充金额，让用户手动输入
      });

      // 7. 显示识别结果对话框
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('识别成功'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('品牌: ${result.brand}'),
                Text('型号: ${result.model}'),
                Text('置信度: ${(result.confidence * 100).toStringAsFixed(0)}%'),
                const SizedBox(height: 8),
                const Text(
                  '提示: 请手动输入资产金额',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确认'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // 关闭加载对话框（如果还在显示）
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('估值失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
