import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';

class SankeyChartWidget extends StatefulWidget {
  const SankeyChartWidget({super.key});

  @override
  State<SankeyChartWidget> createState() => _SankeyChartWidgetState();
}

class _SankeyChartWidgetState extends State<SankeyChartWidget> {
  bool _forceRepaint = false;

  @override
  void initState() {
    super.initState();
    // Web端延迟重绘，解决刷新后文字不显示的问题
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _forceRepaint = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Consumer<AssetProvider>(
        builder: (context, assetProvider, child) {
          final assets = assetProvider.assets;
          final totalAssets = assetProvider.calculateTotalAssets();
          final netAssets = assetProvider.calculateNetAssets();

          print(
            '📊 桑基图构建: 资产数量=${assets.length}, 总资产=$totalAssets, 净资产=$netAssets, 强制重绘=$_forceRepaint',
          );

          // 检查是否已初始化
          if (!assetProvider.isInitialized) {
            print('📊 桑基图: 未初始化，显示加载状态');
            return Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // 检查数据是否有效
          if (totalAssets <= 0 && netAssets <= 0) {
            print('📊 桑基图: 数据无效，显示空状态');
            return Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '暂无资产数据',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '请添加资产后查看分布图',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 计算各类别资产
          final liquidAssets = assets
              .where((asset) => asset.category == AssetCategory.liquidAssets)
              .toList();
          final fixedAssets = assets
              .where((asset) => asset.category == AssetCategory.realEstate)
              .toList();

          final liquidTotal =
              liquidAssets.fold(0.0, (sum, asset) => sum + asset.amount);
          final fixedTotal =
              fixedAssets.fold(0.0, (sum, asset) => sum + asset.amount);

          // 获取前两个最大的流动资金账户
          final topLiquidAssets = liquidAssets
            ..sort((a, b) => b.amount.compareTo(a.amount));
          final top2Liquid = topLiquidAssets.take(2).toList();

          // 获取最大的固定资产账户
          final topFixedAssets = fixedAssets
            ..sort((a, b) => b.amount.compareTo(a.amount));
          final topFixed =
              topFixedAssets.isNotEmpty ? topFixedAssets.first : null;

          // 构建桑葚图数据
          final sankeyData = _buildSankeyData(
            netAssets,
            totalAssets,
            liquidTotal,
            fixedTotal,
            top2Liquid,
            topFixed,
            assetProvider,
          );

          // 检查是否有有效数据
          final hasValidData = sankeyData.any((item) => item.weight > 0);

          if (!hasValidData) {
            return Container(
              height: 300,
              padding: EdgeInsets.all(context.responsiveSpacing16),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '暂无资产数据',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '请添加资产后查看分布图',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            height: 300,
            padding: EdgeInsets.all(context.responsiveSpacing16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 600, // 固定宽度，确保有足够空间显示四层
                child: _buildCustomSankeyChart(
                  context,
                  sankeyData,
                  assetProvider,
                ),
              ),
            ),
          );
        },
      );

  List<SankeyData> _buildSankeyData(
    double netAssets,
    double totalAssets,
    double liquidTotal,
    double fixedTotal,
    List<AssetItem> top2Liquid,
    AssetItem? topFixed,
    AssetProvider assetProvider,
  ) {
    final data = <SankeyData>[];

    // 第1层连接：净资产 → 总资产
    data.add(
      SankeyData(
        source: '净资产',
        target: '总资产',
        weight: netAssets,
        color: const Color(0xFF66CDAA),
      ),
    );

    // 第2层连接：总资产 → 流动资金
    if (liquidTotal > 0) {
      data.add(
        SankeyData(
          source: '总资产',
          target: '流动资金',
          weight: liquidTotal,
          color: const Color(0xFFE6E6FA),
        ),
      );
    }

    // 第2层连接：总资产 → 固定资产
    if (fixedTotal > 0) {
      data.add(
        SankeyData(
          source: '总资产',
          target: '固定资产',
          weight: fixedTotal,
          color: const Color(0xFFD8BFD8),
        ),
      );
    }

    // 第3层连接：流动资金 → 具体账户
    for (var i = 0; i < top2Liquid.length; i++) {
      final asset = top2Liquid[i];
      data.add(
        SankeyData(
          source: '流动资金',
          target: asset.name,
          weight: asset.amount,
          color: const Color(0xFFF4C7A5),
        ),
      );
    }

    // 第3层连接：固定资产 → 具体账户
    if (topFixed != null) {
      data.add(
        SankeyData(
          source: '固定资产',
          target: topFixed.name,
          weight: topFixed.amount,
          color: const Color(0xFFB0C4DE),
        ),
      );
    }

    return data;
  }

  Widget _buildCustomSankeyChart(
    BuildContext context,
    List<SankeyData> data,
    AssetProvider assetProvider,
  ) =>
      LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            // Background canvas for shapes and connections
            CustomPaint(
              painter: SankeyBackgroundPainter(data, assetProvider),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            ),
            // Text widgets overlaid on top
            ..._buildTextOverlays(context, data, assetProvider, constraints),
          ],
        ),
      );

  List<Widget> _buildTextOverlays(
    BuildContext context,
    List<SankeyData> data,
    AssetProvider assetProvider,
    BoxConstraints constraints,
  ) {
    final overlays = <Widget>[];

    // Calculate node positions (same logic as before)
    final nodePositions =
        _calculateNodePositions(data, assetProvider, constraints);

    for (final entry in nodePositions.entries) {
      final nodeName = entry.key;
      final rect = entry.value;
      final amount = _getNodeAmount(nodeName, data, assetProvider);
      final displayText = amount != null ? '$nodeName $amount' : nodeName;

      // Split text into lines
      final lines = displayText.split(' ');
      if (lines.length >= 2) {
        // Two lines: title and amount
        overlays.add(
          Positioned(
            left: rect.left,
            top: rect.top,
            width: rect.width,
            height: rect.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    lines[0],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    lines[1],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Single line
        overlays.add(
          Positioned(
            left: rect.left,
            top: rect.top,
            width: rect.width,
            height: rect.height,
            child: Center(
              child: Text(
                displayText,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }
    }

    return overlays;
  }

  Map<String, Rect> _calculateNodePositions(
    List<SankeyData> data,
    AssetProvider assetProvider,
    BoxConstraints constraints,
  ) {
    final nodePositions = <String, Rect>{};
    final nodeHeights = <String, double>{};

    // Same calculation logic as before
    const leftMargin = 20.0;
    const nodeWidth = 100.0;
    const nodeSpacing = 15.0;
    const levelSpacing = 140.0;
    const minNodeHeight = 30.0;

    final totalAssets = assetProvider.calculateTotalAssets();
    final maxNodeHeight = constraints.maxHeight * 0.8;

    // Calculate node weights and heights
    final nodeWeights = <String, double>{};
    for (final item in data) {
      nodeWeights[item.source] = (nodeWeights[item.source] ?? 0) + item.weight;
      nodeWeights[item.target] = (nodeWeights[item.target] ?? 0) + item.weight;
    }

    for (final entry in nodeWeights.entries) {
      final weight = entry.value;
      final ratio = totalAssets > 0 ? weight / totalAssets : 0.0;
      final height =
          (ratio * maxNodeHeight).clamp(minNodeHeight, maxNodeHeight);
      nodeHeights[entry.key] = height;
    }

    // Define levels
    final level1Nodes = <String>['净资产'];
    final level2Nodes = <String>['总资产'];
    final level3Nodes = <String>['流动资金', '固定资产'];
    final level4Nodes = <String>[];

    for (final item in data) {
      if (!level1Nodes.contains(item.target) &&
          !level2Nodes.contains(item.target) &&
          !level3Nodes.contains(item.target)) {
        if (!level4Nodes.contains(item.target)) {
          level4Nodes.add(item.target);
        }
      }
    }

    // Calculate positions for each level
    _calculateLevelPositions(
      level1Nodes,
      0,
      leftMargin,
      levelSpacing,
      nodeWidth,
      nodeSpacing,
      nodeHeights,
      nodePositions,
      constraints.maxHeight,
      minNodeHeight,
    );
    _calculateLevelPositions(
      level2Nodes,
      1,
      leftMargin,
      levelSpacing,
      nodeWidth,
      nodeSpacing,
      nodeHeights,
      nodePositions,
      constraints.maxHeight,
      minNodeHeight,
    );
    _calculateLevelPositions(
      level3Nodes,
      2,
      leftMargin,
      levelSpacing,
      nodeWidth,
      nodeSpacing,
      nodeHeights,
      nodePositions,
      constraints.maxHeight,
      minNodeHeight,
    );
    _calculateLevelPositions(
      level4Nodes,
      3,
      leftMargin,
      levelSpacing,
      nodeWidth,
      nodeSpacing,
      nodeHeights,
      nodePositions,
      constraints.maxHeight,
      minNodeHeight,
    );

    return nodePositions;
  }

  void _calculateLevelPositions(
    List<String> nodes,
    int level,
    double leftMargin,
    double levelSpacing,
    double nodeWidth,
    double nodeSpacing,
    Map<String, double> nodeHeights,
    Map<String, Rect> nodePositions,
    double totalHeight,
    double minNodeHeight,
  ) {
    if (nodes.isEmpty) return;

    final totalNodeHeight = nodes.fold(
          0.0,
          (sum, node) =>
              sum + (nodeHeights[node] ?? minNodeHeight) + nodeSpacing,
        ) -
        nodeSpacing;

    var currentY = (totalHeight - totalNodeHeight) / 2;
    final x = leftMargin + level * levelSpacing;

    for (final node in nodes) {
      final height = nodeHeights[node] ?? minNodeHeight;
      nodePositions[node] = Rect.fromLTWH(x, currentY, nodeWidth, height);
      currentY += height + nodeSpacing;
    }
  }

  String? _getNodeAmount(
    String nodeName,
    List<SankeyData> data,
    AssetProvider assetProvider,
  ) {
    switch (nodeName) {
      case '净资产':
        final netAssets = assetProvider.calculateNetAssets();
        return '${(netAssets / 10000).toStringAsFixed(2)}万';
      case '总资产':
        final totalAssets = assetProvider.calculateTotalAssets();
        return '${(totalAssets / 10000).toStringAsFixed(2)}万';
      case '流动资金':
        final liquidAssets = assetProvider.assets
            .where((asset) => asset.category == AssetCategory.liquidAssets)
            .toList();
        final liquidTotal =
            liquidAssets.fold(0.0, (sum, asset) => sum + asset.amount);
        return '${(liquidTotal / 10000).toStringAsFixed(2)}万';
      case '固定资产':
        final fixedAssets = assetProvider.assets
            .where((asset) => asset.category == AssetCategory.realEstate)
            .toList();
        final fixedTotal =
            fixedAssets.fold(0.0, (sum, asset) => sum + asset.amount);
        return '${(fixedTotal / 10000).toStringAsFixed(2)}万';
      default:
        // For specific accounts, find from data
        for (final item in data) {
          if (item.target == nodeName) {
            return '${(item.weight / 10000).toStringAsFixed(2)}万';
          }
        }
        return null;
    }
  }
}

class SankeyData {
  SankeyData({
    required this.source,
    required this.target,
    required this.weight,
    required this.color,
  });
  final String source;
  final String target;
  final double weight;
  final Color color;
}

class SankeyBackgroundPainter extends CustomPainter {
  SankeyBackgroundPainter(this.data, this.assetProvider);
  final List<SankeyData> data;
  final AssetProvider assetProvider;

  @override
  void paint(Canvas canvas, Size size) {
    // 检查是否有有效数据
    final hasValidData = data.any((item) => item.weight > 0);
    if (!hasValidData) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // 计算布局参数
    const leftMargin = 20.0;
    const nodeWidth = 100.0;
    const nodeSpacing = 15.0;
    const levelSpacing = 140.0;

    // 计算总资产（用于比例计算）
    final totalAssets = assetProvider.calculateTotalAssets();
    final maxNodeHeight = size.height * 0.8;
    const minNodeHeight = 30.0;

    // 定义四层节点
    final level1Nodes = <String>['净资产'];
    final level2Nodes = <String>['总资产'];
    final level3Nodes = <String>['流动资金', '固定资产'];
    final level4Nodes = <String>[];

    // 收集第4层节点（具体账户）
    for (final item in data) {
      if (!level1Nodes.contains(item.target) &&
          !level2Nodes.contains(item.target) &&
          !level3Nodes.contains(item.target)) {
        if (!level4Nodes.contains(item.target)) {
          level4Nodes.add(item.target);
        }
      }
    }

    // 计算节点位置
    final nodePositions = <String, Rect>{};
    final nodeHeights = <String, double>{};

    // 计算每个节点的实际权重和高度
    final nodeWeights = <String, double>{};
    for (final item in data) {
      nodeWeights[item.source] = (nodeWeights[item.source] ?? 0) + item.weight;
      nodeWeights[item.target] = (nodeWeights[item.target] ?? 0) + item.weight;
    }

    // 计算节点高度（基于实际权重）
    for (final entry in nodeWeights.entries) {
      final nodeName = entry.key;
      final weight = entry.value;
      final ratio = totalAssets > 0 ? weight / totalAssets : 0.0;
      final height =
          (ratio * maxNodeHeight).clamp(minNodeHeight, maxNodeHeight);
      nodeHeights[nodeName] = height;
    }

    // 为每层计算节点位置
    _calculateNodePositions(
      level1Nodes,
      0,
      leftMargin,
      levelSpacing,
      nodeWidth,
      nodeSpacing,
      nodeHeights,
      nodePositions,
      size.height,
      minNodeHeight,
    );
    _calculateNodePositions(
      level2Nodes,
      1,
      leftMargin,
      levelSpacing,
      nodeWidth,
      nodeSpacing,
      nodeHeights,
      nodePositions,
      size.height,
      minNodeHeight,
    );
    _calculateNodePositions(
      level3Nodes,
      2,
      leftMargin,
      levelSpacing,
      nodeWidth,
      nodeSpacing,
      nodeHeights,
      nodePositions,
      size.height,
      minNodeHeight,
    );
    _calculateNodePositions(
      level4Nodes,
      3,
      leftMargin,
      levelSpacing,
      nodeWidth,
      nodeSpacing,
      nodeHeights,
      nodePositions,
      size.height,
      minNodeHeight,
    );

    // 绘制节点（只绘制形状，不绘制文字）
    for (final entry in nodePositions.entries) {
      final rect = entry.value;
      final nodeName = entry.key;

      // 根据节点类型选择颜色
      Color nodeColor;
      if (nodeName == '净资产') {
        nodeColor = const Color(0xFF66CDAA);
      } else if (nodeName == '总资产') {
        nodeColor = const Color(0xFF9370DB);
      } else if (nodeName == '流动资金') {
        nodeColor = const Color(0xFFE6E6FA);
      } else if (nodeName == '固定资产') {
        nodeColor = const Color(0xFFD8BFD8);
      } else {
        nodeColor = const Color(0xFFF4C7A5);
      }

      paint.color = nodeColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
    }

    // 绘制连接线
    for (final item in data) {
      final sourceRect = nodePositions[item.source];
      final targetRect = nodePositions[item.target];

      if (sourceRect != null && targetRect != null) {
        paint.color = item.color.withValues(alpha: 0.6);
        _drawSankeyFlow(
          canvas,
          sourceRect.right,
          sourceRect.center.dy,
          targetRect.left,
          targetRect.center.dy,
          sourceRect.height,
          targetRect.height,
        );
      }
    }
  }

  void _drawSankeyFlow(
    Canvas canvas,
    double startX,
    double startY,
    double endX,
    double endY,
    double startHeight,
    double endHeight,
  ) {
    final path = Path();

    // 创建曲线连接
    path.moveTo(startX, startY - startHeight / 2);
    path.cubicTo(
      startX + (endX - startX) * 0.3,
      startY - startHeight / 2,
      startX + (endX - startX) * 0.7,
      endY - endHeight / 2,
      endX,
      endY - endHeight / 2,
    );
    path.lineTo(endX, endY + endHeight / 2);
    path.cubicTo(
      startX + (endX - startX) * 0.7,
      endY + endHeight / 2,
      startX + (endX - startX) * 0.3,
      startY + startHeight / 2,
      startX,
      startY + startHeight / 2,
    );
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF9370DB).withValues(alpha: 0.3),
    );
  }

  void _calculateNodePositions(
    List<String> nodes,
    int level,
    double leftMargin,
    double levelSpacing,
    double nodeWidth,
    double nodeSpacing,
    Map<String, double> nodeHeights,
    Map<String, Rect> nodePositions,
    double totalHeight,
    double minNodeHeight,
  ) {
    if (nodes.isEmpty) return;

    final totalNodeHeight = nodes.fold(
          0.0,
          (sum, node) =>
              sum + (nodeHeights[node] ?? minNodeHeight) + nodeSpacing,
        ) -
        nodeSpacing;

    var currentY = (totalHeight - totalNodeHeight) / 2;
    final x = leftMargin + level * levelSpacing;

    for (final node in nodes) {
      final height = nodeHeights[node] ?? minNodeHeight;
      nodePositions[node] = Rect.fromLTWH(x, currentY, nodeWidth, height);
      currentY += height + nodeSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is SankeyBackgroundPainter) {
      if (data.length != oldDelegate.data.length) return true;
      for (var i = 0; i < data.length; i++) {
        if (data[i].weight != oldDelegate.data[i].weight) return true;
      }
      return true;
    }
    return true;
  }
}
