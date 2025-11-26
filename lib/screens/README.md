# Screens 通用页面文档

## 概述

`screens` 包包含应用级别的通用页面，这些页面不属于特定的功能模块，而是为整个应用提供导航、设置、开发者工具等功能。

## 页面列表

### 1. main_navigation_screen.dart - 主导航页面

**职责**: 提供 Flux Ledger 的主导航界面，承载 Smart Timeline 入口以及扩展模块。

**功能**:
- 底部导航栏（四个主要模块）
  - **Stream**：Smart Timeline（`UnifiedTransactionEntryScreen`）
  - **Insights**：图表与洞察占位页面
  - **Assets**：资产/账户占位页面
  - **Me**：个人中心与设置占位页面
- 顶部 AppBar（调试模式点击开启、统一的 Flux Ledger 品牌标题）
- Stream Tab 内的 Input Dock 通过 `Stack` 固定在底部导航上方
- 使用 `IndexedStack` 保持页面状态

**导航结构**:
```
MainNavigationScreen
├── UnifiedTransactionEntryScreen (Stream)
├── _PlaceholderScreen (Insights)
├── _PlaceholderScreen (Assets)
└── _PlaceholderScreen (Me)
```

### 2. home_screen.dart - 首页路由

**职责**: 应用入口页面，决定跳转到主导航还是引导页

**功能**:
- 检查首次使用状态
- 首次使用 → 跳转到引导页
- 非首次使用 → 跳转到主导航

**逻辑**:
```dart
if (isFirstLaunch) {
  → OnboardingScreen
} else {
  → MainNavigationScreen
}
```

### 3. dashboard_screen.dart - 数据概览页

**职责**: 展示应用的总体数据概览

**功能**:
- 总资产展示
- 净资产展示
- 收支统计
- 资产分布图表
- 交易趋势图表

**数据来源**:
- AssetProvider - 资产数据
- TransactionProvider - 交易数据
- AccountProvider - 账户数据

### 4. onboarding_screen.dart - 引导页面

**职责**: 首次使用时的引导流程

**功能**:
- 应用介绍
- 功能说明
- 引导用户完成初始设置
- 标记首次使用完成

**流程**:
1. 欢迎页面
2. 功能介绍
3. 初始设置引导
4. 完成引导，跳转到主导航

### 5. settings_screen.dart - 设置页面

**职责**: 应用设置和配置

**功能**:
- 主题设置（浅色/深色模式）
- 语言设置
- 数据管理（导出、导入、清空）
- 关于应用
- 隐私设置

**设置项**:
- 外观设置
- 数据管理
- 通知设置
- 关于信息

### 6. developer_mode_screen.dart - 开发者模式

**职责**: 开发者工具和数据管理

**功能**:
- 数据导出（JSON格式）
- 数据导入（从剪贴板）
- 测试数据生成
- 数据清空
- 历史清账数据处理
- 强制数据迁移
- 数据库检查工具
- 性能监控

**使用场景**:
- 开发调试
- 数据备份和恢复
- 测试数据生成
- 数据迁移

### 7. ai_config_screen.dart - AI配置页面

**职责**: AI服务配置和管理

**功能**:
- AI服务提供商选择（DashScope、SiliconFlow等）
- API密钥配置
- 模型选择
- 参数配置（温度、最大Token等）
- API密钥验证
- 使用统计

**AI服务**:
- DashScope（阿里云）
- SiliconFlow
- 其他AI服务提供商

### 8. 其他页面

- **debug_screen.dart**: 调试页面（开发用）
- **responsive_test_screen.dart**: 响应式测试页面
- **personal_screen.dart**: 个人中心页面

### 9. unified_transaction_entry_screen.dart - Smart Timeline

**职责**: 作为 Phase 1 的首页体验，提供「Smart Timeline」交易流和极简 Input Dock。

**核心功能**:
- **日卡片分组**：根据日期自动分组（Today / Yesterday / 日期），每个分组包裹在白色卡片（20px圆角 + Diffused Shadow）中。
- **交易行样式**：系统图标 + 单行标题 + 右侧等宽金额（收入为 `incomeGreen`，支出为 `expenseRed`），对齐 Apple Wallet 风格。
- **数据来源**：直接消费 `TransactionProvider.transactions`，仅展示已确认交易，并自动排序。
- **Input Dock**：白色背景、24px 顶部圆角，一行输入 + 快捷发送按钮，悬浮在底部导航上方，保持与底部安全区域隔离。
- **Input Dock Night Shift**：输入栏、按钮、图标全面接入 `AppDesignTokens` 语义色，浅/深色模式自动切换（fill、hint、文本皆自适应）。
- **Icon Adaptive Aura**：导航角标和时间线分类图标根据亮/暗主题切换描边与背景光晕，保证色彩对比和品牌层次。
- **AI 入口保留**：继续复用解析、确认、澄清等 AI 流程逻辑，但 UI 由聊天式改为时间线。
- **Rainbow Flux 动画系统（Phase 3）**：
  - **Step A – Shrink & Spin**：发送后 Input Dock 从全宽压缩为 Send 按钮的能量球，按钮外圈使用 `CustomPainter` 绘制蓝紫粉橙渐变并与旋转控制器联动。
  - **Step A Loading Update**：`_RainbowSendButton` 在 Loading 状态下强制彩虹描边保持可见，避免刚触发发送时 halo/旋转指示器被折叠进度遮挡。
  - **Step A Input Visibility**：Loading 期间不再触发 Input Dock 折叠动画，发送按钮会在原位持续展示旋转 Loading，直至 AI 解析完成。
  - **Step A Halo Refresh**：彩虹环改为加粗的实心 360° 渐变闭环，旋转速度提升至 1 秒/圈，加强能量感。
  - **Step B – Expansion**：AI 解析完成时，能量球膨胀为 Draft Card 的柔和高光边框（已去除彩虹描边），边框跟随 spring 曲线展开并保持聚焦状态。
  - **Step C – Highlight**：确认按钮触发 `ScaleTransition` + 光晕阴影，提供即时反馈。
  - **Step D – Absorption**：Draft Card 合并时缩放/上抛，自动滚动到目标日卡片，卡片边框点亮淡色高光；新交易行通过 `flutter_animate().slideY().fadeIn()` 注入时间线，渐变高亮后自然冷却。
  - **Phase 3.5 - Liquid Morph**：Input Dock 使用 AnimatedContainer 实现宽度/圆角渐变，逐帧收缩至 loading 圆形，同时只有在完全收缩时才展示 Rainbow Halo；Draft Card 入口改为 SpringSimulation（scale/opacity 从 0.2→1），视觉效果像能量泡泡向上爆开。
- **Draft Card Liquid Pop**：Draft Card 使用 `flutter_animate` 的 `scaleXY + fadeIn + shimmer` 链式动效，自 Send 按钮方向弹出，并以纯白面板 + 淡品牌色描边搭配柔和阴影呈现，无彩虹特效。
- **Draft Card Cancel Exit**：金额右侧新增圆形“X”按钮，可在无需确认时立刻关闭 Draft、停止光晕动画并恢复输入 Dock。
- **Flux Toast Pill**：所有解析/错误提示改为悬浮的深色磨砂胶囊 Toast，带图标状态色、轻微上浮动画，不再遮挡底部导航。
- **Draft Card Launchpad**：Draft Card 弹射改用 `Curves.elasticOut` + `moveY` 曲线，并在生成时触发 `HapticFeedback.mediumImpact()`，实现类似 Apple Wallet 的“能量弹射”体验。
- **Rolling Amount Numbers**：Draft 卡片上的金额使用 `TweenAnimationBuilder` 0→目标值的缓出指数曲线滚动，搭配等宽字体保持视觉稳定。
- **Waterfall Timeline**：时间线日卡片在加载时应用按索引递增的 `fadeIn + slideY` 延迟，营造瀑布式注入的动效节奏。
- **Morphing Aggregation（Phase 3）**：提供「日 / 周」两种视图模式，使用 `SliverAnimatedList` + Anchor Day 策略完成日卡片与同周聚合卡片之间的流体切换，卡片尺寸由 `AnimatedSize` 平滑过渡，确保视图切换时时间线高度无突兀跳变。
- **Week Trend Pulse**：周视图不再显示完整流水，而是用双向七日趋势柱状图展示每日收入/支出的脉冲，直观对比高峰支出和进账。
- **Month Insight View**：新增 `ViewMode.month`，以“月度账单卡片”展示本月收入、支出与 Top5 消费类别排名，强调宏观视角而非流水细节。
- **Month Segmented Breakdown**：月度卡片内置支出/收入分段控制器，切换查看 TOP 列表，默认展示支出构成。
- **View Toggle Frosted Orb**：日/周切换按钮移至导航栏左侧，采用 44px 圆形 BackdropFilter “磨砂玻璃”样式，与标题/设置图标形成平衡的导航三角，同时释放时间线首屏空间。
- **Theme Palette Button**：右上角新增磨砂设置按钮，支持在浅色/深色/系统主题之间快速切换，并集中管理视觉设置。
- **Amount Theme Switcher**：主题弹窗内可切换 3 套金额色彩体系（Flux Blue / Forest Emerald / Graphite Mono），完全依赖 `AppDesignTokens`，确保浅色/深色模式一致生效。
- **Zoom & Fade Morph**：日/周切换的进/出场动画采用 Fade + Scale 组合（轻微缩放至 0.9），替换之前的 SizeTransition 折叠，带来更柔和的缩放渐隐体验。
- **Right-edge Scrubber（Phase 4）**：右侧 6px 透明索引条支持全局拖拽；拖拽时根据手势位置跳转到对应日期/周，展示带 `selectionClick` 触感的黑色信息气泡，并实时更新 `_scrubLabel` 与 `_scrollController.jumpTo` 实现秒级定位。
- **紧凑输入与中文语境**：输入 Dock 缩减为 56px pill、44~52px send button，文本与按钮垂直对齐，标题改为“智能账单”，日期头矩阵与 chip 统一汉化（今天/昨天/日期）。
- **Monospaced Timeline 数字**：所有金额统一使用 `GoogleFonts.ibmPlexMono` 等宽字体，搭配 `Gap` 布局间距保持 Timeline 数字与输入 Dock 金额对齐。
- **Smart Timeline Skeleton**：时间线加载阶段以 `AppShimmer` 骨架屏替换 `CircularProgressIndicator`，保持页面结构稳定并为数据注入制造期待感。

### 10. unified_transaction_entry_screen_v2.dart - AI 统一记账入口 V2

**职责**: 提供“自然语言 + AI 解析 + 单手操作”一体化的键盘伴侣式记账体验。

**核心交互**:
- 底部沉浸式面板：自动聚焦输入框，配套智能提示轮播。
- AI 账单预览卡片：金额、分类、账户、日期等识别结果收纳在同一个淡灰圆角容器中，搭配置信度徽章与原始语句引用，避免“红色金额漂浮”的割裂感。
- 智能状态按钮：输入中显示蓝色“发送”箭头；当 AI 结果完整且可信时自动切换为绿色“确认”✅，形成闭环。
- 原文快照：解析成功后自动清空输入框，将原句以引用形式展示，可随时“编辑”重新发起识别。
- 增量补录：卡片存在时再次输入会与快照合并后重新识别，卡片更新时会闪光提示，适合逐步补充支付方式、日期等细节。
- 幽灵占位提示：输入框在补录模式下会显示“正在完善: xxx”语句，实时提醒当前操作针对哪条账单。
- 非破坏式刷新：补录提交时卡片保持可见，仅显示轻量加载层，确保视觉连续性与安全感。
- 补录防重复：当没有快照却需要补录时，会同步清空 `_lastRequestedDescription`，避免新输入因为去重逻辑被忽略。

**依赖**:
- `TransactionProvider` 获取最近交易历史用于 few-shot。
- `NaturalLanguageTransactionService` 做实时解析。
- `Phosphor` 图标库 + `Flutter Animate` 负责动效与 skeleton。

## 页面关系

```
HomeScreen (入口)
    ↓
    ├── OnboardingScreen (首次使用)
    │       ↓
    │   MainNavigationScreen
    │
    └── MainNavigationScreen (非首次使用)
            ├── FamilyInfoHomeScreen
            ├── FinancialPlanningHomeScreen
            └── TransactionFlowHomeScreen

SettingsScreen (设置)
    ├── 数据管理
    ├── 主题设置
    └── 关于应用

DeveloperModeScreen (开发者模式)
    ├── 数据导出/导入
    ├── 测试数据生成
    └── 数据迁移

AIConfigScreen (AI配置)
    ├── 服务提供商选择
    ├── API密钥配置
    └── 模型配置
```

## 设计原则

### 1. 通用性
这些页面不包含特定业务逻辑，而是提供通用的应用功能。

### 2. 导航中心
`main_navigation_screen.dart` 作为应用的导航中心，管理主要功能模块的切换。

### 3. 状态管理
使用Provider管理页面状态，确保数据一致性。

### 4. 用户体验
- 流畅的页面转场动画
- 清晰的信息层次
- 友好的错误提示

## 使用指南

### 添加新的通用页面

1. 在 `screens/` 目录下创建新页面文件
2. 在 `core/router/app_router.dart` 中添加路由配置
3. 在相应的入口页面添加导航逻辑

### 修改主导航结构

1. 编辑 `main_navigation_screen.dart`
2. 修改底部导航栏的标签和图标
3. 更新路由配置

### 添加新的设置项

1. 编辑 `settings_screen.dart`
2. 添加新的设置项UI
3. 实现设置逻辑
4. 持久化设置数据

## 相关文档

- [Core包文档](../core/README.md)
- [Router文档](../core/router/README.md)
- [项目架构文档](../ARCHITECTURE.md)

