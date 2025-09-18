import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';

/// 资产估值设置屏幕
class AssetValuationSetupScreen extends StatefulWidget {
  const AssetValuationSetupScreen({
    required this.assetCategory,
    required this.subCategory,
    required this.purchaseAmount,
    required this.purchaseDate,
    super.key,
  });

  final AssetCategory assetCategory;
  final String subCategory;
  final double purchaseAmount;
  final DateTime purchaseDate;

  @override
  State<AssetValuationSetupScreen> createState() =>
      _AssetValuationSetupScreenState();
}

class _AssetValuationSetupScreenState extends State<AssetValuationSetupScreen> {
  DepreciationMethod _selectedMethod = DepreciationMethod.none;
  double _depreciationRate = 0.0;
  bool _useCustomRate = false;

  @override
  void initState() {
    super.initState();
    // 根据资产类型设置默认估值方式
    _setupDefaultValuation();
  }

  void _setupDefaultValuation() {
    switch (widget.assetCategory) {
      case AssetCategory.realEstate:
        // 房产默认手动更新
        _selectedMethod = DepreciationMethod.manualUpdate;
      case AssetCategory.consumptionAssets:
        // 消费资产默认智能估算
        _selectedMethod = DepreciationMethod.smartEstimate;
        _depreciationRate = _calculateSmartDepreciationRate();
      case AssetCategory.investments:
        // 投资资产默认手动更新
        _selectedMethod = DepreciationMethod.manualUpdate;
      default:
        _selectedMethod = DepreciationMethod.none;
    }
  }

  double _calculateSmartDepreciationRate() {
    // 根据子分类计算智能折旧率
    final years = widget.assetCategory.getDepreciationYears(widget.subCategory);
    if (years > 0) {
      return 1.0 / years; // 年折旧率
    }
    return 0.05; // 默认5%年折旧率
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: Text(
            '设置估值方式',
            style: context.textTheme.headlineMedium,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsiveSpacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 资产信息展示
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 资产信息',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing16),
                    _buildInfoRow('资产类型', widget.assetCategory.displayName),
                    SizedBox(height: context.spacing8),
                    _buildInfoRow('子分类', widget.subCategory),
                    SizedBox(height: context.spacing8),
                    _buildInfoRow(
                        '购入金额', '¥${widget.purchaseAmount.toStringAsFixed(2)}'),
                    SizedBox(height: context.spacing8),
                    _buildInfoRow('购入日期', _formatDate(widget.purchaseDate)),
                  ],
                ),
              ),

              SizedBox(height: context.spacing16),

              // 估值方式选择
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚙️ 估值方式',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing16),

                    // 估值方式选项
                    _buildValuationMethodOption(
                      method: DepreciationMethod.none,
                      title: '不设置估值',
                      subtitle: '仅记录购入价格，不进行动态估值',
                      icon: Icons.cancel,
                      color: Colors.grey,
                    ),

                    SizedBox(height: context.spacing12),

                    if (widget.assetCategory ==
                            AssetCategory.consumptionAssets ||
                        widget.assetCategory == AssetCategory.realEstate ||
                        widget.assetCategory == AssetCategory.investments)
                      _buildValuationMethodOption(
                        method: DepreciationMethod.smartEstimate,
                        title: '智能估算',
                        subtitle: _getSmartEstimateDescription(),
                        icon: Icons.smart_toy,
                        color: const Color(0xFF4CAF50),
                      ),

                    if (widget.assetCategory ==
                            AssetCategory.consumptionAssets ||
                        widget.assetCategory == AssetCategory.realEstate ||
                        widget.assetCategory == AssetCategory.investments)
                      SizedBox(height: context.spacing12),

                    _buildValuationMethodOption(
                      method: DepreciationMethod.manualUpdate,
                      title: '手动更新',
                      subtitle: '由您手动更新当前估值',
                      icon: Icons.edit,
                      color: const Color(0xFF2196F3),
                    ),

                    // 折旧率设置（仅对智能估算显示）
                    if (_selectedMethod == DepreciationMethod.smartEstimate &&
                        _depreciationRate > 0) ...[
                      SizedBox(height: context.spacing24),
                      Text(
                        '📉 折旧率设置',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: context.spacing16),

                      // 使用智能推荐还是自定义
                      SwitchListTile(
                        title: const Text('使用智能推荐折旧率'),
                        subtitle: Text(
                            '推荐年折旧率：${(_depreciationRate * 100).toStringAsFixed(1)}%'),
                        value: !_useCustomRate,
                        onChanged: (value) {
                          setState(() {
                            _useCustomRate = !value;
                          });
                        },
                      ),

                      if (_useCustomRate) ...[
                        SizedBox(height: context.spacing16),
                        TextFormField(
                          initialValue:
                              (_depreciationRate * 100).toStringAsFixed(1),
                          decoration: const InputDecoration(
                            labelText: '自定义年折旧率 (%)',
                            hintText: '5.0',
                            prefixIcon: Icon(Icons.percent),
                            suffixText: '%',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入折旧率';
                            }
                            final rate = double.tryParse(value);
                            if (rate == null || rate < 0 || rate > 100) {
                              return '请输入0-100之间的有效百分比';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            final rate = double.tryParse(value);
                            if (rate != null && rate >= 0 && rate <= 100) {
                              setState(() {
                                _depreciationRate = rate / 100;
                              });
                            }
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              SizedBox(height: context.spacing32),

              // 估值预览
              if (_selectedMethod != DepreciationMethod.none)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔍 估值预览',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing16),
                      _buildPreviewRow(
                        '购入价格',
                        '¥${widget.purchaseAmount.toStringAsFixed(2)}',
                        const Color(0xFF2196F3),
                      ),
                      if (_selectedMethod ==
                          DepreciationMethod.smartEstimate) ...[
                        SizedBox(height: context.spacing8),
                        _buildPreviewRow(
                          '当前估值',
                          '¥${_calculateCurrentValue().toStringAsFixed(2)}',
                          const Color(0xFF4CAF50),
                        ),
                        SizedBox(height: context.spacing8),
                        _buildPreviewRow(
                          '已折旧',
                          '¥${(widget.purchaseAmount - _calculateCurrentValue()).toStringAsFixed(2)}',
                          const Color(0xFFFF9800),
                        ),
                        SizedBox(height: context.spacing8),
                        _buildPreviewRow(
                          '折旧率',
                          '${(_depreciationRate * 100).toStringAsFixed(1)}%/年',
                          const Color(0xFF9C27B0),
                        ),
                      ] else if (_selectedMethod ==
                          DepreciationMethod.manualUpdate) ...[
                        SizedBox(height: context.spacing8),
                        _buildPreviewRow(
                          '当前估值',
                          '待手动更新',
                          const Color(0xFF9E9E9E),
                        ),
                      ],
                    ],
                  ),
                ),

              SizedBox(height: context.spacing32),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _saveValuationSettings(DepreciationMethod.none),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: context.responsiveSpacing16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              context.responsiveSpacing12),
                        ),
                      ),
                      child: const Text('跳过估值'),
                    ),
                  ),
                  SizedBox(width: context.spacing16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveValuationSettings(_selectedMethod),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryAction,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            vertical: context.responsiveSpacing16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              context.responsiveSpacing12),
                        ),
                      ),
                      child: const Text('保存设置'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.spacing32),
            ],
          ),
        ),
      );

  Widget _buildInfoRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.secondaryText,
            ),
          ),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );

  Widget _buildValuationMethodOption({
    required DepreciationMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) =>
      InkWell(
        onTap: () {
          setState(() {
            _selectedMethod = method;
            if (method == DepreciationMethod.smartEstimate) {
              _depreciationRate = _calculateSmartDepreciationRate();
            }
          });
        },
        borderRadius: BorderRadius.circular(context.responsiveSpacing12),
        child: Container(
          padding: EdgeInsets.all(context.responsiveSpacing16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedMethod == method ? color : context.dividerColor,
              width: _selectedMethod == method ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(context.responsiveSpacing12),
            color: _selectedMethod == method
                ? color.withOpacity(0.05)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(context.responsiveSpacing8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              SizedBox(width: context.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _selectedMethod == method
                            ? color
                            : context.primaryText,
                      ),
                    ),
                    SizedBox(height: context.spacing4),
                    Text(
                      subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<DepreciationMethod>(
                value: method,
                groupValue: _selectedMethod,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMethod = value;
                      if (value == DepreciationMethod.smartEstimate) {
                        _depreciationRate = _calculateSmartDepreciationRate();
                      }
                    });
                  }
                },
                activeColor: color,
              ),
            ],
          ),
        ),
      );

  Widget _buildPreviewRow(String label, String value, Color color) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.secondaryText,
            ),
          ),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );

  String _getSmartEstimateDescription() {
    switch (widget.assetCategory) {
      case AssetCategory.consumptionAssets:
        final years =
            widget.assetCategory.getDepreciationYears(widget.subCategory);
        return '根据${widget.subCategory}的典型使用寿命$years年自动计算折旧';
      case AssetCategory.realEstate:
        return '基于房产市场趋势估算增值';
      case AssetCategory.investments:
        return '根据投资标的的预期收益率估算';
      default:
        return '智能估算当前价值';
    }
  }

  double _calculateCurrentValue() {
    if (_selectedMethod != DepreciationMethod.smartEstimate) {
      return widget.purchaseAmount;
    }

    final yearsElapsed =
        DateTime.now().difference(widget.purchaseDate).inDays / 365.0;
    final depreciationAmount =
        widget.purchaseAmount * _depreciationRate * yearsElapsed;
    return (widget.purchaseAmount - depreciationAmount)
        .clamp(0.0, widget.purchaseAmount);
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _saveValuationSettings(DepreciationMethod method) {
    final result = AssetValuationResult(
      depreciationMethod: method,
      depreciationRate:
          method == DepreciationMethod.smartEstimate ? _depreciationRate : null,
      currentValue: method == DepreciationMethod.smartEstimate
          ? _calculateCurrentValue()
          : null,
    );

    Navigator.of(context).pop(result);
  }
}

/// 估值设置结果
class AssetValuationResult {
  const AssetValuationResult({
    required this.depreciationMethod,
    this.depreciationRate,
    this.currentValue,
  });

  final DepreciationMethod depreciationMethod;
  final double? depreciationRate;
  final double? currentValue;
}

