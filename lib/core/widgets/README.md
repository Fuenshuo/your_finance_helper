# Core Widgets 组件库文档

## 概述

`core/widgets/` 是Flux Ledger的核心UI组件库，提供可复用的界面组件和交互元素，确保应用UI的一致性和用户体验质量。

**文件统计**: 39个Dart文件，涵盖基础组件、复合组件和动画系统

## 架构定位

### 层级关系
```
UI Layer (Screens)                  # 页面实现
    ↓ (组件组合)
core/widgets/                       # 🔵 当前层级 - 组件库
    ↓ (样式应用)
core/theme/                         # 设计系统
    ↓ (基础渲染)
Flutter Framework                    # UI框架
```

### 职责边界
- ✅ **UI组件**: 提供可复用的界面元素
- ✅ **交互逻辑**: 封装常见的用户交互模式
- ✅ **样式一致性**: 确保组件的视觉统一性
- ✅ **平台适配**: 处理跨平台兼容性
- ❌ **业务逻辑**: 不包含具体的业务处理
- ❌ **数据管理**: 不负责数据状态维护

## 组件分类

### 1. 基础UI组件 (15个文件)

#### 核心容器组件
- **AppCard** (`app_card.dart`): 统一卡片组件，带有阴影和圆角
- **AppEmptyState** (`app_empty_state.dart`): 空状态展示组件
- **AppErrorHandler** (`app_error_handler.dart`): 错误状态处理组件

#### 表单和输入组件
- **AmountInputField** (`amount_input_field.dart`): 金额输入组件，支持格式化和验证
- **AppTextField** (`app_text_field.dart`): 统一文本输入组件
- **AppSelectionControls** (`app_selection_controls.dart`): 选择控件组件

#### 按钮和操作组件
- **AppPrimaryButton** (`app_primary_button.dart`): 主操作按钮
- **EnhancedFloatingActionButton** (`enhanced_floating_action_button.dart`): 增强型浮动操作按钮

#### 反馈和状态组件
- **GlassNotification** (`glass_notification.dart`): 玻璃态通知组件
- **AppShimmer** (`app_shimmer.dart`): 加载骨架屏组件
- **DataRefreshAnimation** (`data_refresh_animation.dart`): 数据刷新动画

#### 标签和标记组件
- **AppTag** (`app_tag.dart`): 标签组件
- **SwipeActionItem** (`swipe_action_item.dart`): 滑动操作项

#### 图表和可视化组件
- **SankeyChartWidget** (`sankey_chart_widget.dart`): 桑基图组件
- **TrendChartWidget** (`trend_chart_widget.dart`): 趋势图组件
- **OverviewTrendChart** (`overview_trend_chart.dart`): 概览趋势图

### 2. 复合组件系统 (7个文件)

#### 导航和列表组件
- **ActionableListItem** (`composite/actionable_list_item.dart`): 可操作列表项
- **NavigableListItem** (`composite/navigable_list_item.dart`): 可导航列表项
- **StandardListItem** (`composite/standard_list_item.dart`): 标准列表项

#### 控制和选择组件
- **SwitchControlListItem** (`composite/switch_control_list_item.dart`): 开关控制列表项
- **ExpandableCalculationItem** (`composite/expandable_calculation_item.dart`): 可展开计算项

#### 高级复合组件
- **NavigableListItem** (`composite/navigable_list_item.dart`): 导航式列表项，集成路由跳转
- **SwitchControlListItem** (`composite/switch_control_list_item.dart`): 开关控制项，支持状态切换

### 3. 动画组件系统 (25个文件)

#### 动画基础组件 (1个文件)
- **AppAnimations** (`animations/components/app_animations.dart`): 动画工具和辅助函数

#### 金融动画组件 (2个文件)
- **FinancialAnimations** (`animations/financial/financial_animations.dart`): 金融相关的动画效果
- **FinancialAnimationSrc** (`animations/financial/src/`): 金融动画源文件

#### 导航动画组件 (1个文件)
- **NavigationAnimations** (`animations/navigation/navigation_animations.dart`): 导航相关的动画效果

## 组件设计原则

### 1. 组合优于继承
使用组合模式构建复杂组件，提高复用性。

### 2. 属性驱动
通过属性控制组件的外观和行为。

### 3. 主题一致性
所有组件都遵循设计系统规范。

### 4. 响应式设计
支持不同屏幕尺寸和设备类型。

### 5. 无障碍性
提供完整的无障碍功能支持。

## 组件使用模式

### 基础组件使用
```dart
// 卡片组件
AppCard(
  child: Column(
    children: [
      Text('标题'),
      Text('内容'),
    ],
  ),
)

// 按钮组件
AppPrimaryButton(
  onPressed: () => print('点击'),
  child: Text('确定'),
)
```

### 复合组件使用
```dart
// 可导航列表项
NavigableListItem(
  title: '设置',
  subtitle: '应用设置',
  onTap: () => context.go('/settings'),
  leading: Icon(Icons.settings),
)

// 开关控制项
SwitchControlListItem(
  title: '通知',
  subtitle: '开启推送通知',
  value: notificationsEnabled,
  onChanged: (value) => setState(() => notificationsEnabled = value),
)
```

### 动画组件使用
```dart
// 基础动画
AppAnimations.fadeIn(
  child: MyWidget(),
  duration: Duration(milliseconds: 300),
)

// 金融动画
FinancialAnimations.amountCounter(
  startAmount: 0.0,
  endAmount: 1234.56,
  duration: Duration(seconds: 1),
)
```

## 样式系统集成

### 设计令牌应用
所有组件都使用`AppDesignTokens`确保一致性：

```dart
Container(
  padding: EdgeInsets.all(AppDesignTokens.spaceMedium),
  decoration: BoxDecoration(
    color: AppDesignTokens.surfaceWhite,
    borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
    boxShadow: [AppDesignTokens.shadowSmall],
  ),
)
```

### 主题适配
组件自动适配亮色和暗色主题：

```dart
Color backgroundColor = Theme.of(context).colorScheme.surface;
Color textColor = Theme.of(context).colorScheme.onSurface;
```

## 性能优化

### 1. 组件缓存
常用组件的实例缓存，避免重复创建。

### 2. 懒加载
组件的按需加载和渲染。

### 3. 动画优化
高效的动画实现，控制帧率。

### 4. 内存管理
及时释放资源，防止内存泄漏。

## 测试策略

### 组件测试
- 组件渲染正确性测试
- 交互行为测试
- 属性变化响应测试

### 集成测试
- 组件在页面中的表现测试
- 多组件协同工作测试
- 主题切换测试

### 视觉回归测试
- 组件外观一致性测试
- 响应式布局测试
- 动画效果测试

## 扩展开发

### 创建新的基础组件
```dart
class NewBaseWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const NewBaseWidget({
    super.key,
    required this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        title: Text(title, style: AppDesignTokens.titleMedium),
        onTap: onPressed,
      ),
    );
  }
}
```

### 添加复合组件
```dart
class NewCompositeWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;

  const NewCompositeWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return StandardListItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
    );
  }
}
```

### 实现动画组件
```dart
class NewAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const NewAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<NewAnimation> createState() => _NewAnimationState();
}

class _NewAnimationState extends State<NewAnimation>
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
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.scale(
            scale: _animation.value,
            child: widget.child,
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
```

## 使用指南

### 组件选择
1. **基础组件**: 用于简单UI元素
2. **复合组件**: 用于复杂交互模式
3. **动画组件**: 用于增强用户体验

### 样式覆盖
在必要时可以通过属性覆盖默认样式：

```dart
AppCard(
  backgroundColor: Colors.blue,  // 覆盖默认背景色
  borderRadius: 12.0,           // 覆盖默认圆角
  child: MyContent(),
)
```

### 自定义扩展
对于特殊需求，可以继承现有组件：

```dart
class CustomButton extends AppPrimaryButton {
  const CustomButton({
    super.key,
    required super.onPressed,
    required super.child,
    this.customColor,
  });

  final Color? customColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: customColor ?? Theme.of(context).primaryColor,
      ),
      child: child,
    );
  }
}
```

## 相关文档

- [Core包总文档](../README.md)
- [设计系统文档](../theme/README.md)
- [UI设计规范](../../../.cursor/rules/ui-design-system.mdc)
