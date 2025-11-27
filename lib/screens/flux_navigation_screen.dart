/// 🌊 Flux Ledger 主导航屏幕
///
/// 实现流式导航的核心界面
/// 支持实时状态更新和流畅的页面切换
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/providers/flux_providers.dart';
import 'package:your_finance_flutter/core/router/flux_router.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/theme/flux_theme.dart';
import 'package:your_finance_flutter/screens/flux_ui_architecture.dart';

/// 🌊 Flux 主导航屏幕
class FluxNavigationScreen extends StatefulWidget {
  const FluxNavigationScreen({
    required this.navigationShell,
    super.key,
  });
  final StatefulNavigationShell navigationShell;

  @override
  State<FluxNavigationScreen> createState() => _FluxNavigationScreenState();
}

class _FluxNavigationScreenState extends State<FluxNavigationScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: FluxTheme.flowBackground,
        appBar: _buildAppBar(),
        body: widget.navigationShell,
        bottomNavigationBar: FluxBottomNavigationBar(
          navigationShell: widget.navigationShell,
        ),
        floatingActionButton: const FluxFloatingActionButton(),
      );

  PreferredSizeWidget _buildAppBar() => AppBar(
        title: GestureDetector(
          onTap: _handleTitleTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [FluxTheme.flowBlue, FluxTheme.incomeGreen],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Flux Ledger',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: FluxTheme.flowBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '流式记账',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: FluxTheme.flowBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 实时状态指示器
          const FlowStatusIndicator(),

          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go(FluxRoutes.settings),
            tooltip: '设置',
          ),

          // 开发者模式按钮 (调试时显示)
          if (_isDebugMode()) ...[
            IconButton(
              icon: const Icon(Icons.developer_mode, color: Colors.orange),
              onPressed: () => context.go(FluxRoutes.developer),
              tooltip: '开发者模式',
            ),
          ],
        ],
      );

  void _handleTitleTap() {
    // 双击标题进入开发者模式
    final debugTapCount = _getDebugTapCount();
    if (debugTapCount >= 5) {
      _toggleDebugMode();
      _resetDebugTapCount();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔧 开发者模式已切换'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _incrementDebugTapCount();
    }
  }

  bool _isDebugMode() {
    // TODO: 实现开发者模式检查
    return false;
  }

  int _getDebugTapCount() {
    // TODO: 实现点击计数器
    return 0;
  }

  void _incrementDebugTapCount() {
    // TODO: 实现点击计数递增
  }

  void _resetDebugTapCount() {
    // TODO: 重置点击计数
  }

  void _toggleDebugMode() {
    // TODO: 切换开发者模式
  }
}

/// 🌊 底部导航栏
class FluxBottomNavigationBar extends StatelessWidget {
  const FluxBottomNavigationBar({
    required this.navigationShell,
    super.key,
  });
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final navTheme = Theme.of(context).bottomNavigationBarTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = navTheme.backgroundColor ?? context.surfaceWhite;
    final selectedColor = navTheme.selectedItemColor ?? context.primaryAction;
    final unselectedColor = navTheme.unselectedItemColor ??
        context.secondaryText.withOpacity(isDark ? 0.85 : 0.7);
    final navShadow = [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.06),
        blurRadius: 12,
        offset: const Offset(0, -2),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: navShadow,
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: '流仪表板',
              tooltip: '实时资金流可视化',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.waterfall_chart_outlined),
              activeIcon: Icon(Icons.waterfall_chart),
              label: '流管道',
              tooltip: '管理持续性资金流',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: '流洞察',
              tooltip: 'AI智能分析与建议',
            ),
          ],
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
          selectedLabelStyle:
              navTheme.selectedLabelStyle ??
              const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
          unselectedLabelStyle:
              navTheme.unselectedLabelStyle ??
              const TextStyle(
                fontSize: 12,
              ),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}

/// 🌊 浮动操作按钮
class FluxFloatingActionButton extends StatelessWidget {
  const FluxFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [FluxTheme.flowBlue, Color(0xFF5AC8FA)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: FluxTheme.flowBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.go(FluxRoutes.flowEntry),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, size: 28),
        ),
      );
}

/// 🌊 流状态指示器
class FlowStatusIndicator extends StatelessWidget {
  const FlowStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) => Consumer<FlowDashboardProvider>(
        builder: (context, dashboard, child) => FlowPulseIndicator(
          status: dashboard.overallHealth,
          size: 8,
        ),
      );
}

/// 🌊 脉冲指示器
class FlowPulseIndicator extends StatefulWidget {
  const FlowPulseIndicator({
    required this.status,
    super.key,
    this.size = 24,
  });
  final FlowHealthStatus status;
  final double size;

  @override
  State<FlowPulseIndicator> createState() => _FlowPulseIndicatorState();
}

class _FlowPulseIndicatorState extends State<FlowPulseIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(widget.status);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        width: widget.size,
        height: widget.size,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.2 + _controller.value * 0.3),
          border: Border.all(
            color: color.withOpacity(0.6),
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.circle,
          color: color,
          size: widget.size * 0.6,
        ),
      ),
    );
  }

  Color _getStatusColor(FlowHealthStatus status) {
    switch (status) {
      case FlowHealthStatus.healthy:
        return FluxTheme.incomeGreen;
      case FlowHealthStatus.warning:
        return const Color(0xFFFF9500);
      case FlowHealthStatus.danger:
        return FluxTheme.expenseRed;
      case FlowHealthStatus.neutral:
        return FluxTheme.neutralGray;
      case FlowHealthStatus.static:
        return const Color(0xFF8E8E93);
    }
  }
}


