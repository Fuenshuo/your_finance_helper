import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/features/insights/screens/flux_insights_screen.dart';

// Stream页面的主题色定义
class StreamThemeColors {
  static const Color primary = Color(0xFF007AFF);    // 活力蓝
  static const Color accent = Color(0xFFFF9500);     // 橙色
  static const Color success = Color(0xFF34C759);    // 绿色
  static const Color error = Color(0xFFFF3B30);      // 红色
  static const Color warning = Color(0xFFFF9500);    // 橙色
  static const Color background = Color(0xFFF2F2F7); // 浅灰背景
  static const Color surface = Color(0xFF1C1C1E);    // 深灰表面
  static const Color textPrimary = Color(0xFF1C1C1E);   // 主要文字
  static const Color textSecondary = Color(0xFF8A8A8E); // 次要文字
}

/// 🌊 Flux Streams Screen
///
/// 统一的流式界面，包含Stream和Insights两个tab页面的切换
/// 使用统一的主题色系统
class FluxStreamsScreen extends StatefulWidget {
  const FluxStreamsScreen({super.key});

  @override
  State<FluxStreamsScreen> createState() => _FluxStreamsScreenState();
}

class _FluxStreamsScreenState extends State<FluxStreamsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Stream页面的主题色定义已在 StreamThemeColors 类中

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : StreamThemeColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            // Stream/Insights Tab切换
            Expanded(
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                        color: StreamThemeColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
                  labelStyle: AppDesignTokens.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: AppDesignTokens.body(context),
                  tabs: const [
                    Tab(text: 'Stream'),
                    Tab(text: 'Insights'),
                  ],
                ),
              ),
            ),

            // 颜色主题切换按钮 (暂时占位)
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(
                Icons.palette_outlined,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              onPressed: () {
                // TODO: 实现颜色主题切换
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Stream Tab
          _buildStreamTab(context),

          // Insights Tab
          FluxInsightsScreen(
            colorTheme: const InsightsColorTheme(
              primary: StreamThemeColors.primary,
              accent: StreamThemeColors.accent,
              success: StreamThemeColors.success,
              error: Color(0xFFFF3B30),
              warning: StreamThemeColors.warning,
              background: StreamThemeColors.background,
              surface: StreamThemeColors.surface,
              textPrimary: StreamThemeColors.textPrimary,
              textSecondary: StreamThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? Colors.black : _streamBackgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              'Stream View',
              style: AppDesignTokens.largeTitle(context).copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transaction timeline will be implemented here',
              style: AppDesignTokens.caption(context).copyWith(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
