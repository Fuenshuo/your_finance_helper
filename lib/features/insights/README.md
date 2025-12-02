# Insights 模块

## 概述
`features/insights` 负责将账户、预算与 AI 能力整合成可视化洞察。模块输出每日/每周/每月的趋势、异常和建议，是 Stream Insights 体验的核心组成部分。

## 目录结构
```
insights/
├── models/        # Daily/Weekly/Monthly 数据建模
├── providers/     # Riverpod/Provider 状态
├── services/      # AI & 分析服务
├── widgets/       # 趋势卡片、图表组件
└── screens/       # Flux Insights 页面容器
```

## 核心服务
- `insight_service.dart`：统一的洞察订阅接口，Mock 版本支持本地播放。
- `ai_analysis_service.dart`：AI explainability 服务；最新实现保证 JSON 解析时显式 cast，并在缺少 actions 节点时安全回退到空列表。
- `pattern_detection_service.dart`：捕捉「周/日异常」及消费模式，为 AI 文案提供上下文。

## 关键组件
- `weekly_trend_chart.dart`：Apple Health 风格的周趋势柱状图，现在只接收 `WeeklyInsight`（包含 7 天数值 + 异常列表）。测试位于 `test/features/insights/widgets/weekly_trend_chart_test.dart`，通过 `_buildWeeklyInsight` helper 注入假数据。
- `daily_budget_velocity.dart` / `trend_radar_chart.dart`：用于 Phase 3 的日常脉冲和趋势雷达展示。

## 开发提示
- 当 AI 服务不可用时，`AiAnalysisService` 会回退到内置侦探式文案，避免 UI 空洞。
- 新增洞察 Widget 时优先复用 `InsightSnapshot<T>`，可同时携带 `isLoading` 与缓存数据，保证切换视图不卡顿。
- 所有 Widget 应遵守 `.cursor/rules/ui-component-styles.mdc` 中的命名和 Token 规范。

