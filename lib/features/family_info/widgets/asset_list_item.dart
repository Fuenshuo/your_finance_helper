import 'dart:math';

import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/theme/responsive_text_styles.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

class AssetListItem extends StatefulWidget {
  const AssetListItem({
    required this.asset,
    super.key,
    this.onTap,
    this.showTrend = true,
  });
  final AssetItem asset;
  final VoidCallback? onTap;
  final bool showTrend;

  @override
  State<AssetListItem> createState() => _AssetListItemState();
}

class _AssetListItemState extends State<AssetListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  // 真正的缓存数据
  static final Map<String, List<double>> _trendDataCache = {};
  static final Map<String, double> _changeAmountCache = {};
  static final Map<String, double> _changePercentageCache = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // 启动淡入动画
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PerformanceMonitor.monitorBuild(
        'AssetListItem',
        () {
          // 使用缓存的趋势数据，避免重复计算
          final trendData = _getCachedTrendData();
          final changeAmount = _getCachedChangeAmount();
          final changePercentage = _getCachedChangePercentage();

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _isHovered ? _scaleAnimation.value : 1.0,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: AppCard(
                    margin: EdgeInsets.symmetric(
                      horizontal: context.responsiveSpacing16,
                      vertical: context.responsiveSpacing4,
                    ),
                    onTap: widget.onTap,
                    child: Padding(
                      padding: EdgeInsets.all(context.responsiveSpacing16),
                      child: Row(
                        children: [
                          // 资产类别图标（带动画）
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(widget.asset.category)
                                  .withValues(
                                alpha: _isHovered ? 0.15 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AnimatedScale(
                              scale: _isHovered ? 1.1 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                _getCategoryIcon(widget.asset.category),
                                color: _getCategoryColor(widget.asset.category),
                                size: 24,
                              ),
                            ),
                          ),

                          SizedBox(width: context.responsiveSpacing12),

                          // 资产信息
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 资产名称和类别（带动画）
                                Row(
                                  children: [
                                    Expanded(
                                      child: AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        style: context.mobileSubtitle.copyWith(
                                          color: _isHovered
                                              ? context.primaryAction
                                              : context.primaryText,
                                        ),
                                        child: Text(
                                          widget.asset.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: context.responsiveSpacing8,
                                        vertical: context.responsiveSpacing4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(
                                          widget.asset.category,
                                        ).withValues(
                                          alpha: _isHovered ? 0.2 : 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        widget.asset.category.displayName,
                                        style: context.mobileCaption.copyWith(
                                          color: _getCategoryColor(
                                            widget.asset.category,
                                          ),
                                          fontWeight: _isHovered
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: context.responsiveSpacing4),

                                // 备注信息
                                if (widget.asset.notes != null &&
                                    widget.asset.notes!.isNotEmpty) ...[
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.responsiveSpacing8,
                                      vertical: context.responsiveSpacing4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.secondaryText
                                          .withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: context.secondaryText
                                            .withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.note_outlined,
                                          size: 12,
                                          color: context.secondaryText,
                                        ),
                                        SizedBox(
                                          width: context.responsiveSpacing4,
                                        ),
                                        Expanded(
                                          child: Text(
                                            widget.asset.notes!,
                                            style:
                                                context.mobileCaption.copyWith(
                                              color: context.secondaryText,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: context.responsiveSpacing4),
                                ],

                                // 固定资产特殊信息
                                if (widget.asset.isFixedAsset) ...[
                                  _buildFixedAssetInfo(context),
                                  SizedBox(height: context.responsiveSpacing4),
                                ],

                                // 当前价值和变化（带动画）
                                Row(
                                  children: [
                                    Text(
                                      '¥${widget.asset.effectiveValue.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                    if (changeAmount != 0) ...[
                                      SizedBox(
                                        width: context.responsiveSpacing8,
                                      ),
                                      Icon(
                                        changeAmount > 0
                                            ? Icons.trending_up_outlined
                                            : Icons.trending_down_outlined,
                                        size: 12,
                                        color: changeAmount > 0
                                            ? context.successColor
                                            : context.errorColor,
                                      ),
                                      SizedBox(
                                        width: context.responsiveSpacing4,
                                      ),
                                      Text(
                                        '${changeAmount > 0 ? '+' : ''}${changePercentage.toStringAsFixed(1)}%',
                                        style: context.mobileCaption.copyWith(
                                          color: changeAmount > 0
                                              ? context.successColor
                                              : context.errorColor,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                // 趋势图（轻量版，带动画）
                                if (widget.showTrend) ...[
                                  SizedBox(height: context.responsiveSpacing8),
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.3),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                      child: RepaintBoundary(
                                        child: _buildLightweightTrendChart(
                                          context,
                                          trendData,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // 右侧箭头（带动画）
                          AnimatedRotation(
                            turns: _isHovered ? 0.25 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding:
                                  EdgeInsets.all(context.responsiveSpacing4),
                              decoration: BoxDecoration(
                                color: _isHovered
                                    ? context.primaryAction
                                        .withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.chevron_right_outlined,
                                color: _isHovered
                                    ? context.primaryAction
                                    : context.secondaryText,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

  // 构建简洁的趋势图
  Widget _buildLightweightTrendChart(BuildContext context, List<double> data) =>
      Container(
        height: 28,
        margin: EdgeInsets.only(top: context.responsiveSpacing4),
        child: CustomPaint(
          painter: _SimpleTrendPainter(
            data: data,
            color: context.primaryAction,
          ),
          size: Size.infinite,
        ),
      );

  // 获取资产类别颜色
  Color _getCategoryColor(AssetCategory category) {
    switch (category) {
      case AssetCategory.liquidAssets:
        return const Color(0xFF007AFF); // 活力蓝
      case AssetCategory.realEstate:
        return const Color(0xFF34C759); // 理性绿
      case AssetCategory.investments:
        return const Color(0xFFFF9500); // 橙色
      case AssetCategory.consumptionAssets:
        return const Color(0xFF30D158); // 绿色
      case AssetCategory.receivables:
        return const Color(0xFFAF52DE); // 紫色
      case AssetCategory.liabilities:
        return const Color(0xFFFF3B30); // 温暖红
    }
  }

  // 获取资产类别图标
  IconData _getCategoryIcon(AssetCategory category) {
    switch (category) {
      case AssetCategory.liquidAssets:
        return Icons.account_balance_wallet_outlined;
      case AssetCategory.realEstate:
        return Icons.home_outlined;
      case AssetCategory.investments:
        return Icons.trending_up_outlined;
      case AssetCategory.consumptionAssets:
        return Icons.shopping_cart_outlined;
      case AssetCategory.receivables:
        return Icons.receipt_outlined;
      case AssetCategory.liabilities:
        return Icons.credit_card_outlined;
    }
  }

  // 获取缓存的趋势数据
  List<double> _getCachedTrendData() {
    if (_trendDataCache.containsKey(widget.asset.id)) {
      return _trendDataCache[widget.asset.id]!;
    }

    // 使用资产ID作为种子，确保相同资产总是返回相同的数据
    final random = Random(widget.asset.id.hashCode);
    final data = <double>[];
    var baseValue = widget.asset.amount;

    // 生成7天的模拟数据
    for (var i = 0; i < 7; i++) {
      // 添加基于种子的"随机"波动，减少计算复杂度
      final variation = (baseValue * 0.02) * (random.nextDouble() - 0.5);
      data.add(baseValue + variation);
      baseValue = data.last;
    }

    _trendDataCache[widget.asset.id] = data;
    return data;
  }

  // 获取缓存的变化金额
  double _getCachedChangeAmount() {
    if (_changeAmountCache.containsKey(widget.asset.id)) {
      return _changeAmountCache[widget.asset.id]!;
    }

    // 使用资产ID作为种子，确保相同资产总是返回相同的数据
    final random = Random(widget.asset.id.hashCode);
    final changeAmount =
        widget.asset.amount * (random.nextDouble() - 0.5) * 0.02; // ±1%的变化
    _changeAmountCache[widget.asset.id] = changeAmount;
    return changeAmount;
  }

  // 获取缓存的变化百分比
  double _getCachedChangePercentage() {
    if (_changePercentageCache.containsKey(widget.asset.id)) {
      return _changePercentageCache[widget.asset.id]!;
    }

    // 使用资产ID作为种子，确保相同资产总是返回相同的数据
    final random = Random(widget.asset.id.hashCode);
    final changePercentage = (random.nextDouble() - 0.5) * 2.0; // ±1%的变化
    _changePercentageCache[widget.asset.id] = changePercentage;
    return changePercentage;
  }

  // 构建固定资产特殊信息
  Widget _buildFixedAssetInfo(BuildContext context) {
    final infoWidgets = <Widget>[];

    // 闲置状态
    if (widget.asset.isIdle) {
      infoWidgets.add(
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pause_circle_outline,
                size: 12,
                color: Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                '闲置',
                style: context.mobileCaption.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 折旧信息
    if (widget.asset.depreciationMethod != DepreciationMethod.none) {
      final originalValue = widget.asset.amount;
      final currentValue = widget.asset.effectiveValue;
      final depreciationAmount = originalValue - currentValue;
      final depreciationPercentage =
          originalValue > 0 ? (depreciationAmount / originalValue * 100) : 0;

      if (depreciationAmount > 0) {
        infoWidgets.add(
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.trending_down_outlined,
                  size: 12,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  '已折旧 ${depreciationPercentage.toStringAsFixed(1)}%',
                  style: context.mobileCaption.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // 手动更新状态
    if (widget.asset.depreciationMethod == DepreciationMethod.manualUpdate) {
      infoWidgets.add(
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.edit_outlined,
                size: 12,
                color: Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                '手动更新',
                style: context.mobileCaption.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (infoWidgets.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: infoWidgets,
    );
  }
}

// 简洁的趋势图绘制器
class _SimpleTrendPainter extends CustomPainter {
  _SimpleTrendPainter({
    required this.data,
    required this.color,
  });
  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) return;

    // 绘制简洁的线条
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = (data[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SimpleTrendPainter oldDelegate) =>
      data != oldDelegate.data || color != oldDelegate.color;
}
