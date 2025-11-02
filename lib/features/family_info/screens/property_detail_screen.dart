import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/mortgage_calculator_screen.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';

class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({
    required this.asset,
    super.key,
    this.onPropertySaved,
  });
  final AssetItem asset;
  final void Function(AssetItem)? onPropertySaved;

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late AssetItem _property;
  final _formKey = GlobalKey<FormState>();

  // 表单控制器
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _currentValueController;
  late TextEditingController _depreciationRateController;
  late TextEditingController _idleValueController;
  late TextEditingController _notesController;
  late TextEditingController _addressController;
  late TextEditingController _areaController;
  late TextEditingController _purchaseYearController;

  // 状态变量
  late DepreciationMethod _depreciationMethod;
  late DateTime? _purchaseDate;
  late bool _isIdle;
  late String _propertyType;
  late String _propertyUsage;

  @override
  void initState() {
    super.initState();
    _property = widget.asset;
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: _property.name);
    _amountController =
        TextEditingController(text: _property.amount.toString());
    _currentValueController = TextEditingController(
      text: _property.currentValue?.toString() ?? '',
    );
    _depreciationRateController = TextEditingController(
      text: _property.depreciationRate?.toString() ?? '',
    );
    _idleValueController = TextEditingController(
      text: _property.idleValue?.toString() ?? '',
    );

    _depreciationMethod = _property.depreciationMethod;
    _purchaseDate = _property.purchaseDate;
    _isIdle = _property.isIdle;
    _propertyType = '住宅';
    _propertyUsage = '自住';

    // 从 notes 字段中解析房产详细信息
    _loadPropertyDetailsFromNotes();
  }

  void _loadPropertyDetailsFromNotes() {
    _addressController = TextEditingController();
    _areaController = TextEditingController();
    _purchaseYearController = TextEditingController();
    _notesController = TextEditingController();

    if (_property.notes != null && _property.notes!.isNotEmpty) {
      try {
        // 尝试解析 JSON 格式的房产详细信息
        if (_property.notes!.startsWith('{"propertyDetails":')) {
          // 首先尝试解析为标准JSON格式
          try {
            final notesData =
                jsonDecode(_property.notes!) as Map<String, dynamic>;
            final propertyDetails =
                notesData['propertyDetails'] as Map<String, dynamic>;

            _addressController.text =
                (propertyDetails['address'] ?? '').toString();
            _areaController.text = (propertyDetails['area'] ?? '').toString();
            _purchaseYearController.text =
                (propertyDetails['purchaseYear'] ?? '').toString();
            _propertyType =
                (propertyDetails['propertyType'] ?? '住宅').toString();
            _propertyUsage =
                (propertyDetails['propertyUsage'] ?? '自住').toString();
            _notesController.text = (propertyDetails['notes'] ?? '').toString();
          } catch (jsonError) {
            // 如果JSON解析失败，尝试解析旧的Map.toString()格式
            Logger.debug('🔄 尝试解析旧格式房产数据');
            final notesStr =
                _property.notes!.substring(19); // 移除 '{"propertyDetails":'
            final endIndex = notesStr.lastIndexOf('}');
            if (endIndex > 0) {
              final detailsStr = notesStr.substring(0, endIndex);
              final detailsMap = _parseOldPropertyDetails(detailsStr);

              _addressController.text = detailsMap['address'] ?? '';
              _areaController.text = detailsMap['area'] ?? '';
              _purchaseYearController.text = detailsMap['purchaseYear'] ?? '';
              _propertyType = detailsMap['propertyType'] ?? '住宅';
              _propertyUsage = detailsMap['propertyUsage'] ?? '自住';
              _notesController.text = detailsMap['notes'] ?? '';
            }
          }
        } else {
          // 如果不是 JSON 格式，直接作为备注使用
          _notesController.text = _property.notes!;
        }
      } catch (e) {
        Logger.debug('❌ 解析房产详细信息失败: $e');
        // 如果解析失败，使用原始的 notes 内容
        _notesController.text = _property.notes!;
      }
    }
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

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _currentValueController.dispose();
    _depreciationRateController.dispose();
    _idleValueController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _purchaseYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: const Text('房产详细信息'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _saveProperty,
              child: const Text('保存'),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 房产基本信息
                _buildPropertyBasicInfoSection(),
                const SizedBox(height: 16),

                // 房产详细信息
                _buildPropertyDetailsSection(),
                const SizedBox(height: 16),

                // 价值管理
                _buildValueManagementSection(),
                const SizedBox(height: 16),

                // 房贷计算器
                _buildMortgageCalculatorSection(),
                const SizedBox(height: 16),

                // 备注信息
                _buildNotesSection(),
                const SizedBox(height: 32),

                // 保存按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProperty,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('保存房产信息'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildPropertyBasicInfoSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '房产基本信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '房产名称',
                  hintText: '如：XX小区X号楼X单元',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入房产名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: '详细地址',
                  hintText: '如：北京市朝阳区XX路XX号',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _areaController,
                      decoration: const InputDecoration(
                        labelText: '建筑面积 (㎡)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _purchaseYearController,
                      decoration: const InputDecoration(
                        labelText: '购买年份',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildPropertyDetailsSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '房产类型',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _propertyType,
                      decoration: const InputDecoration(
                        labelText: '房产类型',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: '住宅', child: Text('住宅')),
                        DropdownMenuItem(value: '商业', child: Text('商业')),
                        DropdownMenuItem(value: '办公', child: Text('办公')),
                        DropdownMenuItem(value: '工业', child: Text('工业')),
                        DropdownMenuItem(value: '其他', child: Text('其他')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _propertyType = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _propertyUsage,
                      decoration: const InputDecoration(
                        labelText: '使用性质',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: '自住', child: Text('自住')),
                        DropdownMenuItem(value: '投资', child: Text('投资')),
                        DropdownMenuItem(value: '出租', child: Text('出租')),
                        DropdownMenuItem(value: '闲置', child: Text('闲置')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _propertyUsage = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildValueManagementSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '价值管理',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: '购买价格 (¥)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入购买价格';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return '请输入有效的金额';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentValueController,
                decoration: const InputDecoration(
                  labelText: '当前市场价值 (¥)',
                  hintText: '可选，用于手动更新价值',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<DepreciationMethod>(
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
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _depreciationRateController,
                      decoration: const InputDecoration(
                        labelText: '年折旧率 (%)',
                        hintText: '如：2',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: _depreciationMethod ==
                          DepreciationMethod.smartEstimate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildMortgageCalculatorSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '房贷计算器',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      final propertyValue =
                          double.tryParse(_amountController.text);
                      if (propertyValue != null && propertyValue > 0) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => MortgageCalculatorScreen(
                              propertyValue: propertyValue,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('请先输入购买价格'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.calculate),
                    label: const Text('计算房贷'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '使用房贷计算器来规划您的购房贷款方案',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
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
                '备注信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  hintText: '如：学区房、地铁口、装修情况等',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      );

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) {
      Logger.debug('❌ PropertyDetailScreen: 表单验证失败');
      return;
    }

    Logger.debug('💾 PropertyDetailScreen: 开始保存房产');
    Logger.debug(
      '💾 PropertyDetailScreen: 原资产ID: ${_property.id}, 名称: ${_property.name}',
    );

    try {
      // 收集房产详细信息
      final propertyDetails = {
        'address': _addressController.text,
        'area': _areaController.text,
        'purchaseYear': _purchaseYearController.text,
        'propertyType': _propertyType,
        'propertyUsage': _propertyUsage,
        'notes': _notesController.text,
      };

      // 将房产详细信息序列化为 JSON 字符串存储在 notes 字段中
      final propertyDetailsJson = jsonEncode(propertyDetails);
      final notesJson = '{"propertyDetails": $propertyDetailsJson}';

      final updatedProperty = _property.copyWith(
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
        notes: notesJson, // 存储房产详细信息
        updateDate: DateTime.now(),
      );

      Logger.debug(
        '💾 PropertyDetailScreen: 更新后资产 - ID: ${updatedProperty.id}, 名称: ${updatedProperty.name}, 金额: ${updatedProperty.amount}',
      );
      Logger.debug('💾 PropertyDetailScreen: 房产详情: $notesJson');

      if (widget.onPropertySaved != null) {
        Logger.debug('💾 PropertyDetailScreen: 调用onPropertySaved回调');
        widget.onPropertySaved!(updatedProperty);
        Logger.debug('✅ PropertyDetailScreen: onPropertySaved回调调用完成');
      } else {
        Logger.debug('⚠️ PropertyDetailScreen: onPropertySaved回调为空');
      }

      if (mounted) {
        Logger.debug('🏠 PropertyDetailScreen: 关闭PropertyDetailScreen');
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('房产信息保存成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      Logger.debug('❌ PropertyDetailScreen: 保存失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存失败，请重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
