import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/providers/asset_provider.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';

class SankeyChartWidget extends StatelessWidget {
  const SankeyChartWidget({super.key});

  @override
  Widget build(BuildContext context) => Consumer<AssetProvider>(
        builder: (context, assetProvider, child) {
          final assets = assetProvider.assets;
          final totalAssets = assetProvider.calculateTotalAssets();
          final netAssets = assetProvider.calculateNetAssets();

          // 计算各类别资产
          final liquidAssets = assets
              .where((asset) => asset.category == AssetCategory.liquidAssets)
              .toList();
          final fixedAssets = assets
              .where((asset) => asset.category == AssetCategory.fixedAssets)
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
      CustomPaint(
        painter: ImprovedSankeyPainter(data, assetProvider),
        size: Size.infinite,
      );
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

class ImprovedSankeyPainter extends CustomPainter {
  ImprovedSankeyPainter(this.data, this.assetProvider);
  final List<SankeyData> data;
  final AssetProvider assetProvider;

  // 缓存文字布局
  final Map<String, TextPainter> _textPainterCache = {};

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // 计算布局参数
    const leftMargin = 20.0;
    const nodeWidth = 100.0; // 增加节点宽度以容纳金额文字
    const nodeSpacing = 15.0; // 增加节点间距
    const levelSpacing = 140.0; // 增加层级间距

    // 计算总权重
    final totalWeight = data.fold(0.0, (sum, item) => sum + item.weight);

    // 计算节点高度
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

    // 计算所有节点高度
    for (final item in data) {
      final height = (item.weight / totalWeight * maxNodeHeight)
          .clamp(minNodeHeight, maxNodeHeight);
      nodeHeights[item.source] = height;
      nodeHeights[item.target] = height;
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

    // 第三遍：绘制节点
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

      // 绘制节点标签
      final amount = _getNodeAmount(nodeName);
      final displayText = amount != null ? '$nodeName $amount' : nodeName;

      // 分行显示：第一行是类型，第二行是金额
      final lines = displayText.split(' ');
      if (lines.length >= 2) {
        // 绘制类型名称
        final titlePainter = _getTextPainter(
          lines[0],
          const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          rect.width,
        );
        titlePainter.paint(
          canvas,
          Offset(
            rect.left + rect.width / 2 - titlePainter.width / 2,
            rect.top + rect.height / 2 - 8,
          ),
        );

        // 绘制金额
        final amountPainter = _getTextPainter(
          lines[1],
          const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          rect.width,
        );
        amountPainter.paint(
          canvas,
          Offset(
            rect.left + rect.width / 2 - amountPainter.width / 2,
            rect.top + rect.height / 2 + 8,
          ),
        );
      } else {
        // 单行显示
        final singlePainter = _getTextPainter(
          displayText,
          const TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          rect.width,
        );
        singlePainter.paint(
          canvas,
          Offset(
            rect.left + rect.width / 2 - singlePainter.width / 2,
            rect.top + rect.height / 2 - singlePainter.height / 2,
          ),
        );
      }
    }

    // 第四遍：绘制连接线
    for (final item in data) {
      final sourceRect = nodePositions[item.source];
      final targetRect = nodePositions[item.target];

      if (sourceRect != null && targetRect != null) {
        paint.color = item.color.withOpacity(0.6);
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
        ..color = const Color(0xFF9370DB).withOpacity(0.3),
    );
  }

  TextPainter _getTextPainter(String text, TextStyle style, double maxWidth) {
    final key = '${text}_${style.fontSize}_${style.fontWeight}_$maxWidth';
    if (!_textPainterCache.containsKey(key)) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      painter.layout(maxWidth: maxWidth);
      _textPainterCache[key] = painter;
    }
    return _textPainterCache[key]!;
  }

  String? _getNodeAmount(String nodeName) {
    // 根据节点名称返回对应的金额
    switch (nodeName) {
      case '净资产':
        return '${(assetProvider.calculateNetAssets() / 10000).toStringAsFixed(2)}万';
      case '总资产':
        return '${(assetProvider.calculateTotalAssets() / 10000).toStringAsFixed(2)}万';
      case '流动资金':
        final liquidAssets = assetProvider.assets
            .where((asset) => asset.category == AssetCategory.liquidAssets)
            .toList();
        final liquidTotal =
            liquidAssets.fold(0.0, (sum, asset) => sum + asset.amount);
        return '${(liquidTotal / 10000).toStringAsFixed(2)}万';
      case '固定资产':
        final fixedAssets = assetProvider.assets
            .where((asset) => asset.category == AssetCategory.fixedAssets)
            .toList();
        final fixedTotal =
            fixedAssets.fold(0.0, (sum, asset) => sum + asset.amount);
        return '${(fixedTotal / 10000).toStringAsFixed(2)}万';
      default:
        // 对于具体账户，从数据中查找
        for (final item in data) {
          if (item.target == nodeName) {
            return '${(item.weight / 10000).toStringAsFixed(2)}万';
          }
        }
        return null;
    }
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

    // 计算该层所有节点的总高度
    final totalNodeHeight = nodes.fold(
          0.0,
          (sum, node) =>
              sum + (nodeHeights[node] ?? minNodeHeight) + nodeSpacing,
        ) -
        nodeSpacing; // 减去最后一个间距

    // 计算起始Y位置（垂直居中）
    var currentY = (totalHeight - totalNodeHeight) / 2;

    // 计算X位置（根据层级）
    final x = leftMargin + level * levelSpacing;

    // 为每个节点分配位置
    for (final node in nodes) {
      final height = nodeHeights[node] ?? minNodeHeight;
      nodePositions[node] = Rect.fromLTWH(x, currentY, nodeWidth, height);
      currentY += height + nodeSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
