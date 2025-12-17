import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/theme/responsive_text_styles.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';

class PerformanceAnalysisScreen extends StatelessWidget {
  const PerformanceAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: const Text('性能分析'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: context.primaryText,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsiveSpacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                '性能监控报告',
                style: context.responsiveDisplayMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.primaryText,
                ),
              ),
              SizedBox(height: context.responsiveSpacing8),
              Text(
                '实时监控各个组件的构建和绘制性能',
                style: context.responsiveBodyLarge.copyWith(
                  color: context.secondaryText,
                ),
              ),
              SizedBox(height: context.responsiveSpacing24),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: PerformanceMonitor.printAllStats,
                      icon: const Icon(Icons.analytics_outlined),
                      label: const Text('查看统计'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryAction,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.responsiveSpacing12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: PerformanceMonitor.clearStats,
                      icon: const Icon(Icons.clear_all_outlined),
                      label: const Text('清除数据'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.primaryAction),
                        foregroundColor: context.primaryAction,
                        padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.responsiveSpacing24),

              // 性能指标说明
              Container(
                padding: EdgeInsets.all(context.responsiveSpacing16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '性能指标说明',
                      style: context.responsiveHeadlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.primaryText,
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing12),
                    _buildMetricItem(
                      context,
                      'AssetListScreen',
                      '主页面构建时间',
                      '正常: <5ms, 警告: 5-10ms, 危险: >10ms',
                      context.successColor,
                    ),
                    SizedBox(height: context.responsiveSpacing8),
                    _buildMetricItem(
                      context,
                      'AssetListItem',
                      '列表项构建时间',
                      '正常: <1ms, 警告: 1-3ms, 危险: >3ms',
                      context.warningColor,
                    ),
                    SizedBox(height: context.responsiveSpacing8),
                    _buildMetricItem(
                      context,
                      'SimpleTrendChart',
                      '趋势图构建时间',
                      '正常: <0.5ms, 警告: 0.5-1ms, 危险: >1ms',
                      context.errorColor,
                    ),
                    SizedBox(height: context.responsiveSpacing8),
                    _buildMetricItem(
                      context,
                      '_TrendLinePainter',
                      '趋势图绘制时间',
                      '正常: <0.1ms, 警告: 0.1-0.5ms, 危险: >0.5ms',
                      context.primaryAction,
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.responsiveSpacing24),

              // 性能优化建议
              Container(
                padding: EdgeInsets.all(context.responsiveSpacing16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '性能优化建议',
                      style: context.responsiveHeadlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.primaryText,
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing12),
                    _buildSuggestionItem(
                      context,
                      '1. 使用 const 构造函数',
                      '减少不必要的 Widget 重建',
                    ),
                    _buildSuggestionItem(
                      context,
                      '2. 避免在 build 方法中创建对象',
                      '将对象创建移到 initState 或类成员变量',
                    ),
                    _buildSuggestionItem(
                      context,
                      '3. 使用 RepaintBoundary',
                      '隔离重绘区域，减少不必要的重绘',
                    ),
                    _buildSuggestionItem(
                      context,
                      '4. 优化列表性能',
                      '使用 ListView.builder 和 itemExtent',
                    ),
                    _buildSuggestionItem(
                      context,
                      '5. 减少动画复杂度',
                      '简化动画曲线和减少同时运行的动画',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildMetricItem(
    BuildContext context,
    String name,
    String description,
    String threshold,
    Color color,
  ) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.only(
              top: context.responsiveSpacing4,
              right: context.responsiveSpacing8,
            ),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.responsiveBodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryText,
                  ),
                ),
                Text(
                  description,
                  style: context.responsiveLabelLarge.copyWith(
                    color: context.secondaryText,
                  ),
                ),
                Text(
                  threshold,
                  style: context.responsiveLabelLarge.copyWith(
                    color: color,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildSuggestionItem(
    BuildContext context,
    String title,
    String description,
  ) =>
      Padding(
        padding: EdgeInsets.only(bottom: context.responsiveSpacing8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 4,
              margin: EdgeInsets.only(
                top: context.responsiveSpacing8,
                right: context.responsiveSpacing8,
              ),
              decoration: BoxDecoration(
                color: context.primaryAction,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.responsiveBodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.primaryText,
                    ),
                  ),
                  Text(
                    description,
                    style: context.responsiveLabelLarge.copyWith(
                      color: context.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
