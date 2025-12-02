# Models 包文档

## 概述

`models` 包定义了应用的核心数据模型，包括所有业务实体的数据结构、枚举类型和业务规则。

## 模型列表

### 1. account.dart - 账户模型

**职责**: 定义账户相关的数据结构和枚举

**枚举类型**:
- `AccountType` - 账户类型（现金、银行、信用卡、投资、贷款、资产、负债）
- `AccountStatus` - 账户状态（活跃、暂停、关闭）
- `LoanType` - 贷款类型（房贷、商业房贷、公积金贷款、组合贷款、车贷等）
- `RepaymentMethod` - 还款方式（等额本息、等额本金、先息后本等）

**核心类**:
- `Account` - 账户实体
  - 支持多种账户类型
  - 包含余额、信用额度、利率等属性
  - 支持贷款账户的详细信息（还款方式、期限等）

**使用场景**:
- 钱包管理
- 账户余额跟踪
- 贷款管理
- 账户间转账

### 2. asset_item.dart - 资产项模型

**职责**: 定义资产相关的数据结构和枚举

**枚举类型**:
- `AssetCategory` - 资产分类（流动资产、不动产、投资理财、消费资产、应收款、债务）
- `DepreciationMethod` - 折旧方法（无、直线法、加速折旧等）

**核心类**:
- `AssetItem` - 资产项实体
  - 支持五大资产分类
  - 包含金额、购买日期、折旧信息
  - 支持固定资产的详细信息（房产、车辆等）

**使用场景**:
- 资产管理
- 资产估值
- 资产折旧计算
- 资产历史追踪

### 3. asset_history.dart - 资产历史模型

**职责**: 定义资产变更历史记录

**枚举类型**:
- `AssetChangeType` - 变更类型（创建、更新、删除、估值变更等）

**核心类**:
- `AssetHistory` - 资产历史记录
  - 记录资产的所有变更
  - 包含变更前后的状态对比
  - 支持导出功能

**使用场景**:
- 资产变更追踪
- 历史记录查询
- 数据导出

### 4. bonus_item.dart - 奖金项模型

**职责**: 定义奖金相关的数据结构

**枚举类型**:
- `BonusType` - 奖金类型（年终奖、季度奖、项目奖等）
- `BonusFrequency` - 奖金频率（一次性、季度、年度等）

**核心类**:
- `BonusItem` - 奖金项实体
  - 支持多种奖金类型
  - 包含金额、发放日期、归属日期等
  - 支持季度奖金的月份配置

**使用场景**:
- 工资管理
- 奖金计算
- 税务计算

### 5. budget.dart - 预算模型

**职责**: 定义预算相关的数据结构和枚举

**枚举类型**:
- `BudgetType` - 预算类型（信封预算、零基预算）
- `BudgetPeriod` - 预算周期（日、周、月、年）
- `BudgetStatus` - 预算状态（活跃、暂停、完成）
- `IncomeType` - 收入类型

**核心类**:
- `EnvelopeBudget` - 信封预算
  - 为特定类别设定支出限额
  - 跟踪已花费金额
  - 支持警告阈值和限制阈值

- `ZeroBasedBudget` - 零基预算
  - 将收入分配到各个类别
  - 确保总分配不超过总收入

- `SalaryIncome` - 工资收入
  - 包含基本工资、津贴、奖金
  - 支持个税、社保、公积金计算
  - 包含工资历史记录

- `MonthlyWallet` - 月度钱包
  - 月度预算和支出管理
  - 支持多账户余额汇总

**使用场景**:
- 预算管理
- 支出控制
- 工资管理
- 月度财务规划

### 6. clearance_entry.dart - 清账记录模型

**职责**: 定义周期清账相关的数据结构

**枚举类型**:
- `PeriodType` - 周期类型（日、周、月、季度、年）
- `ClearanceSessionStatus` - 清账会话状态（余额输入、差额分析、完成等）

**核心类**:
- `PeriodClearanceSession` - 周期清账会话
  - 管理一个周期的清账流程
  - 包含期初余额、期末余额、差额
  - 支持手动添加交易来解释差额

- `WalletBalanceSnapshot` - 钱包余额快照
  - 记录某个时间点的钱包余额

- `WalletDifference` - 钱包差额
  - 计算期初和期末的差额
  - 支持差额分解

- `PeriodSummary` - 周期总结
  - 生成周期性的财务报告
  - 包含收支分析、分类统计

**使用场景**:
- 周期对账
- 差额分析
- 财务总结
- 清账历史

### 7. currency.dart - 货币模型

**职责**: 定义货币和汇率相关的数据结构

**核心类**:
- `Currency` - 货币实体
  - 货币代码、名称、符号
  - 支持多币种

- `ExchangeRate` - 汇率实体
  - 汇率值、更新时间

- `CurrencyConverter` - 货币转换器
  - 提供货币转换功能

**使用场景**:
- 多币种支持
- 汇率转换
- 国际化

### 8. expense_plan.dart - 支出计划模型

**职责**: 定义支出计划相关的数据结构

**枚举类型**:
- `ExpensePlanType` - 支出计划类型（周期性、预算性）
- `ExpenseFrequency` - 支出频率（日、周、月、年）
- `ExpensePlanStatus` - 支出计划状态（活跃、暂停、完成）

**核心类**:
- `ExpensePlan` - 支出计划实体
  - 定义周期性支出规则
  - 支持自动生成交易
  - 关联账户和分类

**使用场景**:
- 财务计划
- 周期性支出管理
- 自动交易生成

### 9. income_plan.dart - 收入计划模型

**职责**: 定义收入计划相关的数据结构

**枚举类型**:
- `IncomeFrequency` - 收入频率（日、周、月、年）

**核心类**:
- `IncomePlan` - 收入计划实体
  - 定义周期性收入规则
  - 支持普通收入和详细工资两种模式
  - 支持自动生成交易

- `IncomePlanExecution` - 收入计划执行记录
  - 记录计划的执行历史

**使用场景**:
- 财务计划
- 收入规划
- 自动交易生成

### 10. transaction.dart - 交易模型

**职责**: 定义交易相关的数据结构和枚举

**枚举类型**:
- `TransactionFlow` - 交易流向（收入、支出、转账）
- `TransactionType` - 交易类型（收入、支出、转账）
- `TransactionStatus` - 交易状态（草稿、已确认、已取消）
- `TransactionCategory` - 交易分类（餐饮、交通、购物等）

**核心类**:
- `Transaction` - 交易实体
  - 支持收入、支出、转账三种类型
  - 关联账户、预算、计划
  - 支持重复交易标记
  - 支持自动生成标记

**使用场景**:
- 交易记录
- 收支管理
- 账户转账
- 预算关联

### 11. ai_config.dart - AI配置模型

**职责**: 定义AI服务相关的配置和数据结构

**枚举类型**:
- `AiProvider` - AI服务提供商（DashScope、SiliconFlow等）
- `AiModelType` - AI模型类型（LLM、Vision等）

**核心类**:
- `AiConfig` - AI配置实体
  - API密钥管理
  - 模型选择
  - 参数配置

- `AiMessage` - AI消息实体
  - 消息内容
  - 角色定义

- `AiResponse` - AI响应实体
  - 响应内容
  - Token使用统计

**使用场景**:
- AI功能配置
- 智能建议
- 数据分析

### 12. parsed_transaction.dart - AI解析交易模型

**职责**: 定义AI解析后的交易数据结构

**枚举类型**:
- `ParsedTransactionSource` - 解析数据来源（自然语言、发票识别、收据识别、银行账单等）

**核心类**:
- `ParsedTransaction` - AI解析后的交易数据
  - 包含所有交易字段（描述、金额、分类、账户等）
  - 包含置信度信息（0.0-1.0）
  - 包含数据来源信息
  - 支持转换为Transaction对象
  - 支持有效性验证

**使用场景**:
- 自然语言记账
- 发票/收据识别
- 银行账单识别
- AI解析结果展示和确认

### 13. flux_view_state.dart - Flux视图状态模型

**职责**: 统一管理Stream时间范围、当前Pane以及特性开关，确保单页Stream+Insights体验的状态一致性。

**核心内容**:
- `FluxViewState` - 基于 `Equatable` 的不可变数据模型，包含 `timeframe`、`pane`、`isFlagEnabled`、`lastDrawerUpdate` 字段，并提供 `toJson/fromJson` 序列化。
- `fluxViewStateProvider` - Riverpod `StateNotifierProvider`，封装 `FluxViewStateNotifier`，负责切换时间范围、Pane以及处理Drawer时间戳更新。
- `FluxViewStateNotifier` - 暴露 `setTimeframe`、`setPane`、`syncFlag`、`markDrawerUpdated`、`reset` 等方法，自动在flag关闭时回落到 `FluxPane.timeline`，默认在初始态即开启Stream Insights合并体验（`isFlagEnabled = true`），方便本地/测试环境直接体验。

**使用场景**:
- `UnifiedTransactionEntryScreen` 中的Day/Week/Month分段控制
- Flux Insights pane与时间轴的切换动画
- Drawer消息节流与telemetry事件的状态来源

### 14. insights_drawer_state.dart - Insights抽屉状态模型

**职责**: 抽象Drawer显隐、展开状态、最新消息与改进计数器，并封装定时器控制逻辑。

**核心内容**:
- `InsightsDrawerState` - 不可变状态对象，包含 `isVisible`、`isExpanded`、`message`、`improvementCount`、`collapseTimer` 等字段。
- `insightsDrawerControllerProvider` - Riverpod Provider，暴露 `InsightsDrawerController`。
- `InsightsDrawerController` - 处理分析结果的聚合(`handleAnalysisSummary`)、延迟展开、自动折叠(`collapseNow`)以及计数器更新。

**使用场景**:
- 统一记账入口页头部的Insights Drawer动画控制
- 测试用例（T017/T018）模拟消息堆积与延迟展开场景
- Telemetry记录抽屉打开/收起事件

### 15. analysis_summary.dart - Insights分析总结 & Telemetry事件

**职责**: 定义 `/insights/analysis` 与 `/telemetry/stream-insights` 对应的数据结构，方便序列化与Riverpod状态共享。

**核心内容**:
- `AnalysisSummary` - 包含 `analysisId`、`generatedAt`、`improvementsFound`、`topRecommendation`、`deepLink` 等字段，提供 `copyWith`、`toJson/fromJson`。
- `StreamInsightsTelemetryEventType` - 规范化事件字符串（view_toggled、drawer_open、drawer_collapse、analysis_summary、flag_state）。
- `StreamInsightsTelemetryEvent` - 统一的Telemetry载体，支持 `viewToggle`、`drawer`、`analysis`、`flag` 工厂方法以及JSON序列化。

**使用场景**:
- Drawer控制器在收到新的 `AnalysisSummary` 时，向Telemetry记录 `analysis_summary` 事件。
- `PerformanceMonitor` 通过 `StreamInsightsTelemetryEvent` 将view切换、抽屉显隐、flag变化日志化。

## 设计原则

### 1. 不可变性优先
模型类使用 `Equatable` 实现值比较，优先使用不可变对象。

### 2. 完整的序列化支持
所有模型都提供 `toJson()` 和 `fromJson()` 方法，支持JSON序列化。

### 3. 业务规则内聚
将相关的业务规则和验证逻辑放在模型类中，而不是分散在服务层。

### 4. 枚举类型使用
使用枚举类型替代魔法字符串，提高类型安全性。

### 5. 文档注释
所有公共API都提供详细的文档注释，说明用途和使用场景。

## 使用指南

### 创建新模型

```dart
import 'package:equatable/equatable.dart';

class MyModel extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;

  const MyModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, createdAt];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MyModel.fromJson(Map<String, dynamic> json) => MyModel(
    id: json['id'] as String,
    name: json['name'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
```

### 添加枚举类型

```dart
enum MyEnum {
  value1('显示名称1'),
  value2('显示名称2');

  const MyEnum(this.displayName);
  final String displayName;
}
```

## 相关文档

- [数据存储架构与格式说明](../../../DEV_DOCUMENT/数据存储架构与格式说明.md)
- [Database包文档](../database/README.md)

