# Core 包文档

## 概述

`core` 包是应用的核心功能层，提供基础设施和通用功能，被所有功能模块共享使用。它遵循"核心功能下沉"的原则，将可复用的代码集中管理。

## 包结构

```
core/
├── animations/          # 动画系统
├── constants/           # 常量定义
├── database/            # 数据库层
├── models/              # 数据模型
├── providers/           # 状态管理
├── router/              # 路由配置
├── services/            # 业务服务
├── theme/               # 主题样式
├── utils/               # 工具类
└── widgets/             # 通用组件
```

## 子包说明

### 1. animations/ - 动画系统

**职责**: 提供统一的动画管理和iOS风格动画系统

**主要文件**:
- `ios_animation_system.dart` - iOS风格动画系统核心
- `animation_engine.dart` - 动画引擎
- `animation_config.dart` - 动画配置

**关键特性**:
- 企业级iOS动画系统
- 自定义动画曲线注册
- 页面转场动画
- 微交互动效

**使用场景**:
- 页面导航转场
- 表单交互反馈
- 数据刷新动画
- 列表项动画

### 2. constants/ - 常量定义

**职责**: 定义应用级别的常量

**主要文件**:
- `app_icons.dart` - 图标常量定义

**关键特性**:
- 统一的图标引用
- 避免硬编码字符串

### 3. database/ - 数据库层

**职责**: 提供类型安全的数据库操作

**主要文件**:
- `app_database.dart` - Drift数据库定义
- `app_database.g.dart` - 自动生成的数据库代码

**关键特性**:
- 使用Drift (类型安全的SQLite ORM)
- 表结构定义
- 数据库迁移策略
- 响应式数据流 (Stream)

**数据表**:
- Assets (资产)
- Transactions (交易)
- Accounts (账户)
- EnvelopeBudgets (信封预算)
- ZeroBasedBudgets (零基预算)
- SalaryIncomes (工资收入)
- AssetHistories (资产历史)
- ExpensePlans (支出计划)
- IncomePlans (收入计划)

### 4. models/ - 数据模型

**职责**: 定义应用的核心数据模型

**主要模型**:
- `account.dart` - 账户模型（现金、银行、信用卡、贷款等）
- `asset_item.dart` - 资产项模型（五大资产分类）
- `asset_history.dart` - 资产历史记录模型
- `bonus_item.dart` - 奖金项模型
- `budget.dart` - 预算模型（信封预算、零基预算、工资收入）
- `clearance_entry.dart` - 清账记录模型
- `currency.dart` - 货币和汇率模型
- `expense_plan.dart` - 支出计划模型
- `income_plan.dart` - 收入计划模型
- `transaction.dart` - 交易模型
- `ai_config.dart` - AI配置模型
- `parsed_transaction.dart` - AI解析交易模型（新增）

**关键特性**:
- 使用Equatable实现值比较
- 完整的JSON序列化/反序列化
- 枚举类型定义
- 业务逻辑验证

### 5. providers/ - 状态管理

**职责**: 提供状态管理功能，连接UI和数据层

**主要Provider**:
- `account_provider.dart` - 账户状态管理
- `asset_provider.dart` - 资产状态管理
- `budget_provider.dart` - 预算状态管理
- `expense_plan_provider.dart` - 支出计划状态管理
- `income_plan_provider.dart` - 收入计划状态管理
- `transaction_provider.dart` - 交易状态管理
- `riverpod_providers.dart` - Riverpod状态管理（新架构）

**关键特性**:
- Provider模式（ChangeNotifier）
- Riverpod支持（新功能）
- 数据同步和缓存
- 状态持久化

**架构演进**:
- 旧架构: Provider + SharedPreferences
- 新架构: Riverpod + Drift Database

### 6. router/ - 路由配置

**职责**: 管理应用的路由导航

**主要文件**:
- `app_router.dart` - GoRouter路由配置

**关键特性**:
- 使用GoRouter进行声明式路由
- 路由常量定义
- 页面参数传递
- 路由守卫和重定向

**路由分类**:
- 主路由（home, onboarding, settings等）
- 家庭信息路由（family-info/*）
- 财务计划路由（financial-planning/*）
- 交易流水路由（transaction-flow/*）

### 7. services/ - 业务服务

**职责**: 提供业务逻辑处理和外部服务集成

**主要服务**:
- `storage_service.dart` - 存储服务（SharedPreferences）
- `drift_database_service.dart` - Drift数据库服务
- `hybrid_storage_service.dart` - 混合存储服务
- `data_migration_service.dart` - 数据迁移服务
- `clearance_service.dart` - 清账服务
- `personal_income_tax_service.dart` - 个税计算服务
- `salary_calculation_service.dart` - 工资计算服务
- `loan_calculation_service.dart` - 贷款计算服务
- `chinese_mortgage_service.dart` - 中国房贷计算服务
- `depreciation_service.dart` - 资产折旧服务
- `asset_history_service.dart` - 资产历史服务
- `total_assets_service.dart` - 总资产计算服务
- `dio_http_service.dart` - HTTP请求服务
- `logging_service.dart` - 日志服务
- `persistent_storage_service.dart` - 持久化存储服务
- `ai/` - AI服务目录
  - `ai_config_service.dart` - AI配置服务
  - `ai_service_factory.dart` - AI服务工厂
  - `ai_service.dart` - AI服务抽象接口
  - `dashscope_ai_service.dart` - DashScope AI服务实现
  - `siliconflow_ai_service.dart` - SiliconFlow AI服务实现
  - `natural_language_transaction_service.dart` - 自然语言记账服务（新增）
  - `image_processing_service.dart` - 图片处理服务（新增）
  - `invoice_recognition_service.dart` - 发票/收据识别服务（新增）

**关键特性**:
- 单例模式
- 异步操作支持
- 错误处理
- 服务间解耦

### 8. theme/ - 主题样式

**职责**: 定义应用的主题和样式系统

**主要文件**:
- `app_theme.dart` - 应用主题定义
- `responsive_text_styles.dart` - 响应式文本样式

**关键特性**:
- Material Design 3规范
- 8pt间距系统
- 12pt圆角半径
- 响应式字体大小
- 深色模式支持（框架已准备）

**设计规范**:
- 主色调: 活力蓝 (#007AFF)
- 背景色: 淡雅灰 (#F7F7FA)
- 文本色: 深邃灰 (#1C1C1E)
- 辅助色: 中性灰 (#8A8A8E)

### 9. utils/ - 工具类

**职责**: 提供通用工具函数和辅助类

**主要工具**:
- `logger.dart` - 日志工具（结构化日志）
- `performance_monitor.dart` - 性能监控
- `notification_manager.dart` - 通知管理
- `unified_notifications.dart` - 统一通知系统
- `debug_mode_manager.dart` - 调试模式管理
- `salary_form_validators.dart` - 工资表单验证器
- `ai_date_parser.dart` - AI日期解析工具（新增）

**关键特性**:
- 结构化日志输出
- 性能指标收集
- 调试工具支持
- 表单验证工具

### 10. widgets/ - 通用组件

**职责**: 提供可复用的UI组件

**主要组件**:
- `app_card.dart` - 统一卡片组件
- `app_animations.dart` - 动画工具
- `amount_input_field.dart` - 金额输入组件
- `sankey_chart_widget.dart` - 桑基图组件
- `trend_chart_widget.dart` - 趋势图组件
- `overview_trend_chart.dart` - 概览趋势图
- `swipe_action_item.dart` - 滑动操作项
- `glass_notification.dart` - 玻璃态通知
- `enhanced_floating_action_button.dart` - 增强型FAB
- `data_refresh_animation.dart` - 数据刷新动画
- `animations/` - 动画组件集合

**关键特性**:
- 统一的设计语言
- 响应式布局支持
- 可配置属性
- 动画集成

## 设计原则

### 1. 单一职责
每个子包只负责一个明确的功能领域，避免职责交叉。

### 2. 依赖方向
- `features` 包依赖 `core` 包
- `core` 包不依赖 `features` 包
- `core` 包内部可以相互依赖

### 3. 可复用性
`core` 包的所有组件和服务都应该设计为可复用的，避免包含业务特定的逻辑。

### 4. 类型安全
- 使用Drift进行类型安全的数据库操作
- 使用枚举类型避免魔法字符串
- 使用强类型模型

### 5. 测试友好
- 服务类支持依赖注入
- 工具类提供纯函数
- 组件支持独立测试

## 使用指南

### 添加新的数据模型

1. 在 `models/` 目录下创建新的模型文件
2. 实现 `Equatable` 接口
3. 添加 `toJson()` 和 `fromJson()` 方法
4. 如需数据库支持，在 `database/app_database.dart` 中添加表定义

### 添加新的服务

1. 在 `services/` 目录下创建服务文件
2. 使用单例模式
3. 提供异步方法
4. 添加错误处理

### 添加新的Provider

1. 在 `providers/` 目录下创建Provider文件
2. 继承 `ChangeNotifier` 或使用 `StateNotifier`
3. 实现数据加载和更新方法
4. 在 `main.dart` 中注册Provider

### 添加新的通用组件

1. 在 `widgets/` 目录下创建组件文件
2. 遵循设计系统规范
3. 支持响应式布局
4. 添加必要的文档注释

## 相关文档

- [数据存储架构与格式说明](../../DEV_DOCUMENT/数据存储架构与格式说明.md)
- [项目架构重构总结](../../项目架构重构总结.md)
- [UI设计系统文档](../../.cursor/rules/ui-design-system.mdc)

