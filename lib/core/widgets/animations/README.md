# Animation Components 动画组件文档

## 概述

`core/widgets/animations/` 是Flux Ledger的动画组件集合，提供丰富的动画效果和交互体验，支持应用的视觉流畅性和用户参与度。

**文件统计**: 4个Dart文件，实现基础动画、导航动画和金融动画

## 架构定位

### 层级关系
```
UI Layer (交互组件)               # 使用动画
    ↓ (动画增强)
core/widgets/animations/           # 🔵 当前层级 - 动画组件
    ↓ (动画实现)
core/widgets/                      # 基础组件
    ↓ (样式系统)
core/theme/                        # 设计令牌
```

### 职责边界
- ✅ **动画效果**: 提供流畅的视觉过渡和交互反馈
- ✅ **性能优化**: 高效的动画实现和资源管理
- ✅ **可复用性**: 通用动画组件的封装和复用
- ✅ **平台适配**: 跨平台动画效果的统一性
- ❌ **业务逻辑**: 不包含动画触发逻辑
- ❌ **数据处理**: 不负责动画数据的计算

## 动画组件分类

### 1. 基础动画组件 (1个文件)

#### AppAnimations (`components/app_animations.dart`)
**职责**: 提供通用的动画工具和辅助函数

**核心功能**:
- 基础动画控制器管理
- 常用动画曲线定义
- 动画状态监听和回调
- 性能监控集成

**关联关系**:
- **依赖**: Flutter动画框架
- **被依赖**: 所有其他动画组件
- **级联影响**: 动画系统的整体性能和一致性

### 2. 导航动画组件 (1个文件)

#### NavigationAnimations (`navigation/navigation_animations.dart`)
**职责**: 页面导航和转场相关的动画效果

**核心功能**:
- 页面切换动画
- 路由转场效果
- 导航栏动画
- 返回手势动画

**关联关系**:
- **依赖**: `core/router/flux_router.dart` (路由系统)
- **被依赖**: `screens/main_navigation_screen.dart` (主导航)
- **级联影响**: 页面切换的用户体验

### 3. 金融动画组件 (2个文件)

#### FinancialAnimations (`financial/financial_animations.dart`)
**职责**: 金融数据展示相关的动画效果

**核心功能**:
- 金额数字滚动动画
- 图表数据过渡动画
- 资产变动视觉反馈
- 财务指标动画展示

**关联关系**:
- **依赖**: 金融数据模型和计算
- **被依赖**: 资产管理、预算分析等金融页面
- **级联影响**: 财务数据的视觉吸引力和理解性

#### FinancialAnimationSrc (`financial/src/`)
**职责**: 金融动画的底层实现和资源文件

**核心功能**:
- 动画算法实现
- 性能优化逻辑
- 平台特定适配
- 资源文件管理

**关联关系**:
- **依赖**: `FinancialAnimations` (接口定义)
- **被依赖**: 金融动画的具体实现
- **级联影响**: 金融动画的性能和效果

## 动画设计原则

### 1. 性能优先
所有动画都经过性能优化，确保60fps流畅运行。

### 2. 语义明确
动画效果与用户操作意图保持一致。

### 3. 渐进增强
在低性能设备上 gracefully degrade。

### 4. 无障碍友好
考虑动画对视觉障碍用户的影响。

## 动画使用模式

### 基础动画应用
```dart
// 淡入动画
Widget fadeInWidget = AppAnimations.fadeIn(
  child: MyWidget(),
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
);

// 缩放动画
Widget scaleWidget = AppAnimations.scale(
  child: IconButton(icon: Icon(Icons.add), onPressed: () {}),
  scale: 1.2,
  duration: Duration(milliseconds: 200),
);
```

### 导航动画集成
```dart
// 页面切换动画
Navigator.push(
  context,
  NavigationAnimations.slideTransition(
    page: NewPage(),
    direction: SlideDirection.fromRight,
  ),
);

// 底部导航切换
BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: (index) {
    NavigationAnimations.tabSwitch(
      fromIndex: _currentIndex,
      toIndex: index,
      onComplete: () => setState(() => _currentIndex = index),
    );
  },
  items: navigationItems,
);
```

### 金融动画展示
```dart
// 金额滚动显示
FinancialAnimations.amountRoll(
  startAmount: oldAmount,
  endAmount: newAmount,
  duration: Duration(milliseconds: 800),
  style: AppDesignTokens.amountLarge,
  builder: (amount) => Text(
    CurrencyFormatter.formatAmount(amount, currency),
    style: style,
  ),
);

// 图表数据过渡
FinancialAnimations.chartTransition(
  oldData: previousChartData,
  newData: currentChartData,
  duration: Duration(milliseconds: 600),
  curve: Curves.easeInOutCubic,
);
```

## 动画性能优化

### 1. 硬件加速
充分利用GPU进行动画渲染。

### 2. 内存管理
及时释放动画控制器和资源。

### 3. 批处理更新
合并多个动画状态更新。

### 4. 智能缓存
缓存常用动画配置和资源。

## 动画测试策略

### 动画功能测试
- 动画触发和执行正确性
- 动画参数和曲线应用
- 动画完成回调验证

### 性能测试
- 动画帧率稳定性测试
- 内存使用监控
- 电池消耗评估

### 兼容性测试
- 不同设备性能表现
- 操作系统版本兼容性
- 辅助功能兼容性

## 扩展开发

### 创建新的基础动画
```dart
class CustomAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const CustomAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * pi,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
```

### 添加导航动画
```dart
class CustomPageTransition extends PageRouteBuilder {
  final Widget page;

  CustomPageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}
```

### 实现金融动画
```dart
class AmountCounter extends StatefulWidget {
  final double startAmount;
  final double endAmount;
  final Duration duration;
  final TextStyle style;

  const AmountCounter({
    super.key,
    required this.startAmount,
    required this.endAmount,
    required this.duration,
    required this.style,
  });

  @override
  State<AmountCounter> createState() => _AmountCounterState();
}

class _AmountCounterState extends State<AmountCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.startAmount,
      end: widget.endAmount,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          CurrencyFormatter.formatAmount(_animation.value, 'CNY'),
          style: widget.style,
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
```

## 使用指南

### 选择合适的动画
1. **基础动画**: 用于简单的视觉反馈
2. **导航动画**: 用于页面切换和导航
3. **金融动画**: 用于数据展示和财务信息

### 动画参数调优
```dart
// 快速反馈
AppAnimations.fadeIn(
  duration: Duration(milliseconds: 150),
  curve: Curves.linear,
);

// 平滑过渡
NavigationAnimations.slideTransition(
  duration: Duration(milliseconds: 350),
  curve: Curves.easeInOutCubic,
);

// 吸引注意
FinancialAnimations.amountRoll(
  duration: Duration(milliseconds: 800),
  curve: Curves.elasticOut,
);
```

### 性能监控
```dart
// 启用动画性能监控
AppAnimations.enablePerformanceMonitoring();

// 检查动画性能
final metrics = AppAnimations.getPerformanceMetrics();
print('平均帧率: ${metrics.averageFps}');
print('掉帧次数: ${metrics.droppedFrames}');
```

## 相关文档

- [Widgets组件库文档](../README.md)
- [设计系统文档](../../theme/README.md)
- [Flutter动画指南](https://docs.flutter.dev/development/ui/animations)



