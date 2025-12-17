/// 🌊 Flux Ledger UI/UX 架构设计
///
/// 从传统静态界面到动态流式体验的全面重构

import 'package:flutter/material.dart';

/// 导航架构重构
/// 从三层静态架构 → 流式动态导航
class FluxNavigationArchitecture {
  /// 核心导航结构
  static const List<FluxNavItem> navigationItems = [
    FluxNavItem(
      id: 'dashboard',
      label: '流仪表板',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      description: '实时资金流可视化',
    ),
    FluxNavItem(
      id: 'streams',
      label: '流管道',
      icon: Icons.waterfall_chart_outlined,
      activeIcon: Icons.waterfall_chart,
      description: '管理持续性资金流',
    ),
    FluxNavItem(
      id: 'insights',
      label: '流洞察',
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights,
      description: 'AI智能分析与建议',
    ),
  ];
}

/// 导航项定义
class FluxNavItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String description;

  const FluxNavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.description,
  });
}

/// 页面架构重构
/// 从传统页面 → 流式页面组件
abstract class FluxPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final FlowPageType pageType;

  const FluxPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pageType,
  });
}

/// 页面类型枚举
enum FlowPageType {
  /// 仪表板页面 - 概览性质
  dashboard,

  /// 列表页面 - 数据展示
  list,

  /// 详情页面 - 详细信息
  detail,

  /// 创建页面 - 新建流程
  create,

  /// 编辑页面 - 修改流程
  edit,

  /// 设置页面 - 配置相关
  settings,
}

/// 流式卡片组件系统
/// 从静态卡片 → 动态流卡片
abstract class FlowCard extends StatelessWidget {
  final FlowCardType cardType;
  final FlowHealthStatus healthStatus;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FlowCard({
    super.key,
    required this.cardType,
    this.healthStatus = FlowHealthStatus.neutral,
    this.onTap,
    this.onLongPress,
  });

  Widget buildContent(BuildContext context);
}

/// 卡片类型
enum FlowCardType {
  /// 资金流卡片
  flow,

  /// 流管道卡片
  stream,

  /// 洞察卡片
  insight,

  /// 统计卡片
  statistic,

  /// 行动卡片
  action,
}

/// 流健康状态
enum FlowHealthStatus {
  /// 健康 - 绿色
  healthy,

  /// 警告 - 橙色
  warning,

  /// 危险 - 红色
  danger,

  /// 中性 - 灰色
  neutral,

  /// 静止 - 暂停状态
  static,
}

/// 流可视化组件
/// 核心创新：资金流动的可视化表达

/// 桑基图组件 - 资金流向可视化
class FlowSankeyChart extends StatelessWidget {
  final List<FlowNode> nodes;
  final List<FlowLink> links;
  final double width;
  final double height;

  const FlowSankeyChart({
    super.key,
    required this.nodes,
    required this.links,
    this.width = 300,
    this.height = 400,
  });

  @override
  Widget build(BuildContext context) {
    // 实现桑基图逻辑
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: SankeyPainter(nodes: nodes, links: links),
      ),
    );
  }
}

/// 桑基图节点
class FlowNode {
  final String id;
  final String name;
  final double value;
  final Color color;
  final Offset position;

  const FlowNode({
    required this.id,
    required this.name,
    required this.value,
    required this.color,
    required this.position,
  });
}

/// 桑基图连接
class FlowLink {
  final String source;
  final String target;
  final double value;
  final Color color;

  const FlowLink({
    required this.source,
    required this.target,
    required this.value,
    required this.color,
  });
}

/// 实时流图组件 - 动态资金流展示
class FlowRealtimeChart extends StatefulWidget {
  final Stream<FlowData> flowStream;
  final Duration updateInterval;

  const FlowRealtimeChart({
    super.key,
    required this.flowStream,
    this.updateInterval = const Duration(seconds: 1),
  });

  @override
  State<FlowRealtimeChart> createState() => _FlowRealtimeChartState();
}

class _FlowRealtimeChartState extends State<FlowRealtimeChart>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  FlowData? _currentData;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    widget.flowStream.listen((data) {
      setState(() => _currentData = data);
      _controller.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: RealtimeFlowPainter(
            data: _currentData!,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// 流数据模型
class FlowData {
  final double inflow;
  final double outflow;
  final double balance;
  final List<FlowPoint> points;

  const FlowData({
    required this.inflow,
    required this.outflow,
    required this.balance,
    required this.points,
  });
}

/// 流数据点
class FlowPoint {
  final DateTime time;
  final double value;
  final FlowPointType type;

  const FlowPoint({
    required this.time,
    required this.value,
    required this.type,
  });
}

/// 流数据点类型
enum FlowPointType {
  inflow,
  outflow,
  balance,
}

/// 流脉动指示器 - 实时状态反馈
class FlowPulseIndicator extends StatefulWidget {
  final FlowHealthStatus status;
  final double size;

  const FlowPulseIndicator({
    super.key,
    required this.status,
    this.size = 24,
  });

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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(widget.status);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.3 + _controller.value * 0.7),
          ),
          child: Icon(
            Icons.circle,
            color: color,
            size: widget.size * 0.6,
          ),
        );
      },
    );
  }

  Color _getStatusColor(FlowHealthStatus status) {
    switch (status) {
      case FlowHealthStatus.healthy:
        return const Color(0xFF34C759);
      case FlowHealthStatus.warning:
        return const Color(0xFFFF9500);
      case FlowHealthStatus.danger:
        return const Color(0xFFFF3B30);
      case FlowHealthStatus.neutral:
        return const Color(0xFF8E8E93);
      case FlowHealthStatus.static:
        return const Color(0xFF8E8E93);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// 流式录入组件
/// 从传统表单 → 智能流引导

class FlowEntryWizard extends StatefulWidget {
  final FlowEntryType entryType;

  const FlowEntryWizard({
    super.key,
    required this.entryType,
  });

  @override
  State<FlowEntryWizard> createState() => _FlowEntryWizardState();
}

class _FlowEntryWizardState extends State<FlowEntryWizard> {
  int _currentStep = 0;
  final Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getStepTitle()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // 步骤指示器
          FlowStepIndicator(
            currentStep: _currentStep,
            totalSteps: _getTotalSteps(),
          ),

          // 步骤内容
          Expanded(
            child: _buildCurrentStep(),
          ),

          // 行动按钮
          FlowActionButtons(
            onPrevious: _currentStep > 0 ? _previousStep : null,
            onNext: _canProceed() ? _nextStep : null,
            nextLabel: _currentStep == _getTotalSteps() - 1 ? '完成' : '下一步',
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    // 根据当前步骤返回标题
    return '流录入向导';
  }

  int _getTotalSteps() {
    // 根据录入类型返回总步骤数
    return 3;
  }

  Widget _buildCurrentStep() {
    // 根据当前步骤构建相应的界面
    return const Placeholder();
  }

  bool _canProceed() {
    // 检查当前步骤是否可以前进
    return true;
  }

  void _nextStep() {
    if (_currentStep < _getTotalSteps() - 1) {
      setState(() => _currentStep++);
    } else {
      _completeFlow();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _completeFlow() {
    // 完成流录入
    Navigator.of(context).pop(_formData);
  }
}

/// 录入类型枚举
enum FlowEntryType {
  /// 快速录入
  quick,

  /// 详细录入
  detailed,

  /// 流管道录入
  stream,

  /// 批量录入
  batch,
}

/// 步骤指示器组件
class FlowStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const FlowStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(totalSteps, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= currentStep
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 行动按钮组件
class FlowActionButtons extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String nextLabel;

  const FlowActionButtons({
    super.key,
    this.onPrevious,
    this.onNext,
    this.nextLabel = '下一步',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (onPrevious != null)
            Expanded(
              child: OutlinedButton(
                onPressed: onPrevious,
                child: const Text('上一步'),
              ),
            ),
          if (onPrevious != null) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: onNext,
              child: Text(nextLabel),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 占位符实现 ====================

/// 桑基图绘制器
class SankeyPainter extends CustomPainter {
  final List<FlowNode> nodes;
  final List<FlowLink> links;

  const SankeyPainter({required this.nodes, required this.links});

  @override
  void paint(Canvas canvas, Size size) {
    // 实现桑基图绘制逻辑
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 实时流绘制器
class RealtimeFlowPainter extends CustomPainter {
  final FlowData data;
  final double animationValue;

  const RealtimeFlowPainter({
    required this.data,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 实现实时流图绘制逻辑
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 流式页面结构
/// 统一的页面布局框架

abstract class FlowPageStructure extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget body;
  final Widget? bottomBar;

  const FlowPageStructure({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
    required this.body,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FF), // 流背景色
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8E8E93),
                  ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: bottomBar,
    );
  }
}

