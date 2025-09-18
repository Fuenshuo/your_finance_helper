import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';

class FixedAssetDetailScreen extends StatefulWidget {
  const FixedAssetDetailScreen({
    required this.asset,
    super.key,
    this.onAssetSaved,
  });
  final AssetItem asset;
  final void Function(AssetItem)? onAssetSaved;

  @override
  State<FixedAssetDetailScreen> createState() => _FixedAssetDetailScreenState();
}

class _FixedAssetDetailScreenState extends State<FixedAssetDetailScreen> {
  late AssetItem _asset;
  final _formKey = GlobalKey<FormState>();

  // 表单控制器
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _currentValueController;
  late TextEditingController _depreciationRateController;
  late TextEditingController _idleValueController;
  late TextEditingController _notesController;

  // 状态变量
  late DepreciationMethod _depreciationMethod;
  late DateTime? _purchaseDate;
  late bool _isIdle;

  @override
  void initState() {
    super.initState();
    _asset = widget.asset;
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: _asset.name);
    _amountController = TextEditingController(text: _asset.amount.toString());
    _currentValueController = TextEditingController(
      text: _asset.currentValue?.toString() ?? '',
    );
    _depreciationRateController = TextEditingController(
      text: _asset.depreciationRate?.toString() ?? '',
    );
    _idleValueController = TextEditingController(
      text: _asset.idleValue?.toString() ?? '',
    );
    _notesController = TextEditingController(text: _asset.notes ?? '');

    _depreciationMethod = _asset.depreciationMethod;
    _purchaseDate = _asset.purchaseDate;
    _isIdle = _asset.isIdle;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _currentValueController.dispose();
    _depreciationRateController.dispose();
    _idleValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('固定资产详情'),
          actions: [
            TextButton(
              onPressed: _saveAsset,
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),
                      _buildDepreciationSection(),
                      const SizedBox(height: 24),
                      _buildIdleSection(),
                      const SizedBox(height: 24),
                      _buildNotesSection(),
                      const SizedBox(height: 24),
                      _buildCalculatedValuesSection(),
                      const SizedBox(height: 100), // 为底部按钮留出空间
                    ],
                  ),
                ),
              ),
              // 底部保存按钮
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveAsset,
                      icon: const Icon(Icons.save),
                      label: const Text('保存资产信息'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildBasicInfoSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '基本信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '资产名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入资产名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: '原始价值 (¥)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入原始价值';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return '请输入有效的金额';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      );

  Widget _buildDepreciationSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '折旧设置',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DepreciationMethod>(
                value: _depreciationMethod,
                decoration: const InputDecoration(
                  labelText: '折旧方式',
                  border: OutlineInputBorder(),
                ),
                items: DepreciationMethod.values
                    .map(
                      (method) => DropdownMenuItem(
                        value: method,
                        child: Text(method.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _depreciationMethod = value!;
                    if (value == DepreciationMethod.smartEstimate) {
                      _depreciationRateController.text =
                          _asset.getDefaultDepreciationRate().toString();
                    }
                  });
                },
              ),
              if (_depreciationMethod == DepreciationMethod.smartEstimate) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _depreciationRateController,
                  decoration: const InputDecoration(
                    labelText: '年折旧率 (%)',
                    border: OutlineInputBorder(),
                    helperText: '例如：15 表示每年折旧15%',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_depreciationMethod ==
                        DepreciationMethod.smartEstimate) {
                      if (value == null || value.isEmpty) {
                        return '请输入年折旧率';
                      }
                      final rate = double.tryParse(value);
                      if (rate == null || rate < 0 || rate > 100) {
                        return '请输入有效的折旧率 (0-100)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectPurchaseDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '购入日期',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _purchaseDate != null
                          ? '${_purchaseDate!.year}-${_purchaseDate!.month.toString().padLeft(2, '0')}-${_purchaseDate!.day.toString().padLeft(2, '0')}'
                          : '请选择购入日期',
                    ),
                  ),
                ),
              ],
              if (_depreciationMethod == DepreciationMethod.manualUpdate) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currentValueController,
                  decoration: const InputDecoration(
                    labelText: '当前价值 (¥)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_depreciationMethod ==
                        DepreciationMethod.manualUpdate) {
                      if (value == null || value.isEmpty) {
                        return '请输入当前价值';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount < 0) {
                        return '请输入有效的金额';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      );

  Widget _buildIdleSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '闲置管理',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('标记为闲置'),
                subtitle: const Text('闲置资产将使用闲置价值计算'),
                value: _isIdle,
                onChanged: (value) {
                  setState(() {
                    _isIdle = value;
                  });
                },
              ),
              if (_isIdle) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _idleValueController,
                  decoration: const InputDecoration(
                    labelText: '闲置价值 (¥)',
                    border: OutlineInputBorder(),
                    helperText: '预估的二手市场价值',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_isIdle) {
                      if (value == null || value.isEmpty) {
                        return '请输入闲置价值';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount < 0) {
                        return '请输入有效的金额';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      );

  Widget _buildNotesSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '备注',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '备注信息',
                  border: OutlineInputBorder(),
                  hintText: '可添加资产的相关说明...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      );

  Widget _buildCalculatedValuesSection() {
    final originalValue =
        double.tryParse(_amountController.text) ?? _asset.amount;
    final currentValue = _calculateCurrentValue();
    final depreciationAmount = originalValue - currentValue;
    final depreciationPercentage =
        originalValue > 0 ? (depreciationAmount / originalValue * 100) : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '计算结果',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildValueRow('原始价值', originalValue),
            _buildValueRow('当前价值', currentValue),
            _buildValueRow('折旧金额', depreciationAmount, isDepreciation: true),
            _buildValueRow(
              '折旧比例',
              depreciationPercentage.toDouble(),
              isPercentage: true,
            ),
            if (_depreciationMethod == DepreciationMethod.smartEstimate &&
                _purchaseDate != null) ...[
              const SizedBox(height: 8),
              _buildValueRow(
                '使用年限',
                DateTime.now().difference(_purchaseDate!).inDays / 365.25,
                suffix: '年',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValueRow(
    String label,
    double value, {
    bool isDepreciation = false,
    bool isPercentage = false,
    String? suffix,
  }) {
    Color? valueColor;
    if (isDepreciation && value > 0) {
      valueColor = Colors.red;
    } else if (isPercentage && value > 0) {
      valueColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            isPercentage
                ? '${value.toStringAsFixed(1)}%'
                : '¥${value.toStringAsFixed(0)}${suffix ?? ''}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateCurrentValue() {
    if (_isIdle) {
      return double.tryParse(_idleValueController.text) ?? 0;
    }

    if (_depreciationMethod == DepreciationMethod.manualUpdate) {
      return double.tryParse(_currentValueController.text) ?? 0;
    }

    if (_depreciationMethod == DepreciationMethod.smartEstimate &&
        _purchaseDate != null) {
      final rate =
          (double.tryParse(_depreciationRateController.text) ?? 0.0) / 100.0;
      final originalValue = double.tryParse(_amountController.text) ?? 0;

      if (rate > 0) {
        final yearsUsed =
            DateTime.now().difference(_purchaseDate!).inDays / 365.25;
        final depreciationAmount = originalValue * rate * yearsUsed;
        final depreciatedValue = originalValue - depreciationAmount;
        return depreciatedValue > 0 ? depreciatedValue : 0;
      }
    }

    return double.tryParse(_amountController.text) ?? 0;
  }

  Future<void> _selectPurchaseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _purchaseDate = date;
      });
    }
  }

  Future<void> _saveAsset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final updatedAsset = _asset.copyWith(
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        currentValue: _depreciationMethod == DepreciationMethod.manualUpdate
            ? double.tryParse(_currentValueController.text)
            : null,
        depreciationMethod: _depreciationMethod,
        depreciationRate:
            _depreciationMethod == DepreciationMethod.smartEstimate
                ? double.tryParse(_depreciationRateController.text)
                : null,
        purchaseDate: _purchaseDate,
        isIdle: _isIdle,
        idleValue: _isIdle ? double.tryParse(_idleValueController.text) : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        updateDate: DateTime.now(),
      );

      // 如果有回调函数，使用回调函数（用于添加新资产）
      if (widget.onAssetSaved != null) {
        widget.onAssetSaved!(updatedAsset);
      } else {
        // 否则使用Provider更新现有资产
        final assetProvider =
            Provider.of<AssetProvider>(context, listen: false);
        await assetProvider.updateAsset(updatedAsset);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // 静默处理错误，不显示提示框
    }
  }
}
