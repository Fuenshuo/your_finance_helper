# Core Theme 主题系统文档

## 概述

`core/theme/` 是Flux Ledger的设计系统核心，定义了应用统一的视觉语言、色彩系统、字体规范和响应式布局规则，确保整个应用的一致性和专业性。

**文件统计**: 4个Dart文件，实现完整的设计系统

## 架构定位

### 层级关系
```
UI Layer (所有组件)               # 使用主题
    ↓ (Theme.of(context))
core/theme/                        # 🔵 当前层级 - 设计系统
    ↓ (AppDesignTokens)
Material Design 3 + Flux视觉规范   # 基础设计语言
    ↓ (颜色/字体/间距)
操作系统 (iOS/Android)             # 平台适配
```

### 职责边界
- ✅ **设计系统**: 定义统一的视觉规范和设计语言
- ✅ **主题管理**: 亮色/暗色主题的完整实现
- ✅ **响应式设计**: 多设备适配和字体缩放
- ✅ **组件样式**: 通用组件的样式定义
- ❌ **业务逻辑**: 不包含具体的业务功能
- ❌ **数据处理**: 不负责数据展示逻辑

## 核心组件

### 1. 设计令牌系统 (1个文件)

#### AppDesignTokens (`app_design_tokens.dart`)
**职责**: 应用的设计令牌系统，定义所有视觉元素的标准值

**核心内容**:
- **色彩系统**: 基础色板、语义色彩、状态色彩
- **字体系统**: 字体族、字体大小、字体权重
- **间距系统**: 标准间距值、容器边距
- **圆角系统**: 组件圆角规范
- **阴影系统**: 阴影样式定义

**关联关系**:
- **依赖**: Flutter的Material Design系统
- **被依赖**: 所有UI组件和样式定义
- **级联影响**: 整个应用的视觉一致性

### 2. 主题定义 (1个文件)

#### AppTheme (`app_theme.dart`)
**职责**: Material Design 3主题的完整实现

**核心功能**:
- ThemeData配置和自定义
- 组件主题覆盖 (AppBar, Card, Button等)
- 平台适配 (iOS/Android差异处理)
- 主题扩展支持

**关联关系**:
- **依赖**: `AppDesignTokens` (设计令牌)
- **被依赖**: `main_flux.dart` (应用主题设置)
- **级联影响**: 所有Material组件的样式

### 3. Flux主题扩展 (1个文件)

#### FluxTheme (`flux_theme.dart`)
**职责**: Flux Ledger特有的主题扩展和视觉特性

**核心功能**:
- Flux品牌色彩系统
- 特殊的视觉效果定义
- 动画和转场主题
- 自定义组件主题

**关联关系**:
- **依赖**: `AppTheme` (基础主题)
- **被依赖**: Flux特有的UI组件
- **级联影响**: Flux视觉体验的独特性

### 4. 响应式字体系统 (1个文件)

#### ResponsiveTextStyles (`responsive_text_styles.dart`)
**职责**: 响应式的文本样式系统，支持多设备适配

**核心功能**:
- 基于设备尺寸的字体缩放
- 文本层次结构定义
- 无障碍性字体支持
- 平台特定的字体调整

**关联关系**:
- **依赖**: 设备信息和屏幕参数
- **被依赖**: 所有文本显示组件
- **级联影响**: 文本的可读性和适配性

## 设计系统架构

### 令牌层级结构
```
基础令牌 (Base Tokens)
├── 色彩 (Colors)
│   ├── 原始色彩 (Primitive Colors)
│   ├── 语义色彩 (Semantic Colors)
│   └── 组件色彩 (Component Colors)
├── 字体 (Typography)
│   ├── 字体族 (Font Families)
│   ├── 字体大小 (Font Sizes)
│   └── 字体权重 (Font Weights)
└── 间距 (Spacing)
    ├── 标准间距 (Standard Spacing)
    └── 容器边距 (Container Spacing)
```

### 主题应用流程
```
设计令牌 → 主题配置 → 组件样式 → UI渲染
```

## 色彩系统

### 基础色板
```dart
class AppDesignTokens {
  // 活力蓝 - 主要品牌色
  static const Color primaryBlue = Color(0xFF007AFF);

  // 深邃灰 - 主要文字色
  static const Color textPrimary = Color(0xFF1C1C1E);

  // 淡雅灰 - 背景色
  static const Color backgroundLight = Color(0xFFF7F7FA);
}
```

### 语义色彩
- **expenseRed**: 支出显示 (红色系)
- **incomeGreen**: 收入显示 (绿色系)
- **warning**: 警告状态 (橙色系)
- **success**: 成功状态 (绿色系)

### 主题变体
- **亮色主题**: 适合白天使用，高对比度
- **暗色主题**: 适合夜晚使用，低对比度
- **高对比度主题**: 无障碍性增强

## 字体系统

### 字体层次
- **Display**: 大标题，品牌展示
- **Headline**: 页面标题，重要信息
- **Title**: 卡片标题，区域标题
- **Body**: 正文内容，主要阅读文本
- **Label**: 标签，按钮文本，辅助信息

### 响应式字体
```dart
TextStyle responsiveHeadline(BuildContext context) {
  return AppDesignTokens.headline(context).copyWith(
    fontSize: _getResponsiveFontSize(context, baseSize: 24),
  );
}
```

## 间距系统

### 8pt网格系统
```
4pt, 8pt, 16pt, 24pt, 32pt, 48pt, 64pt, 96pt
```

### 组件间距规范
- **微小间距**: 4pt (图标与文字间)
- **小间距**: 8pt (列表项间)
- **中等间距**: 16pt (卡片间)
- **大间距**: 24pt (区域间)

## 圆角系统

### 圆角规范
- **无圆角**: 0pt (直角设计)
- **小圆角**: 4pt (按钮、标签)
- **中圆角**: 8pt (输入框、卡片)
- **大圆角**: 16pt (主要卡片、对话框)
- **特大圆角**: 20pt (特殊强调元素)

## 主题扩展机制

### 自定义主题属性
```dart
class FluxThemeExtension extends ThemeExtension<FluxThemeExtension> {
  final Color fluxPrimary;
  final Color fluxSecondary;
  final TextStyle fluxHeadline;

  const FluxThemeExtension({
    required this.fluxPrimary,
    required this.fluxSecondary,
    required this.fluxHeadline,
  });
}
```

### 主题切换
```dart
// 亮色主题
ThemeData lightTheme = AppTheme.lightTheme();

// 暗色主题
ThemeData darkTheme = AppTheme.darkTheme();

// 自定义主题
ThemeData customTheme = AppTheme.customTheme(
  primaryColor: customPrimary,
  secondaryColor: customSecondary,
);
```

## 平台适配

### iOS适配
- San Francisco字体族
- iOS设计规范遵循
- 安全区域适配

### Android适配
- Roboto字体族
- Material Design 3规范
- 系统导航栏适配

### Web适配
- 系统字体栈
- 响应式断点适配
- 触摸和鼠标交互统一

## 无障碍性支持

### 色彩对比度
- 所有文字组合满足WCAG AA标准
- 图标与背景的对比度要求
- 状态指示色的可见性保证

### 字体可读性
- 最小字体大小限制
- 行高优化
- 字间距调整

### 交互反馈
- 触摸目标最小尺寸
- 焦点指示器
- 屏幕阅读器支持

## 性能优化

### 1. 主题缓存
主题对象的智能缓存，避免重复创建。

### 2. 样式计算优化
响应式样式的延迟计算和缓存。

### 3. 字体加载优化
字体文件的按需加载和预加载。

### 4. 主题切换优化
平滑的主题过渡动画。

## 测试策略

### 视觉回归测试
- 主题切换的视觉一致性测试
- 多设备适配测试
- 色彩对比度测试

### 组件样式测试
- 设计令牌应用正确性测试
- 响应式布局测试
- 无障碍性功能测试

### 集成测试
- 主题与组件的集成测试
- 平台适配测试
- 动态主题切换测试

## 扩展开发

### 添加新的设计令牌
```dart
class AppDesignTokens {
  // 添加新的色彩令牌
  static const Color newAccentColor = Color(0xFF123456);

  // 添加新的字体样式
  static TextStyle newTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      color: textPrimary,
    );
  }
}
```

### 自定义主题扩展
```dart
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color customColor;
  final double customSpacing;

  const CustomThemeExtension({
    required this.customColor,
    required this.customSpacing,
  });

  // 实现必需的方法...
}
```

## 使用指南

### 应用主题
```dart
MaterialApp(
  theme: AppTheme.lightTheme(),
  darkTheme: AppTheme.darkTheme(),
  themeMode: themeProvider.themeMode,
  // ...
);
```

### 使用设计令牌
```dart
Container(
  padding: EdgeInsets.all(AppDesignTokens.spaceMedium),
  decoration: BoxDecoration(
    color: AppDesignTokens.surfaceWhite,
    borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
  ),
  child: Text(
    '示例文本',
    style: AppDesignTokens.bodyLarge(context),
  ),
);
```

## 相关文档

- [Core包总文档](../README.md)
- [UI设计系统文档](../../../.cursor/rules/ui-design-system.mdc)
- [Material Design 3规范](https://material.io/design)

