/// 🌊 Flux Ledger UI/UX 架构设计
///
/// 从传统静态界面到动态流式体验的全面重构
library;

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
  const FluxNavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.description,
  });
  final String id;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String description;
}

/// 页面架构重构
/// 从传统页面 → 流式页面组件
abstract class FluxPage extends StatefulWidget {
  const FluxPage({
    required this.title,
    required this.subtitle,
    required this.pageType,
    super.key,
  });
  final String title;
  final String subtitle;
  final FlowPageType pageType;
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
  const FlowCard({
    required this.cardType,
    super.key,
    this.healthStatus = FlowHealthStatus.neutral,
    this.onTap,
    this.onLongPress,
  });
  final FlowCardType cardType;
  final FlowHealthStatus healthStatus;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

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
  const FlowSankeyChart({
    required this.nodes,
    required this.links,
    super.key,
    this.width = 300,
    this.height = 400,
  });
  final List<FlowNode> nodes;
  final List<FlowLink> links;
  final double width;
  final double height;

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
  const FlowNode({
    required this.id,
    required this.name,
    required this.value,
    required this.color,
    required this.position,
  });
  final String id;
  final String name;
  final double value;
  final Color color;
  final Offset position;
}

/// 桑基图连接
class FlowLink {
  const FlowLink({
    required this.source,
    required this.target,
    required this.value,
    required this.color,
  });
  final String source;
  final String target;
  final double value;
  final Color color;
}

/// 实时流图组件 - 动态资金流展示
class FlowRealtimeChart extends StatefulWidget {
  const FlowRealtimeChart({
    required this.flowStream,
    super.key,
    this.updateInterval = const Duration(seconds: 1),
  });
  final Stream<FlowData> flowStream;
  final Duration updateInterval;

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
      builder: (context, child) => CustomPaint(
        painter: RealtimeFlowPainter(
          data: _currentData!,
          animationValue: _controller.value,
        ),
      ),
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
  const FlowData({
    required this.inflow,
    required this.outflow,
    required this.balance,
    required this.points,
  });
  final double inflow;
  final double outflow;
  final double balance;
  final List<FlowPoint> points;
}

/// 流数据点
class FlowPoint {
  const FlowPoint({
    required this.time,
    required this.value,
    required this.type,
  });
  final DateTime time;
  final double value;
  final FlowPointType type;
}

/// 流数据点类型
enum FlowPointType {
  inflow,
  outflow,
  balance,
}

/// 流脉动指示器 - 实时状态反馈
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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(widget.status);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
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
      ),
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
  const FlowEntryWizard({
    required this.entryType,
    super.key,
  });
  final FlowEntryType entryType;

  @override
  State<FlowEntryWizard> createState() => _FlowEntryWizardState();
}

class _FlowEntryWizardState extends State<FlowEntryWizard> {
  int _currentStep = 0;
  final Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) => Scaffold(
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
  const FlowStepIndicator({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: List.generate(
            totalSteps,
            (index) => Expanded(
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
            ),
          ),
        ),
      );
}

/// 行动按钮组件
class FlowActionButtons extends StatelessWidget {
  const FlowActionButtons({
    super.key,
    this.onPrevious,
    this.onNext,
    this.nextLabel = '下一步',
  });
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String nextLabel;

  @override
  Widget build(BuildContext context) => Container(
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

// ==================== 占位符实现 ====================

/// 桑基图绘制器
class SankeyPainter extends CustomPainter {
  const SankeyPainter({required this.nodes, required this.links});
  final List<FlowNode> nodes;
  final List<FlowLink> links;

  @override
  void paint(Canvas canvas, Size size) {
    // 实现桑基图绘制逻辑
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 实时流绘制器
class RealtimeFlowPainter extends CustomPainter {
  const RealtimeFlowPainter({
    required this.data,
    required this.animationValue,
  });
  final FlowData data;
  final double animationValue;

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
  const FlowPageStructure({
    required this.title,
    required this.subtitle,
    required this.body,
    super.key,
    this.actions = const [],
    this.bottomBar,
  });
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget body;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) => Scaffold(
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
