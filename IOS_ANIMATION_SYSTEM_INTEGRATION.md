# iOS动效系统集成指南

## 概述

iOS动效系统是一个企业级的Flutter动效解决方案，专为iOS应用设计，提供了完整的动效组件库和性能监控能力。本系统基于Notion iOS版本的动效实现，支持手势反馈、状态变化、导航过渡和特殊效果。

## 架构概览

```
lib/core/animations/
├── ios_animation_system.dart      # 🏢 企业级动效系统主入口
├── ios_animation_system_test.dart # 🧪 单元测试
├── animation_config.dart          # ⚙️  配置和常量
├── animation_engine.dart          # 🚀 核心动画引擎
├── ios_gesture_animations.dart    # 👆 手势反馈动效
├── ios_state_animations.dart      # 🔄 状态变化动效
├── ios_navigation_animations.dart # 🧭 导航过渡动效
├── ios_special_effects.dart       # ✨ 特殊效果动效
└── ios_animation_manager.dart     # 🎯 统一管理器API
```

## 快速开始

### 1. 初始化系统

```dart
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';

// 获取单例实例
final animationSystem = IOSAnimationSystem();

// 配置主题（可选）
animationSystem.updateTheme(
  const IOSAnimationTheme(
    enableAnimations: true,
    enableHapticFeedback: true,
    respectReducedMotion: true,
    animationSpeed: 1.0,
    enablePerformanceMonitoring: false,
  ),
);
```

### 2. 使用动效组件

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // iOS风格按钮
        animationSystem.iosButton(
          child: const Text('点击我'),
          onPressed: () => print('按钮被点击'),
        ),

        const SizedBox(height: 16),

        // iOS风格卡片
        animationSystem.iosCard(
          child: const Text('卡片内容'),
          onTap: () => print('卡片被点击'),
        ),

        const SizedBox(height: 16),

        // iOS风格列表项
        animationSystem.iosListItem(
          child: const Text('列表项'),
          onTap: () => print('列表项被点击'),
        ),
      ],
    );
  }
}
```

## 核心组件

### 按钮组件

```dart
// 填充按钮（默认）
animationSystem.iosButton(
  child: const Text('主要操作'),
  onPressed: () => handlePrimaryAction(),
  style: IOSButtonStyle.filled, // 默认值
);

// 轮廓按钮
animationSystem.iosButton(
  child: const Text('次要操作'),
  onPressed: () => handleSecondaryAction(),
  style: IOSButtonStyle.outlined,
);

// 文本按钮
animationSystem.iosButton(
  child: const Text('取消'),
  onPressed: () => handleCancel(),
  style: IOSButtonStyle.text,
);

// 禁用状态
animationSystem.iosButton(
  child: const Text('禁用按钮'),
  onPressed: () => handleAction(),
  enabled: false, // 会自动降低透明度
);
```

### 卡片组件

```dart
animationSystem.iosCard(
  child: Column(
    children: [
      const Text('卡片标题'),
      const Text('卡片内容'),
    ],
  ),
  padding: const EdgeInsets.all(16),
  backgroundColor: Colors.white,
  elevation: 2,
  onTap: () => handleCardTap(),
);
```

### 列表项组件

```dart
Column(
  children: [
    animationSystem.iosListItem(
      child: const Text('第一项'),
      onTap: () => handleItem1(),
    ),
    animationSystem.iosListItem(
      child: const Text('第二项'),
      onTap: () => handleItem2(),
    ),
    animationSystem.iosListItem(
      child: const Text('最后一项'),
      isLast: true, // 移除底部边框
      onTap: () => handleItem3(),
    ),
  ],
);
```

### 模态弹窗

```dart
Future<void> showMyModal(BuildContext context) async {
  final result = await animationSystem.showIOSModal<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('确认操作'),
      content: const Text('您确定要执行此操作吗？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop('cancel'),
          child: const Text('取消'),
        ),
        animationSystem.iosButton(
          child: const Text('确认'),
          onPressed: () => Navigator.of(context).pop('confirm'),
          style: IOSButtonStyle.filled,
        ),
      ],
    ),
    barrierDismissible: true,
  );

  if (result == 'confirm') {
    // 处理确认操作
  }
}
```

## 高级用法

### 自定义动效序列

```dart
class AdvancedAnimationWidget extends StatefulWidget {
  @override
  State<AdvancedAnimationWidget> createState() => _AdvancedAnimationWidgetState();
}

class _AdvancedAnimationWidgetState extends State<AdvancedAnimationWidget>
    with TickerProviderStateMixin {

  final animationSystem = IOSAnimationSystem();

  Future<void> _performComplexAnimation() async {
    await animationSystem.executeSequence(
      animationId: 'complex-sequence',
      vsync: this,
      specs: const [
        IOSAnimationSpec.buttonTap,
        IOSAnimationSpec.successFeedback,
      ],
      onComplete: () => print('动效序列完成'),
      onError: () => print('动效序列失败'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return animationSystem.iosButton(
      child: const Text('执行复杂动效'),
      onPressed: _performComplexAnimation,
    );
  }
}
```

### 性能监控

```dart
// 启用性能监控
animationSystem.updateTheme(
  const IOSAnimationTheme(
    enablePerformanceMonitoring: true,
  ),
);

// 在控制台查看性能指标
// [IOSAnimationSystem] Animation "button-tap" completed in 250ms (success)
```

## 主题配置

### 全局主题设置

```dart
class AppThemeProvider extends InheritedWidget {
  final IOSAnimationSystem animationSystem;

  const AppThemeProvider({
    super.key,
    required this.animationSystem,
    required super.child,
  });

  static IOSAnimationSystem of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppThemeProvider>();
    return provider!.animationSystem;
  }

  @override
  bool updateShouldNotify(AppThemeProvider oldWidget) => false;
}
```

### 响应用户偏好

```dart
class AccessibilityManager {
  static IOSAnimationTheme getAdaptiveTheme(BuildContext context) {
    // 检查系统辅助功能设置
    final brightness = MediaQuery.of(context).platformBrightness;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return IOSAnimationTheme(
      // 在高对比度模式下增强动效
      animationSpeed: brightness == Brightness.dark ? 1.2 : 1.0,
      // 尊重用户的文字大小偏好
      respectReducedMotion: textScale > 1.5,
    );
  }
}
```

## 最佳实践

### 1. 性能优化

```dart
class OptimizedWidget extends StatefulWidget {
  @override
  State<OptimizedWidget> createState() => _OptimizedWidgetState();
}

class _OptimizedWidgetState extends State<OptimizedWidget>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  final animationSystem = IOSAnimationSystem();

  @override
  void dispose() {
    animationSystem.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return animationSystem.iosListItem(
      child: const Text('优化的列表项'),
      onTap: () => _handleTap(),
    );
  }
}
```

### 2. 错误处理

```dart
class RobustWidget extends StatelessWidget {
  final animationSystem = IOSAnimationSystem();

  Future<void> _safeAnimation() async {
    try {
      await animationSystem.executeAnimation(
        animationId: 'safe-animation',
        vsync: this as TickerProvider,
        spec: IOSAnimationSpec.buttonTap,
      );
    } catch (e) {
      // 记录错误但不中断用户操作
      debugPrint('Animation failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return animationSystem.iosButton(
      child: const Text('安全动效'),
      onPressed: _safeAnimation,
    );
  }
}
```

### 3. 无障碍支持

```dart
class AccessibleWidget extends StatelessWidget {
  final animationSystem = IOSAnimationSystem();

  @override
  Widget build(BuildContext context) {
    // 检查无障碍设置
    final mediaQuery = MediaQuery.of(context);

    return animationSystem.iosButton(
      child: const Text('无障碍按钮'),
      onPressed: () => _handleTap(),
      // 在大文字模式下禁用复杂动效
      enabled: mediaQuery.textScaleFactor <= 1.5,
    );
  }
}
```

## 测试指南

### 单元测试

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';

void main() {
  group('IOSAnimationSystem', () {
    late IOSAnimationSystem system;

    setUp(() {
      system = IOSAnimationSystem();
    });

    tearDown(() {
      system.dispose();
    });

    test('should create button correctly', () {
      final button = system.iosButton(
        child: const Text('Test'),
        onPressed: () {},
      );

      expect(button, isNotNull);
    });

    test('should handle disabled state', () {
      final disabledButton = system.iosButton(
        child: const Text('Disabled'),
        onPressed: () {},
        enabled: false,
      );

      // 测试禁用状态的视觉反馈
    });
  });
}
```

### 集成测试

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';

void main() {
  group('Animation Integration Tests', () {
    testWidgets('button tap animation works', (tester) async {
      final system = IOSAnimationSystem();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: system.iosButton(
              child: const Text('Tap Me'),
              onPressed: () {},
            ),
          ),
        ),
      );

      // 模拟点击
      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      // 验证动效触发
      // 这里可以添加具体的动效验证逻辑
    });
  });
}
```

## 故障排除

### 常见问题

#### 1. 动效不播放
```dart
// 检查是否禁用了动画
final theme = animationSystem.currentTheme;
if (!theme.enableAnimations) {
  debugPrint('Animations are disabled');
}

// 检查动画速度
if (theme.animationSpeed == 0.0) {
  debugPrint('Animation speed is zero');
}
```

#### 2. 内存泄漏
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final animationSystem = IOSAnimationSystem();

  @override
  void dispose() {
    animationSystem.dispose();
    super.dispose();
  }

  // ... 其他代码
}
```

#### 3. 性能问题
```dart
// 启用性能监控
animationSystem.updateTheme(
  const IOSAnimationTheme(
    enablePerformanceMonitoring: true,
  ),
);

// 检查控制台输出，识别慢速动效
```

## 更新日志

### v1.0.0 (2025-01-15)
- ✨ 初始发布企业级iOS动效系统
- 🎯 支持手势反馈、状态变化、导航过渡
- 📊 集成性能监控和错误处理
- 🧪 包含完整的单元测试和集成测试
- 📚 提供详细的集成文档和最佳实践

## 贡献指南

### 代码规范
1. 使用`const`构造函数避免不必要的重建
2. 正确实现`dispose`方法释放资源
3. 添加适当的错误处理
4. 遵循Flutter的命名约定

### 测试要求
1. 为新组件添加单元测试
2. 验证无障碍功能
3. 测试性能影响
4. 确保向后兼容

## 许可证

本项目采用MIT许可证。详见LICENSE文件。

---

## 联系我们

如有问题或建议，请通过以下方式联系：
- 📧 Email: animation-team@company.com
- 💬 Slack: #ios-animation-system
- 📖 文档: [内部文档链接]

---

**🎉 祝您使用愉快！**
