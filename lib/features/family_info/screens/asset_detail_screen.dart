import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/family_info/screens/asset_edit_screen.dart';

/// 通用资产详情屏幕
class AssetDetailScreen extends StatefulWidget {
  const AssetDetailScreen({
    required this.asset,
    super.key,
  });

  final AssetItem asset;

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  @override
  void initState() {
    super.initState();

    // ===== v1.1.0 初始化企业级动效系统 =====
    // 注册通用资产详情专用动效曲线
    IOSAnimationSystem.registerCustomCurve(
      'asset-detail-expand',
      Curves.elasticOut,
    );
    IOSAnimationSystem.registerCustomCurve(
      'asset-history-chart',
      Curves.easeInOutCubic,
    );
    IOSAnimationSystem.registerCustomCurve(
      'asset-info-slide',
      Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: Text(
            widget.asset.name,
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
              // 资产基本信息
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(context.responsiveSpacing12),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(widget.asset.category)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              context.responsiveSpacing12,
                            ),
                          ),
                          child: Icon(
                            _getCategoryIcon(widget.asset.category),
                            color: _getCategoryColor(widget.asset.category),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: context.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.asset.name,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: context.spacing4),
                              Text(
                                '${widget.asset.category.displayName} · ${widget.asset.subCategory}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.asset.notes != null &&
                        widget.asset.notes!.isNotEmpty) ...[
                      SizedBox(height: context.spacing16),
                      Text(
                        widget.asset.notes!,
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: context.spacing16),

              // 价值信息
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💰 价值信息',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing16),

                    // 购入价格
                    _buildValueRow(
                      context,
                      '购入价格',
                      '¥${widget.asset.amount.toStringAsFixed(2)}',
                      _getValueColor(
                        widget.asset.amount,
                        widget.asset.currentValue ?? widget.asset.amount,
                      ),
                      subtitle: widget.asset.purchaseDate != null
                          ? '购入时间：${_formatDate(widget.asset.purchaseDate!)}'
                          : null,
                    ),

                    // 当前估值（如果有）
                    if (widget.asset.currentValue != null &&
                        widget.asset.currentValue != widget.asset.amount) ...[
                      SizedBox(height: context.spacing12),
                      _buildValueRow(
                        context,
                        '当前估值',
                        '¥${widget.asset.currentValue!.toStringAsFixed(2)}',
                        _getValueColor(
                          widget.asset.currentValue!,
                          widget.asset.amount,
                        ),
                        subtitle: _getValueChangeText(),
                      ),
                    ],

                    // 折旧信息
                    if (widget.asset.depreciationMethod !=
                        DepreciationMethod.none) ...[
                      SizedBox(height: context.spacing12),
                      _buildValueRow(
                        context,
                        '估值方式',
                        widget.asset.depreciationMethod.displayName,
                        const Color(0xFF2196F3),
                        subtitle: widget.asset.depreciationRate != null
                            ? '年折旧率：${(widget.asset.depreciationRate! * 100).toStringAsFixed(1)}%'
                            : null,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: context.spacing16),

              // 资产状态
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 资产状态',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing16),
                    _buildStatusRow(
                      context,
                      '创建时间',
                      _formatDateTime(widget.asset.creationDate),
                    ),
                    SizedBox(height: context.spacing8),
                    _buildStatusRow(
                      context,
                      '最后更新',
                      _formatDateTime(widget.asset.updateDate),
                    ),
                    if (widget.asset.isIdle) ...[
                      SizedBox(height: context.spacing8),
                      _buildStatusRow(
                        context,
                        '闲置状态',
                        '当前闲置',
                        valueColor: const Color(0xFFFF9800),
                      ),
                      if (widget.asset.idleValue != null) ...[
                        SizedBox(height: context.spacing8),
                        _buildStatusRow(
                          context,
                          '闲置价值',
                          '¥${widget.asset.idleValue!.toStringAsFixed(2)}',
                          valueColor: const Color(0xFF9C27B0),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              // 资产特定的详细信息
              if (_hasAdditionalDetails()) ...[
                SizedBox(height: context.spacing16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📋 详细信息',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing16),
                      ..._buildAdditionalDetails(context),
                    ],
                  ),
                ),
              ],

              SizedBox(height: context.spacing32),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          AppAnimations.createRoute<void>(
                            AssetEditScreen(asset: widget.asset),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('编辑资产'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.responsiveSpacing12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.spacing16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 导航到历史记录
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('历史记录功能即将上线')),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('查看历史'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryAction,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.responsiveSpacing12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.spacing32),
            ],
          ),
        ),
      );

  Widget _buildValueRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor, {
    String? subtitle,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                style: context.textTheme.titleMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: context.spacing4),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.secondaryText.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      );

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) =>
      Row(
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
              color: valueColor ?? context.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );

  Color _getCategoryColor(AssetCategory category) {
    switch (category) {
      case AssetCategory.liquidAssets:
        return const Color(0xFF4CAF50);
      case AssetCategory.realEstate:
        return const Color(0xFF2196F3);
      case AssetCategory.investments:
        return const Color(0xFF9C27B0);
      case AssetCategory.consumptionAssets:
        return const Color(0xFFFF9800);
      case AssetCategory.receivables:
        return const Color(0xFF00BCD4);
      case AssetCategory.liabilities:
        return const Color(0xFFF44336);
    }
  }

  IconData _getCategoryIcon(AssetCategory category) {
    switch (category) {
      case AssetCategory.liquidAssets:
        return Icons.account_balance_wallet;
      case AssetCategory.realEstate:
        return Icons.home;
      case AssetCategory.investments:
        return Icons.trending_up;
      case AssetCategory.consumptionAssets:
        return Icons.devices;
      case AssetCategory.receivables:
        return Icons.receipt;
      case AssetCategory.liabilities:
        return Icons.warning;
    }
  }

  Color _getValueColor(double currentValue, double originalValue) {
    if (currentValue > originalValue) {
      return const Color(0xFF4CAF50); // 增值 - 绿色
    } else if (currentValue < originalValue) {
      return const Color(0xFFF44336); // 贬值 - 红色
    } else {
      return const Color(0xFF9E9E9E); // 持平 - 灰色
    }
  }

  String _getValueChangeText() {
    if (widget.asset.currentValue == null) return '';

    final change = widget.asset.currentValue! - widget.asset.amount;
    final changePercent = (change / widget.asset.amount * 100).abs();

    if (change > 0) {
      return '较购入价增值 ¥${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(1)}%)';
    } else if (change < 0) {
      return '较购入价贬值 ¥${change.abs().toStringAsFixed(2)} (${changePercent.toStringAsFixed(1)}%)';
    } else {
      return '价值无变化';
    }
  }

  bool _hasAdditionalDetails() {
    // 检查是否有额外的详细信息需要显示
    return widget.asset.category == AssetCategory.realEstate ||
        widget.asset.category == AssetCategory.consumptionAssets ||
        widget.asset.isIdle;
  }

  List<Widget> _buildAdditionalDetails(BuildContext context) {
    final details = <Widget>[];

    // 房产特定信息
    if (widget.asset.category == AssetCategory.realEstate) {
      // 这里可以从asset的额外字段中获取房产信息
      // 暂时显示占位信息
      details.add(_buildStatusRow(context, '房产类型', '住宅'));
      details.add(SizedBox(height: context.spacing8));
      details.add(_buildStatusRow(context, '使用性质', '自住'));
    }

    // 消费资产特定信息
    if (widget.asset.category == AssetCategory.consumptionAssets) {
      details.add(_buildStatusRow(context, '资产类型', widget.asset.subCategory));
      if (widget.asset.depreciationRate != null) {
        details.add(SizedBox(height: context.spacing8));
        final expectedLife = widget.asset.depreciationRate! > 0
            ? (1 / widget.asset.depreciationRate!).round()
            : 0;
        details.add(_buildStatusRow(context, '预期使用寿命', '$expectedLife年'));
      }
    }

    return details;
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  String _formatDateTime(DateTime dateTime) =>
      DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}
