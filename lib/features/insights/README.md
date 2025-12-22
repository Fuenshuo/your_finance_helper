# Insights 模块

## 概述
`features/insights` 负责将账户、预算与 AI 能力整合成可视化洞察。模块输出每日/每周/每月的趋势、异常和建议，是 Stream Insights 体验的核心组成部分。

**文件统计**: 34个Dart文件（models: 10个, providers: 2个, services: 11个, widgets: 7个, screens: 3个, utils: 1个）

## 目录结构
```
insights/
├── models/        # Daily/Weekly/Monthly 数据建模 (10个文件)
├── providers/     # Riverpod/Provider 状态 (2个文件)
├── services/      # AI & 分析服务 (11个文件)
├── utils/         # 工具函数 (1个文件)
├── widgets/       # 趋势卡片、图表组件 (7个文件)
└── screens/       # Flux Insights 页面容器 (3个文件)
```

## 核心服务
- `insight_service.dart`：统一的洞察订阅接口，Mock 版本支持本地播放。
- `ai_analysis_service.dart`：AI explainability 服务；最新实现保证 JSON 解析时显式 cast，并在缺少 actions 节点时安全回退到空列表。
- `services/ai_analysis_delegates.dart`：AI 可选扩展接口（Daily/Weekly/Monthly 分析）。为兼容 Mockito 在 sound null-safety 下的参数 matcher，这些接口的入参允许为 nullable（实现内部需自行做空值兜底）。
- `pattern_detection_service.dart`：捕捉「周/日异常」及消费模式，为 AI 文案提供上下文。
- `financial_calculation_service.dart`：财务计算（健康分等）；仅在需要读写本地缓存时才延迟初始化 `SharedPreferences`，避免影响纯计算与单元测试。
  - `insight_service.dart` 的 `jobStatusStream()` 会先发出当前 job 快照，再继续推送状态更新，避免订阅时机导致漏事件。

## 关键组件
- `weekly_trend_chart.dart`：Apple Health 风格的周趋势柱状图，现在只接收 `WeeklyInsight`（包含 7 天数值 + 异常列表）。测试位于 `test/features/insights/widgets/weekly_trend_chart_test.dart`，通过 `_buildWeeklyInsight` helper 注入假数据。
- `daily_budget_velocity.dart` / `trend_radar_chart.dart`：用于 Phase 3 的日常脉冲和趋势雷达展示。
- `structural_health_chart.dart`：结构健康环图组件；在小高度容器内会自动滚动，避免测试/页面出现溢出。

## 开发提示
- 当 AI 服务不可用时，`AiAnalysisService` 会回退到内置侦探式文案，避免 UI 空洞。
- 新增洞察 Widget 时优先复用 `InsightSnapshot<T>`，可同时携带 `isLoading` 与缓存数据，保证切换视图不卡顿。
- 所有 Widget 应遵守 `.cursor/rules/ui-component-styles.mdc` 中的命名和 Token 规范。
- Widget 内部若有异步计算并更新状态（`setState`），务必在更新前检查 `mounted`，避免「setState() called after dispose()」。
- 服务层的 `switch` 分支务必显式 `break`，避免 fall-through 造成评分/推荐错误（CI 也会严格检查此类问题）。

